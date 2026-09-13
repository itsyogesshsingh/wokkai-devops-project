variable "project_name" {
  description = "Project name"
  type        = string
  default     = "wokkai-devops-project"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}