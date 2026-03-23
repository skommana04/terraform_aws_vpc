locals {
    common_tags = {
        project = var.project
        environment = var.environment
        component = var.component
    }
    az_names = slice(data.aws_availability_zone.example.names, 0, 2)
    comman_name_suffix = "${var.project}-${var.component}-${var.environment}" #roboshop-catalogue-dev
}