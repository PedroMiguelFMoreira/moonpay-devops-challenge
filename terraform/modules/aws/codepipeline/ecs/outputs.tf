output "codebuild_projects_name" {
  value = [
    for project in aws_codebuild_project.codebuild_project : project.name
  ]
}
