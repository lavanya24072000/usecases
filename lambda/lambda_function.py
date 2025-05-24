
import boto3
import fitz  # PyMuPDF
import tiktoken
import psycopg2
import openai
import os

# Set OpenAI API key from environment variable
openai.api_key = os.environ["OPENAI_API_KEY"]

def download_file(bucket_name, s3_key, local_path):
    s3 = boto3.client('s3')
    s3.download_file(bucket_name, s3_key, local_path)

def extract_text(file_path):
    doc = fitz.open(file_path)
    return "\n".join([page.get_text() for page in doc])

def chunk_text(text, max_tokens=500):
    tokenizer = tiktoken.get_encoding("cl100k_base")
    tokens = tokenizer.encode(text)
    return [tokenizer.decode(tokens[i:i+max_tokens]) for i in range(0, len(tokens), max_tokens)]

def generate_embeddings(chunks):
    embeddings = []
    for chunk in chunks:
        response = openai.Embedding.create(
            input=chunk,
            model="text-embedding-ada-002"
        )
        embeddings.append(response['data'][0]['embedding'])
    return embeddings

def store_chunks(chunks, embeddings, db_config):
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()
    for chunk, embedding in zip(chunks, embeddings):
        cursor.execute(
            "INSERT INTO documents (content, embedding) VALUES (%s, %s)",
            (chunk, embedding)
        )
    conn.commit()
    cursor.close()
    conn.close()

def lambda_handler(event, context):
    bucket_name = os.environ['BUCKET_NAME']
    db_config = {
        'host': os.environ['DB_HOST'],
        'dbname': os.environ['DB_NAME'],
        'user': os.environ['DB_USER'],
        'password': os.environ['DB_PASSWORD']
    }
    s3_key = event['s3_key']
    local_path = '/tmp/document.pdf'

    download_file(bucket_name, s3_key, local_path)
    text = extract_text(local_path)
    chunks = chunk_text(text)
    embeddings = generate_embeddings(chunks)
    store_chunks(chunks, embeddings, db_config)
