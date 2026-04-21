# LanceDB_setup/read_test_airport.py
import lancedb
import time

DB_PATH = "/mnt/lustre/lancedb"

db    = lancedb.connect(DB_PATH)
table = db.open_table("airports")

df    = table.to_pandas()
total = len(df)

match = df[df["name"] == "TEST-HEAVY-NODE-AIRPORT"]

print(f"[LIGHT] Read at {time.strftime('%H:%M:%S')}")
print(f"[LIGHT] Total rows visible: {total}")

if not match.empty:
    print(f"[LIGHT] ✅ Consistency CHECK PASSED — test airport found:")
    print(match[["airport_id","name","city","country","iata","lat","lon"]].to_string(index=False))
else:
    print(f"[LIGHT] ❌ Consistency CHECK FAILED — test airport NOT found")