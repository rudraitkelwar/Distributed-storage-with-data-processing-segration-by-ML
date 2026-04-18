import lancedb

DB_URI = "/mnt/lustre/lancedb"    # must match what you used on node-heavy

db = lancedb.connect(DB_URI)

print("Tables:", db.table_names())

airports = db.open_table("airports")
print("Airports rows:", airports.count_rows())

# show a few rows
print(airports.head().to_pandas())