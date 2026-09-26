output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.web_server.public_ip}"
}