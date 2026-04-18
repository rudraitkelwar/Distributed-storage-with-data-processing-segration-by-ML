import pandas as pd
import lancedb

DB_URI = "/mnt/lustre/lancedb"

db = lancedb.connect(DB_URI)

# 1) Define the correct column names for airports-extended.dat
cols = [
    "id",
    "name",
    "city",
    "country",
    "iata",
    "icao",
    "latitude",
    "longitude",
    "altitude",
    "tz_offset",
    "dst",
    "tz_name",
    "type",
    "source",
]

# 2) Read the file with NO header, using our column names
df = pd.read_csv(
    "data/airports-extended.dat",  # or the correct path to your file
    header=None,
    names=cols,
)

print("Columns:", df.columns.tolist())
print("Row count:", len(df))

# 3) Keep and rename a subset of useful columns
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

table_name = "airports"

if table_name in db.table_names():
    tbl = db.open_table(table_name)
    tbl.add(df)
else:
    tbl = db.create_table(table_name, data=df)

print("LanceDB table:", table_name, "rows:", tbl.count_rows())
print(tbl.head().to_pandas())