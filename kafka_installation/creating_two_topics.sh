SERVER6_IP=172.31.40.22   # change this

/opt/kafka/bin/kafka-topics.sh --create \
  --topic heavy-queries \
  --partitions 3 --replication-factor 1 \
  --bootstrap-server ${SERVER6_IP}:9092

/opt/kafka/bin/kafka-topics.sh --create \
  --topic light-queries \
  --partitions 3 --replication-factor 1 \
  --bootstrap-server ${SERVER6_IP}:9092


  #Verify the topics 

  /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server ${SERVER6_IP}:9092

# message verification

#send
  echo "test-message" | /opt/kafka/bin/kafka-console-producer.sh \
  --topic light-queries \
  --bootstrap-server ${SERVER6_IP}:9092

#consume message  
  /opt/kafka/bin/kafka-console-consumer.sh \
  --topic light-queries \
  --from-beginning \
  --bootstrap-server ${SERVER6_IP}:9092