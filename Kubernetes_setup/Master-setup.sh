sudo hostnamectl set-hostname node-master

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san 3.15.169.28 --disable traefik" sh - # to download and install k3s on the master node, replace the --tls-san value with the public IP of your master node

