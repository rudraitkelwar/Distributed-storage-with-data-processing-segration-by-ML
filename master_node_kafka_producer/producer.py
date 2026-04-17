from kafka import KafkaProducer
import json, time, uuid, numpy as np

KAFKA_BROKER = "172.31.40.22:9092"
HEAVY_TOPIC  = "heavy-queries"
LIGHT_TOPIC  = "light-queries"

producer = KafkaProducer(
    bootstrap_servers=KAFKA_BROKER,
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    acks="all",
)

def fake_embedding(text):
    rng = np.random.default_rng(seed=abs(hash(text)) % (2**32))
    return rng.normal(size=8).astype("float32").tolist()

def classify_query(text):
    heavy_signals = ["JOIN", "GROUP BY", "WINDOW", "PARTITION BY"]
    score = sum(1 for s in heavy_signals if s.upper() in text.upper())
    return "heavy" if score >= 1 else "light"

def send_query(text, client_id="client"):
    qid   = str(uuid.uuid4())
    label = classify_query(text)
    topic = HEAVY_TOPIC if label == "heavy" else LIGHT_TOPIC
    msg = {
        "id":        qid,
        "text":      text,
        "embedding": fake_embedding(text),
        "label":     label,
        "client_id": client_id,
        "ts":        time.time(),
    }
    producer.send(topic, value=msg).get(timeout=10)
    print(f"[PRODUCER] sent → {topic}  id={qid[:8]}  label={label}")

if __name__ == "__main__":
    send_query("SELECT * FROM users WHERE id = 1")
    send_query("SELECT u.name, COUNT(*) FROM users u JOIN orders o ON u.id = o.user_id GROUP BY u.name")
    producer.flush()
    print("[PRODUCER] done.")