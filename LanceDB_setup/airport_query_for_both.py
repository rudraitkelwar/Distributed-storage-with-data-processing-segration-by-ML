# master_node_kafka_producer/airport_client_multi.py
from kafka import KafkaProducer, KafkaConsumer
import json, uuid

KAFKA_BROKER = "172.31.40.22:9092"
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

def query(target, req_type, payload):
    if target == "heavy":
        req_topic = REQ_TOPIC_HEAVY
    elif target == "light":
        req_topic = REQ_TOPIC_LIGHT
    else:
        raise ValueError("target must be 'heavy' or 'light'")

    qid = str(uuid.uuid4())
    req = {"id": qid, "type": req_type, "payload": payload}
    producer.send(req_topic, value=req)
    producer.flush()
    print(f"\n[CLIENT] sent query id={qid[:8]} target={target} type={req_type} payload={payload}")

    print("[CLIENT] waiting for result...")
    for msg in consumer:
        res = msg.value
        if res.get("id") == qid:
            status = res.get("status")
            rows   = res.get("rows", [])
            node   = res.get("node", "?")
            print(f"[CLIENT] response from node={node}")
            if status == "error":
                print(f"[CLIENT] ERROR: {res.get('error')}")
            elif not rows:
                print("[CLIENT] No matching airports found.")
            else:
                print(f"[CLIENT] {len(rows)} airport(s) found:")
                print(f"{'ID':<6} {'IATA':<6} {'ICAO':<6} {'Name':<50} {'City':<20} {'Country':<30} {'Lat':>10} {'Lon':>10}")
                print("-" * 140)
                for row in rows:
                    print(
                        f"{row.get('airport_id',''):<6} "
                        f"{row.get('iata',''):<6} "
                        f"{row.get('icao',''):<6} "
                        f"{row.get('name',''):<50} "
                        f"{row.get('city',''):<20} "
                        f"{row.get('country',''):<30} "
                        f"{row.get('lat',0):>10.4f} "
                        f"{row.get('lon',0):>10.4f}"
                    )
            break

if __name__ == "__main__":
    # Ask heavy node
    print("Query for airports in the United States (should go to HEAVY node)")
    query("heavy", "by_country", {"country": "United States"})

    # Ask light node
    print("Query for airports in New York (should go to LIGHT node)")
    query("light", "by_city", {"city": "New York"})