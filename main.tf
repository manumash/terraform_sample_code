variable "awsdeploy" {
    type = "map"
    default = {
    region = "us-east-1"
    vpc = "vpc-093898004b20a7b84"
    ami = "ami-0022f774911c1d690"
    itype = "t2.micro"
    subnet = "subnet-81896c8e"
    publicip = true
    keyname = "myseckey"
    secgroupname = "deploy-Sec-Group"
  }
}

provider "aws" {
  region = lookup(var.awsdeploy, "region")
}

resource "aws_security_group" "deployment_server" {
  name = lookup(var.awsdeploy, "secgroupname")
  description = lookup(var.awsdeploy, "secgroupname")
  vpc_id = lookup(var.awsdeploy, "vpc")

  // SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = ""
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "project-iac" {
  ami = lookup(var.awsdeploy, "ami")
  instance_type = lookup(var.awsdeploy, "itype")
  subnet_id = lookup(var.awsdeploy, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsdeploy, "publicip")
  key_name = lookup(var.awsdeploy, "keyname")


  vpc_security_group_ids = [
    aws_security_group.deployment-iac-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    iops = 150
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="SERVER01"
    Environment = "Test"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.deployment-iac-sg ]
}


output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}
