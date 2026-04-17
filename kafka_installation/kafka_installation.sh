# Java
sudo yum update
sudo yum install -y openjdk-17-jdk
sudo yum install -y java-17

# Kafka
cd /opt
sudo wget https://archive.apache.org/dist/kafka/3.8.0/kafka_2.12-3.8.0.tgz
sudo tar -xzf kafka_2.12-3.8.0.tgz
sudo mv kafka_2.12-3.8.0 kafka

export SERVER6_IP=172.31.40.22