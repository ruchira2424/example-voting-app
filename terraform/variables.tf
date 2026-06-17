variable "project_id" {
  description = "The ID of the project in which to create the resources."
  type        = string
}

variable "region"{
    description = "The region in which to create the resources."
    type        = string
    default="us-central1"
}

variable "environment" {
    description = "The environment in which to create the resources."
    type        = string
    default     = "dev"
}

variable "repository_name"{
    description = "The name of the repository to create."
    type        = string
    default     = "my-repo"
}