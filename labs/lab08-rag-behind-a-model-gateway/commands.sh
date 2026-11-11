# Lab 8 · RAG behind a model gateway
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Run it
python3 -m venv .venv && . .venv/bin/activate
pip install openai psycopg[binary] pypdf "mcp[cli]"
echo $LITELLM_KEY        # still set from 8.1? if not, export it again
python ingest.py
python app.py "What is the warranty period for the X200?"
