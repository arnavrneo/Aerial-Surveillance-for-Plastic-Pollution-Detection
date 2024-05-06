# # so that fargate can automatically connect instances to control plane
# # resource "aws_iam_role" "eks-fargate-profile" {
# #   name = "eks-fargate-profile"
# #   assume_role_policy = jsonencode({
# #     Statement = [{
# #       Action = "sts:AssumeRole"
# #       Effect = "Allow"
# #       Principal = {
# #         Service = "eks-fargate-pods.amazonaws.com"
# #       }
# #     }]
# #     Version = "2012-10-17"
# #   })
# # }
#
# data "aws_iam_policy_document" "kube_assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       identifiers = ["eks-fargate-pods.amazonaws.com"]
#       type        = "Service"
#     }
#   }
# }
#
# resource "aws_iam_role" "kube_iam_role" {
#   assume_role_policy = data.aws_iam_policy_document.kube_assume_role.json
#   name = var.kube_profile_role_name
# }
#
# resource "aws_iam_role_policy_attachment" "eks-fargate-profile" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
#   role       = aws_iam_role.kube_iam_role.name
# }
#
# resource "aws_eks_fargate_profile" "kube-system" {
#   cluster_name           = aws_eks_cluster.eks-cluster.name
#   fargate_profile_name   = var.fargate_default_profile_name
#   pod_execution_role_arn = aws_iam_role.kube_iam_role.arn
#
#   # These subnets must have the following resource tag:
#   # kubernetes.io/cluster/<CLUSTER_NAME>.
#   subnet_ids = [
#     aws_subnet.private-us-east-1a.id,
#     aws_subnet.private-us-east-1b.id
#   ]
#
#   selector {
#     namespace = "kube-system"
#   }
# }
#
# # custom fargate profile for the app
# resource "aws_eks_fargate_profile" "staging" {
#   cluster_name           = aws_eks_cluster.eks-cluster.name
#   fargate_profile_name   = "staging"
#   pod_execution_role_arn = aws_iam_role.kube_iam_role.arn
#
#   subnet_ids = [
#     aws_subnet.private-us-east-1a.id,
#     aws_subnet.private-us-east-1b.id
#   ]
#
#   selector {
#     namespace = var.fargate_custom_profile_namespace
#   }
# }
#
