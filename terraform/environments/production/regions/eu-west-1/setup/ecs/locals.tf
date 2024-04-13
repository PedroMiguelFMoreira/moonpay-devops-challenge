locals {
  ordered_placement_strategy = {
    pack_cpu = [
      {
        type  = "binpack"
        field = "cpu"
      }
    ]
  }
  applications = {
    moonpay = {
      name     = "moonpay"
      projects = {
        api = {
          container_port = 3000
          alb_port       = 3000
          desired_count  = 1
          cpu            = 1024
          memory         = 1024
        }
      }
    }
  }
}
