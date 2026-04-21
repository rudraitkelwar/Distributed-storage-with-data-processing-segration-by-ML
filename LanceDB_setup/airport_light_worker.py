# LanceDB_setup/airport_worker_light.py (on node-light)
from kafka import KafkaConsumer, KafkaProducer
import json, time
import lancedb

KAFKA_BROKER = "172.31.40.22:9092"
REQ_TOPIC    = "airport-queries-light"
RES_TOPIC    = "airport-results"

db    = lancedb.connect("/mnt/lustre/lancedb")
table = db.open_table("airports")

consumer = KafkaConsumer(
    REQ_TOPIC,
    bootstrap_servers=KAFKA_BROKER,
    group_id=None,
    auto_offset_reset="latest",
    enable_auto_commit=False,
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
)

producer = KafkaProducer(
    bootstrap_servers=KAFKA_BROKER,
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    acks="all",
)

print("[AIRPORT-WORKER-LIGHT] ready, waiting for queries...")

for msg in consumer:
    req   = msg.value
    qid   = req.get("id")
    qtype = req.get("type")
    p     = req.get("payload", {})

    try:
        df = table.to_pandas()

        # You can choose to support different query types on light,
        # or maybe only a subset (e.g., by_country) – your choice.
        if qtype == "by_country":
            country = p["country"]
            df = df[df["country"] == country].head(5)   # maybe smaller sample

        elif qtype == "by_city":
            city = p["city"]
            df = df[df["city"] == city].head(5)

        else:
            df = df.head(5)

        rows = df.to_dict(orient="records")
        res  = {"id": qid, "status": "ok", "type": qtype, "rows": rows, "ts": time.time(), "node": "light"}

    except Exception as e:
        res = {"id": qid, "status": "error", "error": str(e), "ts": time.time(), "node": "light"}

    producer.send(RES_TOPIC, value=res)
    producer.flush()
    print(f"[AIRPORT-WORKER-LIGHT] answered qid={qid[:8]} type={qtype} rows={len(res.get('rows', []))}")