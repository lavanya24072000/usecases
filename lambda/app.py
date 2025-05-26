import json
import psycopg2
import os
 
def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        query = body.get("query", "")
        if not query:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Query parameter missing"})
            }
 
        # Dummy embedding vector - replace with real embedding logic
        embedding = [0.1] * 1536
 
        conn = psycopg2.connect(
            host=os.environ["DB_HOST"],
            dbname=os.environ["DB_NAME"],
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASS"]
        )
        cur = conn.cursor()
 
        # pgvector similarity search example
        cur.execute("""
            SELECT chunk, 1 - (embedding <=> %s::vector) AS similarity
            FROM documents
            ORDER BY embedding <=> %s::vector
            LIMIT 5
        """, (embedding, embedding))
 
        results = [{"chunk": row[0], "score": row[1]} for row in cur.fetchall()]
        cur.close()
        conn.close()
 
        return {
            "statusCode": 200,
            "body": json.dumps(results)
        }
 
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
