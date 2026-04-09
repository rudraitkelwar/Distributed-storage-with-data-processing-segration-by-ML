from lance_schema import get_table

table = get_table()
print("Light node sees rows:", table.count_rows())
for rec in table.to_pandas(limit=5).itertuples():
    print(rec.id, rec.label, rec.ts)