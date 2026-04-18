sudo yum update
sudo yum install -y python3 python3-pip
pip install "lancedb>=0.8.0" "numpy>=1.26" "pydantic>=2"


sudo dnf install -y python39 python39-pip   # or yum depending on your distro
python3.9 -m pip install --upgrade pip
python3.9 -m pip install "lancedb" "numpy>=1.26" "pydantic>=2"