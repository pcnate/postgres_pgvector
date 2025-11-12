Postgres + pgvector for LightRAG
================================

Spin up a PostgreSQL instance with pgvector and pg_trgm enabled for LightRAG.

Quick start
-----------
- Copy env: `cp .env.example .env`
- Start DB: `docker compose up -d`
- Logs: `docker compose logs -f postgres`
- Stop: `docker compose down`

Connect
-------
- psql: `psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:$POSTGRES_PORT/$POSTGRES_DB"`
- Verify: in psql, run `\\dx` and confirm `vector` and `pg_trgm` are installed.

Extensions
----------
- Enabled by default via `db/init/001_extensions.sql`:
  - `vector` (pgvector)
  - `pg_trgm`
- Optional lines are commented; uncomment to enable on first init.

Notes
-----
- The `./db/init` folder runs only on first initialization of the volume (`pgdata`).
  To re-run init scripts, remove the volume: `docker compose down -v` (data loss).

Example schema (optional)
-------------------------
```sql
-- Example table for 1536-dim embeddings
CREATE TABLE IF NOT EXISTS documents (
  id BIGSERIAL PRIMARY KEY,
  embedding vector(1536),
  content TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Example vector index (cosine)
CREATE INDEX IF NOT EXISTS idx_documents_embedding
  ON documents USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);
```

Semantic Release
----------------
- Branching:
  - `main`: stable releases (tagged)
  - `development`: RC prereleases (e.g. `v1.2.0-rc.1`)
- CI: GitHub Actions workflow runs semantic-release on push to `main` or `development`,
  and when PRs into those branches are closed/merged.
- Configure repo secret `GITHUB_TOKEN` (automatic in GitHub) with `contents: write` permissions.
- Use Conventional Commits (feat, fix, chore, docs, refactor, perf, test) to drive versioning.

Local development
-----------------
- Requires Docker Desktop.
- Node 18+ if you want to run `semantic-release` locally.
