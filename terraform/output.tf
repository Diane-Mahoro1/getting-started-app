output "server_public_ip" {
  value       = aws_instance.todo_app_server.public_ip
  description = "The public IP of your server"
}