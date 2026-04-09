import lancedb
import numpy as np

LANCE_ROOT = "/mnt/lustre/lancedb"
TABLE_NAME = "queries"

db = lancedb.connect(LANCE_ROOT)

if TABLE_NAME in db.table_names():
    print("Table already exists:", TABLE_NAME)
    exit(0)

# Create an example schema (id, text, embedding, label, ts)
data = [{
    "id": "bootstrap",
    "text": "bootstrap",
    "embedding": np.zeros(8, dtype=np.float32).tolist(),  # 8-dim demo
    "label": "light",
    "ts": 0.0,
}]

tbl = db.create_table(TABLE_NAME, data=data)
tbl.delete("id == 'bootstrap'")  # remove bootstrap row
print("Created LanceDB table:", TABLE_NAME)