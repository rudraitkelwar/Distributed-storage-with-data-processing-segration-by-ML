# master_node_kafka_producer/airport_client_smart.py
import sys
sys.path.insert(0, "/home/ec2-user/Distributed-storage-with-data-processing-segration-by-ML")

from ML_classifier.classifier import classify
from kafka import KafkaProducer, KafkaConsumer
import json, uuid

KAFKA_BROKER    = "172.31.40.22:9092"
REQ_TOPIC_HEAVY = "airport-queries-heavy"
REQ_TOPIC_LIGHT = "airport-queries-light"
RES_TOPIC       = "airport-results"

producer = KafkaProducer(
    bootstrap_servers=KAFKA_BROKER,
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    acks="all",
)
consumer = KafkaConsumer(
    RES_TOPIC,
    bootstrap_servers=KAFKA_BROKER,
    group_id=None,
    auto_offset_reset="latest",
    enable_auto_commit=False,
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
)

def smart_query(req_type, payload):
    # ML classifier decides heavy or light
    target    = classify(req_type, payload)
    req_topic = REQ_TOPIC_HEAVY if target == "heavy" else REQ_TOPIC_LIGHT

    qid = str(uuid.uuid4())
    req = {"id": qid, "type": req_type, "payload": payload}
    producer.send(req_topic, value=req)
    producer.flush()

    print(f"\n[SMART-CLIENT] query={req_type} payload={payload}")
    print(f"[SMART-CLIENT] ML classified → {target.upper()} node → topic={req_topic}")
    print(f"[SMART-CLIENT] sent id={qid[:8]}, waiting for result...")

    for msg in consumer:
        res = msg.value
        if res.get("id") == qid:
            rows = res.get("rows", [])
            node = res.get("node", "?")
            print(f"[SMART-CLIENT] response from node={node} rows={len(rows)}")
            if rows:
                print(f"{'ID':<6} {'IATA':<6} {'Name':<45} {'City':<20} {'Country'}")
                print("-" * 100)
                for row in rows:
                    print(f"{row.get('airport_id',''):<6} {row.get('iata',''):<6} "
                          f"{row.get('name',''):<45} {row.get('city',''):<20} "
                          f"{row.get('country','')}")
            else:
                print("[SMART-CLIENT] No matching airports found.")
            break

if __name__ == "__main__":
    smart_query("by_city",    {"city": "New York"})         # → light
    smart_query("by_country", {"country": "United States"}) # → heavy
    smart_query("by_bbox",    {"lat_min": 40.0, "lat_max": 42.0,
                                "lon_min": -75.0, "lon_max": -72.0}) # → heavy