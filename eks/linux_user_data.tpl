MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -ex
/etc/eks/bootstrap.sh ${cluster_name} \
  --container-runtime containerd

yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service

--==MYBOUNDARY==--

