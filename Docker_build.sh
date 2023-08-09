#!/bin/bash

# launch an ec2 instance. open port 80 and port 22(just a reference, i use Azure for this)

# install and configure docker on the ec2 instance
sudo apt update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo systemctl enable docker


# login to your docker hub account, my password is hidden in my local computer
cat ~/my_password.txt | sudo docker login --vietth2001 --password-stdin

# start the container and run the nginx image 

sudo docker run --name mynginx1 -p 80:80 -d nginx

# referances
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-container-image.html
# https://docs.docker.com/get-started/02_our_app/
# https://docs.docker.com/engine/reference/commandline/login/#provide-a-password-using-stdin