from kafka import KafkaConsumer
import json, time
from lance_schema import get_table

KAFKA_BROKER = "172.31.40.22:9092"
TOPIC        = "light-queries"

consumer = KafkaConsumer(
    TOPIC,
    bootstrap_servers=KAFKA_BROKER,
    group_id="light-workers",
    auto_offset_reset="earliest",
    enable_auto_commit=True,
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
)

table = get_table()
print("[LIGHT] Consumer ready, waiting for messages...")

for msg in consumer:
    env = msg.value
    t0  = time.perf_counter()
    table.add([{
        "id":        env["id"],
        "text":      env["text"],
        "embedding": env["embedding"],
        "label":     env["label"],
        "ts":        env["ts"],
    }])
    dt = (time.perf_counter() - t0) * 1000
    print(f"[LIGHT] stored id={env['id'][:8]} label={env['label']} {dt:.1f}ms")