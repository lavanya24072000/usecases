import os
import json
import psycopg2
import openai

openai.api_key = os.getenv("OPENAI_KEY")

def embed_query(query):
    response = openai.Embedding.create(
        input=query,
        model="text-embedding-ada-002"
    )
    return response["data"][0]["embedding"]

def lambda_handler(event, context):
    body = json.loads(event['body'])
    query = body.get("query", "")
    embedding = embed_query(query)

    conn = psycopg2.connect(
        dbname=os.getenv("PG_DB"),
        user=os.getenv("PG_USER"),
        password=os.getenv("PG_PASS"),
        host=os.getenv("PG_HOST"),
        port=5432
    )
    cur = conn.cursor()
    cur.execute("""
        SELECT content FROM documents
        ORDER BY embedding <-> %s
        LIMIT 5
    """, (embedding,))
    rows = cur.fetchall()
    cur.close()
    conn.close()

    return {
        "statusCode": 200,
        "body": json.dumps([row[0] for row in rows])
    }
