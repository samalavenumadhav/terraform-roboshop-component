variable "commmon_tags" {
    default = {
        Name = "roboshop"
        Environment = "dev"
        Terraform = "true"
    }
}
variable "ec2_final_tags" {
    default = {
        
            Name = "functions-demo"
            Environment = "prod"
    }
}
     
variable "sg_tags" {
    default = {
        Name = "functions sg P"
    }

}
   
    
   
