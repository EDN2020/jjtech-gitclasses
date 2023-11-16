provider "aws" {
  region = "us-east-2"
  shared_config_files = ["/Users/dedie/.aws/config"]
  shared_credentials_files = ["/Users/dedie/.aws/credentials"]
  profile = "terraform-user"
}
variable "prefix" {
  description = "servername prefix"
  default = "jjtech"
}

variable "sg_ports" {
  type        = list(number)
  description = "list of ports"
  default     = [22, 443, 80, 9000]
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_security_group" "jjtech_sg" {
  name        = "${var.prefix}-sg"
  description = "jjtech-app"

  dynamic "ingress" {
    for_each = var.sg_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    for_each = var.sg_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.jjtech_sg.id]
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
yum install wget
wget https://github.com/EDN2020/github-classes/blob/main/medlife-master-copy.zip -P ~/
yum install unzip -y 
unzip ~/medlife-master-copy.zip
rm -f /var/www/html/index.html 
cp -rf medlife-master/* /var/www/html/
EOF
https://github.com/EDN2020/github-classes/blob/main/jjtechlife.zip

    
tags = {
    Name = "${var.prefix}-server"
  }
}


#   user_data = <<EOF
# #!/bin/bash
# yum update -y
# yum install httpd -y
# service httpd start
# chkconfig httpd on
# yum install wget
# wget https://github.com/awanmbandi/aws-real-world-projects/raw/web-appplications-src-code/medlife-health-care.zip -P ~/
# yum install unzip -y 
# unzip ~/medlife-health-care.zip
# rm -f /var/www/html/index.html 
# cp -rf medlife-master/* /var/www/html/
# EO