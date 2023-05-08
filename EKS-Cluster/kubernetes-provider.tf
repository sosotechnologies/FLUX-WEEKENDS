# Datasource: 
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.id
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
}

## Added this for flux
# data "flux_install" "main" {
#   target_path    = "clusters/test"
#   network_policy = false
#   components     = ["source-controller", "helm-controller", "kustomize-controller"]
#   version        = "latest"
# }

# data "kubectl_file_documents" "apply" {
#   content = data.flux_install.main.content
# }

# data "flux_sync" "main" {
#   target_path = "clusters/test"
#   url         = "https://github.com/prprasad2020/fluxcd-medium"
#   branch      = "main"
# }

# data "kubectl_file_documents" "sync" {
#   content = data.flux_sync.main.content
# }