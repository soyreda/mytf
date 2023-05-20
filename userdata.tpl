#!/bin/bash
sudo apt update -y 
echo "Hello, World + Load Balancer" > /home/ubuntu/index.html
nohup busybox httpd -f p "${var.server_port}" &
