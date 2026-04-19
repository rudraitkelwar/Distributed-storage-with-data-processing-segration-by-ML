from kafka import KafkaProducer, KafkaConsumer
import json, uuid

KAFKA_BROKER = "172.31.40.22:9092"
REQ_TOPIC    = "airport-queries"
RES_TOPIC    = "airport-results"

producer = KafkaProducer(
    bootstrap_servers=KAFKA_BROKER,
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    acks="all",
)

consumer = KafkaConsumer(
    RES_TOPIC,
    bootstrap_servers=KAFKA_BROKER,
    group_id=None,
    auto_offset_reset="latest",   # only wait for NEW results
    enable_auto_commit=False,
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
)

def query(req_type, payload):
    qid = str(uuid.uuid4())
    req = {"id": qid, "type": req_type, "payload": payload}
    producer.send(REQ_TOPIC, value=req)
    producer.flush()
    print(f"\n[CLIENT] sent query id={qid[:8]} type={req_type} payload={payload}")

    print("[CLIENT] waiting for result...")
    for msg in consumer:
        res = msg.value
        if res.get("id") == qid:
            status = res.get("status")
            rows   = res.get("rows", [])
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
    # Query 1: all airports in a country
    query("by_country", {"country": "United States"})

    # Query 2: airports in a specific city
    query("by_city", {"city": "New York"})

    # Query 3: airports within a lat/lon bounding box
    query("by_bbox", {"lat_min": 40.0, "lat_max": 42.0, "lon_min": -75.0, "lon_max": -72.0})