resource "aws_key_pair" "brandon-key" {
  key_name                  = "brandon-key"
  public_key                = file(var.PATH_TO_PUBLIC_KEY)

    # Importa a chave pública gerada no PC local
}

resource "aws_vpc" "teste-terraform"{
    cidr_block              = "10.0.0.0/16"
    instance_tenancy        = "default"
    enable_dns_support      = true
    enable_dns_hostnames    = true

    tags = {
        Name                = "TesteTerraform"
        value               = "Brandon"
    }

    # Cria a VPC onde a EC2 será criada
}

resource "aws_internet_gateway" "ig-teste-terraform" {
    vpc_id = aws_vpc.teste-terraform.id

    tags = {
        name                = "TesteTerraform"
        value               = "Brandon"
    }
  
    # Cria um internet gateway para rotear tráfego na internet
}

resource "aws_route_table" "rt-terraform-teste" {
    vpc_id = aws_vpc.teste-terraform.id
    
    route{
        cidr_block          = "0.0.0.0/0"
        gateway_id          = aws_internet_gateway.ig-teste-terraform.id
    }

    # Cria uma route table com uma rota para a internet
}

resource "aws_subnet" "teste-terraform-subnet-1" {
    vpc_id = aws_vpc.teste-terraform.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        name                = "subnetTest"
        value               = "Brandon"
    }

    # Cria uma subnet dentro da VPC e associa um ip público para todas as EC2 nela
}

resource "aws_route_table_association" "route-table-association" {
    subnet_id               = aws_subnet.teste-terraform-subnet-1.id
    route_table_id          = aws_route_table.rt-terraform-teste.id

    # Associa a route table na subnet
}

resource "aws_security_group" "terraform-test"{
    name                    = "terraform-test-brandon"
    description             = "Testando a criacao do security group via terraform"
    vpc_id                  = aws_vpc.teste-terraform.id

    ingress{
        description         = "Teste de regra via terraform - Brandon"
        from_port           = 22
        to_port             = 22
        protocol            = "tcp"
        cidr_blocks         = var.MYIP
    }

    egress {
        from_port           = 0
        to_port             = 0
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        ipv6_cidr_blocks    = ["::/0"]
    }

    # Cria um security group na VPC, abre a porta 22 para conexões TCP feitas com meu IP
}

resource "aws_instance" "example" {
    ami                     = var.AMI
    instance_type           = "t2.micro"
    key_name                = aws_key_pair.brandon-key.key_name
    subnet_id               = aws_subnet.teste-terraform-subnet-1.id
    tenancy                 = "default"
    vpc_security_group_ids  = [aws_security_group.terraform-test.id]

    # Parâmetros da EC2 que será criada
}