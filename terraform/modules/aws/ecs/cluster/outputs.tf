output "cluster" {
  value = {
    id   = aws_ecs_cluster.ecs_cluster.id
    name = aws_ecs_cluster.ecs_cluster.name
  }
}
