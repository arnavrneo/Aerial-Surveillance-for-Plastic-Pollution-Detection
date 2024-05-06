# # for eks to access AWS Services
# data "aws_iam_policy_document" "eks_assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       identifiers = ["eks.amazonaws.com"]
#       type        = "Service"
#     }
#   }
# }
#
# resource "aws_iam_role" "iam_role" {
#   assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
#   name = var.eks_role_name
# }
#
# # resource "aws_iam_role" "tf-cluster-eks" {
# #   name = "eks-cluster-${var.cluster_name}"
# #   assume_role_policy = <<POLICY
# # {
# #     "Version": "2012-10-17",
# #   "Statement": [
# #     {
# #       "Effect": "Allow",
# #       "Principal": {
# #         "Service": "eks.amazonaws.com"
# #       },
# #       "Action": "sts:AssumeRole"
# #     }
# #   ]
# # }
# # POLICY
# # }
#
# resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.iam_role.name
# }
#
# # provisioning eks
# resource "aws_eks_cluster" "eks-cluster" {
#   name     = var.cluster_name
#   role_arn = aws_iam_role.iam_role.arn
#
#   vpc_config {
#
#     endpoint_private_access = false
#     endpoint_public_access = true
#     public_access_cidrs = ["0.0.0.0/0"]
#
#     subnet_ids = [
#       aws_subnet.private-us-east-1a.id,
#       aws_subnet.private-us-east-1b.id,
#       aws_subnet.public-us-east-1a.id,
#       aws_subnet.public-us-east-1b.id
#     ]
#   }
#
#   depends_on = [aws_iam_role_policy_attachment.eks-cluster-policy]
# }
#
# # outputs
# output "endpoint" {
#   value = aws_eks_cluster.eks-cluster.endpoint
# }