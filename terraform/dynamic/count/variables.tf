variable "instances" {
    type    = list
    default = ["mongodb","redis","mysql","rabbitmq","frontend"]
}

variable "zone_id" {
    default = "Z0935977CBYGA1Y5S3YB"
}

variable "domain_name" {
    default = "samala.online"
}