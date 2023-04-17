provider "aws" {

region = "us-east-1"

access_key = "ASIAQT5S2553R2IAQWMW"

secret_key = "UkIcGAxBcrSVgQ6NZlQzSlxhs6+psDeqBuYnbEOX"

token = "FwoGZXIvYXdzEFsaDG43+I82RRj5n3+xLiLNAdeu/ybMiu8v73mD6uXcX8IHCeZxkQZhOLOu6Upaxm9zru692nYJbdi7aGOa3IF0S16Xw5wTuC70soJpOKOxvYqhXOBqC05p43+jZGtLPNeW0M+XvTSsKS8xNq4jWIYvIOEhesWmC4gf5W4S8a7b3IJtfjk2YbJtgymeeb5GQlOIcBofnj6tvLSvRaEjGqxTnep91dc5mBGz88wRP3YVZBqD52x9xABJJn4pI8K/Ed59tRBolINiXuxQojYV8qtmEppfSoMi6SquC8G8iB4osqT0oQYyLTebrVwJ1tlndlGK8hl1DJsAuYxNPqhO2nYElMTQM8xKLvpsdkQgD/zx+NASaQ=="

}




resource "aws_launch_configuration" "Clim-DM" {

image_id = "ami-05adf8b06ab95608e"

instance_type = "t3.micro"

security_groups = [aws_security_group.Clim-DM.id]

user_data = data.template_file.user_data.rendered

}




resource "aws_security_group" "Clim-DM" {

name_prefix = "Clim-DM"

vpc_id = aws_vpc.default.id

}




resource "aws_autoscaling_group" "Clim-DM" {

desired_capacity = 1

launch_configuration = aws_launch_configuration.Clim-DM.id

max_size = 5

min_size = 1

name = "Clim-DM-asg"

target_group_arns = [aws_lb_target_group.Clim-DM.arn]

vpc_zone_identifier = aws_subnet.public.*.id

}




data "template_file" "user_data" {

template = file("userdata.sh")

}




resource "aws_internet_gateway" "Clim-DM" {
  vpc_id = aws_vpc.default.id
}




resource "aws_route_table" "Clim-DM" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Clim-DM.id
  }
}




resource "aws_route_table_association" "Clim-DM" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.Clim-DM.id
}




resource "aws_route_table_association" "Clim-DM2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.Clim-DM.id
}




resource "aws_vpc" "default" {

cidr_block = "10.0.0.0/16"

enable_dns_hostnames = true

}




resource "aws_subnet" "public" {

cidr_block = "10.0.4.0/24"

map_public_ip_on_launch = true

vpc_id = aws_vpc.default.id

availability_zone = "us-east-1a"

}




resource "aws_subnet" "public2" {

cidr_block = "10.0.5.0/24"

map_public_ip_on_launch = true

vpc_id = aws_vpc.default.id

availability_zone = "us-east-1b"

}




resource "aws_lb" "Clim-DM" {

name = "Clim-DM-lb"

internal = false

load_balancer_type = "application"

security_groups = [aws_security_group.Clim-DM.id]

subnets = [aws_subnet.public.id, aws_subnet.public2.id]

}




resource "aws_lb_target_group" "Clim-DM" {

name = "Clim-DM-target-group"

port = 80

protocol = "HTTP"

vpc_id = aws_vpc.default.id

}




resource "aws_lb_listener" "Clim-DM" {

load_balancer_arn = aws_lb.Clim-DM.arn

port = "80"

protocol = "HTTP"

default_action {

target_group_arn = aws_lb_target_group.Clim-DM.arn

type = "forward"

}

}

