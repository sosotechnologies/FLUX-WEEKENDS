# Resource: AWS IAM Group 
resource "aws_iam_group" "sosotech-eksadmins_iam_group" {
  name = "${local.name}-soso-tech-eksadmins"
  path = "/"
}

# Resource: AWS IAM Group Policy
resource "aws_iam_group_policy" "sosotech-eksadmins_iam_group_assumerole_policy" {
  name  = "${local.name}-sosotech-eksadmins-group-policy"
  group = aws_iam_group.sosotech-eksadmins_iam_group.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Sid    = "AllowAssumeOrganizationAccountRole"
        Resource = "${aws_iam_role.eks_admin_role.arn}"
      },
    ]
  })
}


# Resource: AWS IAM User - Basic User (No AWSConsole Access)
resource "aws_iam_user" "eksadmin_user" {
  name = "${local.name}-soso-eksadmin3"
  path = "/"
  force_destroy = true
  tags = local.common_tags
}

# Resource: AWS IAM Group Membership
resource "aws_iam_group_membership" "sosotech-eksadmins" {
  name = "${local.name}-soso-tech-eksadmins-group-membership"
  users = [
    aws_iam_user.eksadmin_user.name
  ]
  group = aws_iam_group.sosotech-eksadmins_iam_group.name
}