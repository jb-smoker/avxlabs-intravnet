module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "useg_${random_string.name.result}"
  create_private_key = fileexists("~/.ssh/id_rsa.pub") ? false : true
  public_key         = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : null
}

module "vdi_key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "intravnet_vdi_${random_string.name.result}"
  create_private_key = true
}

resource "aws_security_group" "allow_all_private_db" {
  name        = "allow_all_private_db"
  description = "allow_all_private_db"
  vpc_id      = module.spoke_aws_db.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_private"
  }
}

resource "aws_security_group" "allow_all_private_web" {
  name        = "allow_all_private_web"
  description = "allow_all_private_web"
  vpc_id      = module.spoke_aws_web.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_private"
  }
}

resource "aws_security_group" "allow_all_private_dmz" {
  name        = "allow_all_private_dmz"
  description = "allow_all_private_dmz"
  vpc_id      = module.spoke_aws_ingress.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_private_dmz"
  }
}

resource "aws_security_group" "allow_web_ssh_public" {
  name        = "allow_web_ssh_public"
  description = "allow_web_ssh_public"
  vpc_id      = module.spoke_aws_ingress.vpc.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_private"
  }
}

resource "aws_db_subnet_group" "db_vpc" {
  name       = "wp-useg-db"
  subnet_ids = [module.spoke_aws_db.vpc.private_subnets[0].subnet_id, module.spoke_aws_db.vpc.private_subnets[1].subnet_id]
  tags = {
    Name = "My DB subnet group"
  }
}


resource "aws_db_instance" "wp_mysql" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  db_name                = "wordpress"
  vpc_security_group_ids = [aws_security_group.allow_all_private_db.id]
  db_subnet_group_name   = aws_db_subnet_group.db_vpc.name
  username               = var.database_admin_login
  password               = var.database_admin_password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "aws_ami" "guacamole" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["679593333241"]
  }

  filter {
    name   = "name"
    values = ["bitnami-guacamole-*-x86_64-hvm-ebs*"]
  }
}


module "ec2_instance_wp_web" {
  count  = var.number_of_web_servers
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "aws-wp-be-${count.index}"

  ami                    = data.aws_ami.amazon-linux-2.image_id
  instance_type          = "t2.micro"
  key_name               = module.key_pair.key_pair_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_all_private_web.id]
  subnet_id              = module.spoke_aws_web.vpc.private_subnets[0].subnet_id
  user_data = templatefile("${path.module}/aws_web.tftpl", {
    db_fqdn     = "${aws_db_instance.wp_mysql.address}",
    db_user     = "${var.database_admin_login}",
    db_password = "${var.database_admin_password}",
    username    = "${var.admin_username}",
    password    = "${var.admin_password}",
    wp_alb_url  = "${aws_lb.aws_wordpress_prod.dns_name}"
  })

  tags = {
    Cloud       = "AWS"
    Application = "wordpress"
    Role        = "Web"
    OS          = "Linux"
    Environment = count.index % 2 == 0 ? "Prod" : "Dev"
  }
  depends_on = [
    aviatrix_firewall_instance_association.egress_fqdn_association_1
  ]
}


# module "ec2_instance_guacamole" {
#   source = "terraform-aws-modules/ec2-instance/aws"

#   name = "guacamole-01"

#   ami                         = data.aws_ami.guacamole.image_id
#   instance_type               = "t3a.small"
#   key_name                    = module.key_pair.key_pair_name
#   monitoring                  = true
#   vpc_security_group_ids      = [aws_security_group.allow_web_ssh_public.id]
#   subnet_id                   = module.spoke_aws_ingress.vpc.public_subnets[0].subnet_id
#   associate_public_ip_address = true

#   tags = {
#     Cloud       = "AWS"
#     Application = "Bastion"
#     Environment = "Prod"
#   }
# }

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["099720109477"] # Canonical
# }

# resource "ssh_resource" "guac_password" {
#   # The default behaviour is to run file blocks and commands at create time
#   # You can also specify 'destroy' to run the commands at destroy time
#   when = "create"

