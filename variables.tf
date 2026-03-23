variable "cidr_block" {
    type = string 
    default = "10.0.0.0/16"

}
variable "project" {
    type = string
    default = "roboshop"
}
variable "component" {
        type = string
    default = "catalogue"
}
variable "environment" {
    type = string
    default = "dev"
}
variable "vpc_tags" {}

variable "public_cidr_blocks" {
    type = string
    default = ["10.0.1.0/24","10.0.2.0/24"]
}
variable "private_cidr_blocks" {
    type = string
     default = ["10.0.10.0/24","10.0.20.0/24"]
}
variable "database_cidr_blocks" {
    type = string
    default = ["10.0.11.0/24","10.0.22.0/24"]
}

variable "eip_tags" {}