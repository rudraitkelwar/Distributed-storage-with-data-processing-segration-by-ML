import lancedb

LANCE_ROOT = "/mnt/lustre/lancedb"
TABLE_NAME = "queries"

def get_table():
    db = lancedb.connect(LANCE_ROOT)
    return db.open_table(TABLE_NAME)