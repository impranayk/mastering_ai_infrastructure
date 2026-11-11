# ingest.py: chunk documents, embed them through the gateway, store in pgvector
import os, glob, re
import psycopg
from openai import OpenAI
from pypdf import PdfReader

llm = OpenAI(base_url="http://localhost:4000/v1", api_key=os.environ["LITELLM_KEY"])
DB = "postgresql://rag:rag@localhost:5432/rag"
CHUNK_WORDS, OVERLAP = 350, 50          # ~450-500 tokens per chunk

def read(path):
    if path.endswith(".pdf"):
        return "\n".join(p.extract_text() or "" for p in PdfReader(path).pages)
    return open(path, encoding="utf-8", errors="ignore").read()

def chunks(text):
    words = re.sub(r"\s+", " ", text).split(" ")
    step = CHUNK_WORDS - OVERLAP
    for i in range(0, max(len(words) - OVERLAP, 1), step):
        yield " ".join(words[i:i + CHUNK_WORDS])

with psycopg.connect(DB, autocommit=True) as conn:
    conn.execute("CREATE EXTENSION IF NOT EXISTS vector")
    dim = len(llm.embeddings.create(model="embed", input=["probe"]).data[0].embedding)
    conn.execute("DROP TABLE IF EXISTS chunks")
    conn.execute(f"""CREATE TABLE chunks (id serial PRIMARY KEY, source text, body text,
                    embedding vector({dim}),
                    tsv tsvector GENERATED ALWAYS AS (to_tsvector('english', body)) STORED)""")
    for path in glob.glob("docs/**/*.*", recursive=True):
        parts = list(chunks(read(path)))
        for k in range(0, len(parts), 32):                       # embed in batches
            batch = parts[k:k + 32]
            vecs = llm.embeddings.create(model="embed", input=batch).data
            for body, v in zip(batch, vecs):
                conn.execute("INSERT INTO chunks (source, body, embedding) VALUES (%s, %s, %s::vector)",
                             (os.path.basename(path), body, str(v.embedding)))
        print(f"{path}: {len(parts)} chunks")
    conn.execute("CREATE INDEX ON chunks USING hnsw (embedding vector_cosine_ops)")
    conn.execute("CREATE INDEX ON chunks USING gin (tsv)")
