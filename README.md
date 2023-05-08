
Bucket and Dynamo [LockID]
1.
soso-s3-bucket
my-sosodynamo1
2.
soso-s3-bucket
my-sosodynamo2
3.
soso-s3-bucket
my-sosodynamo3

Bucket

soso-s3-bucket

[docker pull jenkins/jenkins:2.387.2-lts-jdk11](https://hub.docker.com/r/jenkins/jenkins/tags)

```sudo docker pull jenkins/jenkins:2.387.2-lts-jdk11```

[docker pull jenkins/jnlp-slave](https://hub.docker.com/r/jenkins/jnlp-slave)

```docker pull jenkins/jnlp-slave```


kubectl exec -it jenkins-5857f888b5-6zz54 -- /bin/bash
sudo cat /var/jenkins_home/secrets/initialAdminPassword

***get JAVA_Home***
```echo $JAVA_HOME```
```java version```
```whereis java```

```whereis git```

***You can go to jenkins home from the container: ```/var/jenkins_home```***
***You can see your workspace at: ```/var/jenkins_home/workspace```***


### some commands to run on Jenkins server 
sudo apt install openjdk-8-jdk -y

https://github.com/cn-terraform/terraform-aws-jenkins/blob/main/main.tf


```
kubectl exec -it jenkins-5857f888b5-92wh6 -- /bin/bash

java -version

cd /usr/share/nginx/html/efs
```

***Creating a specific resource***

terraform apply --target=[resource]


aws eks update-kubeconfig --region us-east-1 --name MiddleWare-Prod-eks-sosotech	


sonarqube login is: admin  - admin


## EX 3:
- install GitHub Cli
- Create 4 repos: 
  - flux-production/apps
  - flux-staging/apps
  - flux-fleet[with-bootstrapping]
  - devops-toolkit/apps[repo-already-exists]
- clone them separately
- create namespaces: production and staging 
- create prod and staging source files in the [app] folder
- create a kustomization for prod and staging source files in the [app] folder


***Install Git Cli***

```
wget https://github.com/cli/cli/releases/download/v2.15.0/gh_2.15.0_linux_amd64.rpm

sudo rpm -i gh_2.15.0_linux_amd64.rpm

gh --version
```

copy key and create in Github-SSH, then authenticate GH

```
gh auth login
```

save Git creds as env var

```
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
export GITHUB_USER=sosotechnologies
```

```
echo $GITHUB_USER
echo $GITHUB_TOKEN
```

### Repo 1. 

```
mkdir -p flux-production/apps
cd flux-production
git init
gh repo create

echo "commit Readme" | tee README.md

git add . && \
git commit -m "added prod folder" && \
git push --set-upstream origin master
```

### Repo 2
```
mkdir -p flux-staging/apps
cd flux-staging

git init
gh repo create

[Select: Push an existing local repository to GitHub]

echo "commit Readme" | tee README.md

git add . && \
git commit -m "added stag folder" && \
git push --set-upstream origin master
```


```
kubectl create ns production 
kubectl create ns staging 
```

### Repo 3
Remember the path defined here [apps] is the app folder I created in staging and production repos, bootstrap will:
- install flux
- Create a github repo
- create the deploy keys
...

```
flux bootstrap github --owner sosotechnologies --repository flux-fleet --branch main  --path apps --personal true
```

See the resources that were created from the bootstrap

```
kubectl get po -n flux-system
kubectl get svc -n flux-system
kubectl get secrets -n flux-system
kubectl get cm -n flux-system
```

#### Cd into flux-fleet directory and create the below resources

- staging source and Kustomization
- production source and Kustomization
- devops-toolkit

```
git clone git@github.com:sosotechnologies/flux-fleet.git
cd flux-fleet
```

So far my flux-weekend folder looks like so:

.
├── flux-fleet
│   └── apps
│       └── flux-system
│           ├── gotk-components.yaml
│           ├── gotk-sync.yaml
│           └── kustomization.yaml
├── flux-production
│   ├── apps
│   └── README.md
└── flux-staging
    ├── apps
    └── README.md

***Create Kustomization and Source in the flux-fleet/ folder***
- Create source and Kustomize for staging

```
flux create source git staging --url https://github.com/sosotechnologies/flux-staging --branch master --interval 30s --export | tee apps/staging.yaml
```

- Kustomize staging to same file: apps/staging.yaml

```
flux create kustomization staging --source staging --path "./" --prune true --interval 10m --export | tee -a apps/staging.yaml
```

***Create source and Kustomize for production***

```
flux create source git production --url https://github.com/sosotechnologies/flux-production --branch master --interval 30s --export | tee apps/production.yaml
```

Kustomize production to same file: apps/production.yaml

```
flux create kustomization production --source production --path "./" --prune true --interval 10m --export | tee -a apps/production.yaml
```

### repo 4
Create devops-toolkit in thesame in the flux-fleet/ folder

```
flux create source git devops-toolkit --url=https://github.com/sosotechnologies/devops-toolkit --branch=master --interval=30s --export | tee apps/devops-toolkit.yaml
```

```
git add . && \
git commit -m "added staging folder, production folder and devops-toolkit" && \
git push --set-upstream origin main
```

***Now my flux-weekend folder looks like***

.
├── flux-fleet
│   └── apps
│       ├── devops-toolkit.yaml
│       ├── flux-system
│       │   ├── gotk-components.yaml
│       │   ├── gotk-sync.yaml
│       │   └── kustomization.yaml
│       ├── production.yaml
│       └── staging.yaml
├── flux-production
│   ├── apps
│   └── README.md
└── flux-staging
    ├── apps
    └── README.md

```
watch flux get sources git
flux get kustomizations
```

***setup is done! NEXT: Create Helm Releases***

**Staging Release**

```
cd flux-staging
```

Copy this command and fun as is:

```
echo "image:
    tag: 2.9.9
ingress:
    host: staging.devops-toolkit.$INGRESS_HOST.nip.io" \
    | tee values.yaml
```

```
flux create helmrelease devops-toolkit-staging --source GitRepository/devops-toolkit --values values.yaml --chart "helm" --target-namespace staging --interval 30s --export | tee apps/devops-toolkit.yaml
```

```
rm values.yaml
```

```
git add . && \
git commit -m "added staging helm release" && \
git push --set-upstream origin master
```

```
watch flux get helmreleases
kubectl --namespace staging get pods
```

***NOTE:*** You can change the image tag in the staging: devops-toolkit.yaml
    From:  tag: 2.9.9 --> tag: 2.9.17 
And [commit and push to Git] and flux will automatically detect and deploy.


**Production Release**

```
cd ..
cd flux-production
```

Copy this command and fun as is:

```
echo "image:
    tag: 2.9.17
ingress:
    host: production.devops-toolkit.$INGRESS_HOST.nip.io" \
    | tee values.yaml
```

```
flux create helmrelease devops-toolkit-production --source GitRepository/devops-toolkit --values values.yaml --chart "helm" --target-namespace production --interval 30s --export | tee apps/devops-toolkit.yaml
```

```
rm values.yaml
```

```
git add . && \
git commit -m "added production helm release" && \
git push --set-upstream origin master
```

```
flux get helmreleases
watch kubectl --namespace production get pods
```

Final Tree

.
├── flux-fleet
│   └── apps
│       ├── devops-toolkit.yaml
│       ├── flux-system
│       │   ├── gotk-components.yaml
│       │   ├── gotk-sync.yaml
│       │   └── kustomization.yaml
│       ├── production.yaml
│       └── staging.yaml
├── flux-production
│   ├── apps
│   │   └── devops-toolkit.yaml
│   └── README.md
└── flux-staging
    ├── apps
    │   └── devops-toolkit.yaml
    └── README.md

**IT'S ALL FOLKS!**

NEXT TASK

Configure ECR/OICD-IRSA/GIT tagging for CD deployment

```
aws ecr list-images --repository=soso-repository
```

```
kubectl create job --from=cronjob/ecr-credentials-sync -n flux-system ecr-credentials-sync-init --dry-run=client -o yaml > job.yaml
```

