# create-instance.tf
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
} 

resource "aws_key_pair" "keypair" {
    #key_name    = "TerraformAnsible-Keypair"
    key_name    = var.key_pair
    #public_key  = "joc-key-pair.pub"
    public_key  = "${file("joc-key-pair.pub")}"
}


resource "aws_instance" "instance" {
#  ami                         = var.instance_ami
  ami                         = data.aws_ami.ubuntu.id

#  availability_zone           = "${var.aws_region}${var.aws_region_az}"
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id
  #key_name                    = var.key_pair
  key_name                    = aws_key_pair.keypair.key_name
  user_data                   = "${file(var.install_script_name)}"
 
#  root_block_device {
#    delete_on_termination = true
#    encrypted             = false
#    volume_size           = var.root_device_size
#    volume_type           = var.root_device_type
#  }
 
  tags = {
    "Owner"               = var.owner
    "Name"                = "${var.owner}-instance"
    "KeepInstanceRunning" = "false"
  }
}
