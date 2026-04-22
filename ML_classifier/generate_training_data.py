# ML_classifier/generate_training_data.py
import json, csv

# Manually labeled examples
# Features: query_type (encoded), payload_size, has_country, has_city, has_bbox
# Label: 0=light, 1=heavy

samples = [
    # LIGHT queries (specific, narrow)
    {"query_type": "by_city",    "has_country": 0, "has_city": 1, "has_bbox": 0, "payload_keys": 1, "label": 0},
    {"query_type": "by_city",    "has_country": 0, "has_city": 1, "has_bbox": 0, "payload_keys": 1, "label": 0},
    {"query_type": "by_city",    "has_country": 0, "has_city": 1, "has_bbox": 0, "payload_keys": 1, "label": 0},
    {"query_type": "by_city",    "has_country": 0, "has_city": 1, "has_bbox": 0, "payload_keys": 1, "label": 0},
    {"query_type": "by_city",    "has_country": 0, "has_city": 1, "has_bbox": 0, "payload_keys": 1, "label": 0},

    # HEAVY queries (broad, full scans)
    {"query_type": "by_country", "has_country": 1, "has_city": 0, "has_bbox": 0, "payload_keys": 1, "label": 1},
    {"query_type": "by_country", "has_country": 1, "has_city": 0, "has_bbox": 0, "payload_keys": 1, "label": 1},
    {"query_type": "by_country", "has_country": 1, "has_city": 0, "has_bbox": 0, "payload_keys": 1, "label": 1},
    {"query_type": "by_bbox",    "has_country": 0, "has_city": 0, "has_bbox": 1, "payload_keys": 4, "label": 1},
    {"query_type": "by_bbox",    "has_country": 0, "has_city": 0, "has_bbox": 1, "payload_keys": 4, "label": 1},
    {"query_type": "by_bbox",    "has_country": 0, "has_city": 0, "has_bbox": 1, "payload_keys": 4, "label": 1},
    {"query_type": "default",    "has_country": 0, "has_city": 0, "has_bbox": 0, "payload_keys": 0, "label": 1},
]

# Encode query_type as int
type_map = {"by_city": 0, "by_country": 1, "by_bbox": 2, "default": 3}
for s in samples:
    s["query_type_enc"] = type_map[s["query_type"]]

# Save as CSV
with open("ML_classifier/training_data.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["query_type_enc","has_country","has_city","has_bbox","payload_keys","label"])
    writer.writeheader()
    for s in samples:
        writer.writerow({k: s[k] for k in ["query_type_enc","has_country","has_city","has_bbox","payload_keys","label"]})

print("Training data saved to ML_classifier/training_data.csv")