# Generate a cluster UUID
KAFKA_CLUSTER_ID=$(/opt/kafka/bin/kafka-storage.sh random-uuid)

# Format the storage directory
/opt/kafka/bin/kafka-storage.sh format \
  -t $KAFKA_CLUSTER_ID \
  -c /opt/kafka/config/kraft/server.properties