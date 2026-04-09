from lance_schema import get_table

table = get_table()
print("Light node sees rows:", table.count_rows())

df = table.to_pandas()         # load all rows (fine for small tests)
df = df.head(5)                # keep first 5 rows

for rec in df.itertuples():
    print(rec.id, rec.label, rec.ts)