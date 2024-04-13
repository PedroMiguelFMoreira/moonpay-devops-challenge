resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
  setting {
    name  = "containerInsights"
    value = var.container_insights
  }
  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = var.capacity_providers
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = var.capacity_providers[0]
  }
}
