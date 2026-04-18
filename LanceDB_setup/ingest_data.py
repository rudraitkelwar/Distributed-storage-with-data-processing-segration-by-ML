import pandas as pd
import lancedb

# lance db location
DB_URI = "/mnt/lustre/lancedb"   # <-- adjust if needed

db = lancedb.connect(DB_URI)

# Load the OpenFlights airports-extended file ,   It is comma-separated and includes a header row.
df = pd.read_csv(f"data/airports-extended.dat")

print("Columns:", df.columns.tolist())
print("Row count:", len(df))

# Optional: keep only a few useful columns and rename them
keep_cols = {
    "id": "airport_id",
    "name": "name",
    "city": "city",
    "country": "country",
    "iata": "iata",
    "icao": "icao",
    "latitude": "lat",
    "longitude": "lon",
}
df = df[list(keep_cols.keys())].rename(columns=keep_cols)

# 3) Create or append to a LanceDB table
table_name = "airports"

if table_name in db.table_names():
    tbl = db.open_table(table_name)
    tbl.add(df)
else:
    tbl = db.create_table(table_name, data=df)

print("LanceDB table:", table_name, "rows:", tbl.count_rows())
print(tbl.head().to_pandas())