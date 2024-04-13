output "codepipeline_github_connection_arn" {
  value = aws_codestarconnections_connection.codepipeline_github_connection.arn
}

output "codepipeline_codepipeline_bucket_region" {
  value = aws_s3_bucket.codepipeline_bucket_region
}

output "codepipeline_codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}

output "codepipeline_codepipeline_role_id" {
  value = aws_iam_role.codepipeline_role.id
}

output "codepipeline_codedeploy_ecs_role_arn" {
  value = aws_iam_role.codedeploy_ecs_role.arn
}

output "codepipeline_codebuild_security_group_id" {
  value = module.codebuild_security_group.security_group_id
}

output "codepipeline_codebuild_security_group_name" {
  value = module.codebuild_security_group.security_group_name
}
