#!/bin/bash
sudo yum update -y
export RELEASE=1.22.0
curl -LO https://storage.googleapis.com/kubernetes-release/release/v$RELEASE/bin/linux/amd64/kubectl
chmod +x ./kubectl 
sudo mv ./kubectl /usr/local/bin/kubectl