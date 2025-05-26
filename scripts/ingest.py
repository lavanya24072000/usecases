import boto3
import psycopg2
from utils import chunk_text
 
def ingest(bucket, key):
    s3 = boto3.client("s3")
    obj = s3.get_object(Bucket=bucket, Key=key)
    text = obj['Body'].read().decode('utf-8')
 
    chunks = chunk_text(text)
 
    conn = psycopg2.connect(
        host="your-db-host",
        user="admin",
        password="admin1234",
        dbname="semanticdb"
    )
    cur = conn.cursor()
 
    for chunk in chunks:
        embedding = [0.1] * 1536  # Dummy embedding
        cur.execute("INSERT INTO documents (chunk, embedding) VALUES (%s, %s)", (chunk, embedding))
 
    conn.commit()
    cur.close()
    conn.close()
 
if __name__ == "__main__":
    # Example usage:
    ingest("your-s3-bucket-name", "path/to/your/file.txt")
