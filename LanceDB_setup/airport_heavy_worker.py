from kafka import KafkaConsumer, KafkaProducer
import json, time
import lancedb
import pyarrow.compute as pc  # still imported but not strictly needed now

KAFKA_BROKER = "172.31.40.22:9092"
REQ_TOPIC    = "airport-queries"
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

print("[AIRPORT-WORKER] ready, waiting for queries...")

for msg in consumer:
    req   = msg.value
    qid   = req.get("id")
    qtype = req.get("type")
    p     = req.get("payload", {})

    try:
        # Load a reasonable slice of the table
        df = table.to_pandas()  # or table.to_pandas(limit=5000) if large

        if qtype == "by_country":
            country = p["country"]
            df = df[df["country"] == country].head(10)

        elif qtype == "by_city":
            city = p["city"]
            df = df[df["city"] == city].head(10)

        elif qtype == "by_bbox":
            lat_min = p["lat_min"]
            lat_max = p["lat_max"]
            lon_min = p["lon_min"]
            lon_max = p["lon_max"]
            df = df[
                (df["lat"] >= lat_min) &
                (df["lat"] <= lat_max) &
                (df["lon"] >= lon_min) &
                (df["lon"] <= lon_max)
            ].head(20)

        else:
            df = df.head(5)

        rows = df.to_dict(orient="records")
        res  = {"id": qid, "status": "ok", "type": qtype, "rows": rows, "ts": time.time()}

    except Exception as e:
        res = {"id": qid, "status": "error", "error": str(e), "ts": time.time()}

    producer.send(RES_TOPIC, value=res)
    producer.flush()
    print(f"[AIRPORT-WORKER] answered qid={qid[:8]} type={qtype} rows={len(res.get('rows', []))}")