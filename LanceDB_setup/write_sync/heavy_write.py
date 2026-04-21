# LanceDB_setup/write_test_airport.py
import lancedb
import pandas as pd
import time

DB_PATH = "/mnt/lustre/lancedb"

db    = lancedb.connect(DB_PATH)
table = db.open_table("airports")

# A fake test airport that is easy to find by name
test_airport = pd.DataFrame([{
    "airport_id": 99999,
    "name":       "TEST-HEAVY-NODE-AIRPORT",
    "city":       "HeavyCity",
    "country":    "TestLand",
    "iata":       "HVY",
    "icao":       "THVY",
    "lat":        0.0,
    "lon":        0.0,
}])

table.add(test_airport)

print(f"[HEAVY] Written test airport at {time.strftime('%H:%M:%S')}")
print(f"[HEAVY] Total rows now: {table.count_rows()}")