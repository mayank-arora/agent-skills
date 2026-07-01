#!/usr/bin/env python3
"""Read-only query helper for a local Postgres database.

Usage:
    query_db.py "SELECT ..."

Env overrides (defaults in brackets):
    KH_HOST [localhost]  KH_PORT [5432]  KH_DBNAME [postgres]
    KH_USER (required)   KH_PASS (required)  KH_SCHEMA [public]

Requires psycopg2. If missing:
    python3 -m venv /tmp/kh-venv && /tmp/kh-venv/bin/pip install psycopg2-binary
    /tmp/kh-venv/bin/python query_db.py "SELECT ..."

Refuses obviously-mutating SQL. Connection is forced read-only.
"""
import os
import sys

try:
    import psycopg2
except ImportError:
    sys.exit(
        "psycopg2 missing. Run:\n"
        "  python3 -m venv /tmp/kh-venv && /tmp/kh-venv/bin/pip install psycopg2-binary\n"
        "then run this with /tmp/kh-venv/bin/python"
    )

if len(sys.argv) < 2:
    sys.exit('usage: query_db.py "SQL"')

sql = sys.argv[1]
lowered = " " + sql.lower().replace("\n", " ") + " "
banned = (" insert ", " update ", " delete ", " truncate ", " drop ", " alter ", " create ", " grant ")
if any(word in lowered for word in banned):
    sys.exit("refusing: query looks mutating. This helper is read-only.")

user = os.environ.get("KH_USER")
password = os.environ.get("KH_PASS")
if not user or not password:
    sys.exit("set KH_USER and KH_PASS (DB credentials) in the environment.")

config = dict(
    host=os.environ.get("KH_HOST", "localhost"),
    port=int(os.environ.get("KH_PORT", "5432")),
    dbname=os.environ.get("KH_DBNAME", "postgres"),
    user=user,
    password=password,
    connect_timeout=5,
)
schema = os.environ.get("KH_SCHEMA", "public")

connection = psycopg2.connect(**config)
connection.set_session(readonly=True)
cursor = connection.cursor()
cursor.execute("SET search_path = %s", (schema,))
cursor.execute(sql)
if cursor.description:
    columns = [d[0] for d in cursor.description]
    rows = cursor.fetchall()
    print(" | ".join(columns))
    for row in rows:
        print(" | ".join("" if v is None else str(v) for v in row))
    print(f"({len(rows)} rows)")
else:
    print("(no result set)")
connection.rollback()
connection.close()
