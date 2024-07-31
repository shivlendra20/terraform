variable "aws_access_key" {
  type    = string
}

variable "aws_secret_key" {
  type    = string
}

variable "environment_name" {
  type    = string
  description = "define to which environment to create the resources:   dev/uat/prod"
  default = "dev"
}

variable "service_base_name" {
  type    = string
  description = "define base name for service"
}


variable "ecs_task_definition_cpu" {
    description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
    default = "1024"
}

variable "ecs_task_definition_memory" {
    description = "Fargate instance memory to provision (in MiB)"
    default = "3072"
}
