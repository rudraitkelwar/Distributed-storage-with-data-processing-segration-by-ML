from lance_schema import get_table
import numpy as np
import time

table = get_table()
print("Opened table with", table.count_rows(), "rows")

# Insert a test row
row = {
    "id": "heavy-test-1",
    "text": "SELECT ... heavy test",
    "embedding": np.random.randn(8).astype("float32").tolist(),
    "label": "heavy",
    "ts": time.time(),
}

table.add([row])
print("After insert, rows:", table.count_rows())