variable "instances" {
  type        = map
  default     = {
    mongodb = "t3.micro"
    redis   = "t3.micro"
    mysql   = "t3.micro"
    rabbitmq ="t3.micro"
  } 
}

variable "zone_id" {
  default = "Z0935977CBYGA1Y5S3YB"
}

variable "domain_name" {
  default = "samala.online"
}


