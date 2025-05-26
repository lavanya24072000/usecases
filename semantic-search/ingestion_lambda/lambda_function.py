import os
import boto3
import psycopg2
import fitz  # PyMuPDF
import openai

s3 = boto3.client('s3')
openai.api_key = os.getenv("OPENAI_KEY")

def embed_text(text):
    response = openai.Embedding.create(
        input=text,
        model="text-embedding-ada-002"
    )
    return response["data"][0]["embedding"]

def chunk_text(text, chunk_size=500):
    return [text[i:i + chunk_size] for i in range(0, len(text), chunk_size)]

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key    = event['Records'][0]['s3']['object']['key']
    
    tmp_path = f"/tmp/{key}"
    s3.download_file(bucket, key, tmp_path)

    doc = fitz.open(tmp_path)
    full_text = ""
    for page in doc:
        full_text += page.get_text()

    chunks = chunk_text(full_text)

    conn = psycopg2.connect(
        dbname=os.getenv("PG_DB"),
        user=os.getenv("PG_USER"),
        password=os.getenv("PG_PASS"),
        host=os.getenv("PG_HOST"),
        port=5432
    )
    cur = conn.cursor()

    for chunk in chunks:
        embedding = embed_text(chunk)
        cur.execute("INSERT INTO documents (content, embedding) VALUES (%s, %s)", (chunk, embedding))

    conn.commit()
    cur.close()
    conn.close()

    return {"statusCode": 200, "body": "Ingestion complete"}