#   host        = module.ec2_instance_guacamole.public_dns
#   user        = "bitnami"
#   private_key = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa")}" : module.key_pair.private_key_pem

#   file {
#     content     = "sudo cat /home/bitnami/bitnami_credentials"
#     destination = "/tmp/get_creds.sh"
#     permissions = "0700"
#   }

#   timeout = "15m"

#   commands = [
#     "/tmp/get_creds.sh"
#   ]
#   depends_on = [
#     aviatrix_gateway.aws_egress_fqdn
#   ]
# }

resource "aws_instance" "guacamole" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  key_name                    = module.key_pair.key_pair_name
  subnet_id                   = module.spoke_aws_ingress.vpc.public_subnets[0].subnet_id
  associate_public_ip_address = true ##
  vpc_security_group_ids      = [aws_security_group.allow_web_ssh_public.id]
  user_data = templatefile("${path.module}/guacamole.tftpl", {
    username     = var.admin_username
    password     = var.admin_password
    azure_web_1  = azurerm_network_interface.wp-web-interfaces[0].private_ip_address
    azure_web_2  = azurerm_network_interface.wp-web-interfaces[1].private_ip_address
    aws_web_1    = module.ec2_instance_wp_web[0].private_ip
    aws_web_2    = module.ec2_instance_wp_web[1].private_ip
    vdi_hostname = module.ec2_instance_windows_vdi.private_ip
    vdi_password = rsadecrypt(module.ec2_instance_windows_vdi.password_data, module.vdi_key_pair.private_key_pem)
    pod_id       = ""
  })
  tags = {
    Name        = "guacamole-01"
    Cloud       = "AWS"
    Application = "Bastion"
    Environment = "Prod"
  }
  provisioner "file" {
    source      = "${path.module}/cert.crt"
    destination = "/tmp/cert.crt"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("~/.ssh/id_rsa")
      timeout     = "1m"
      agent       = "false"
    }
  }
  provisioner "file" {
    source      = "${path.module}/cert.key"
    destination = "/tmp/cert.key"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("~/.ssh/id_rsa")
      timeout     = "1m"
      agent       = "false"
    }
  }
}

module "ec2_instance_windows_vdi" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "windows-jump-01"

  ami                         = data.aws_ami.windows.image_id
  instance_type               = "t3a.small"
  key_name                    = module.vdi_key_pair.key_pair_name
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.allow_all_private_dmz.id]
  subnet_id                   = module.spoke_aws_ingress.vpc.private_subnets[0].subnet_id
  associate_public_ip_address = false
  user_data                   = file("${path.module}/aws_vdi.txt")
  get_password_data           = true

  tags = {
    Cloud       = "AWS"
    Application = "VDI"
    OS          = "Windows"
    Environment = "Prod"
  }
  depends_on = [
    aviatrix_firewall_instance_association.egress_fqdn_association_1
  ]
}

resource "aws_lb" "aws_wordpress_prod" {
  name               = "wordpress-prod"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web_ssh_public.id]
  subnets            = [for subnet in module.spoke_aws_ingress.vpc.public_subnets : subnet.subnet_id]

  tags = {
    Environment = "Prod"
    Application = "Wordpress"
    Role        = "Load Balancer"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.aws_wordpress_prod.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_wordpress_prod.arn
  }
}

resource "aws_lb_target_group" "aws_wordpress_prod" {
  name        = "wordpress-prod"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.spoke_aws_ingress.vpc.vpc_id
  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200,302" # has to be HTTP 200 or fails
  }
  tags = {
    Environment = "Prod"
    Application = "Wordpress"
  }
}

resource "aws_lb_target_group_attachment" "aws_wordpress_prod" {
  count             = var.number_of_web_servers
  target_group_arn  = aws_lb_target_group.aws_wordpress_prod.arn
  target_id         = module.ec2_instance_wp_web[count.index].private_ip
  port              = 80
  availability_zone = "all"
}
