sudo hostnamectl set-hostname node-heavy # for node with heavy resources 

sudo hostnamectl set-hostname node-light # for node with light resources


curl -sfL https://get.k3s.io | K3S_URL=https://172.31.40.22:6443 K3S_TOKEN=K1045c87b42f90e8b9cf44686266a892c9919bc0ae664015e9b6981eb4ac21cc387::server:1a562232d1ddf69293dd8b9fd5430021 sh - 
