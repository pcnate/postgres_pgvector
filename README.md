Postgres + pgvector for LightRAG
================================

Spin up a PostgreSQL instance with pgvector enabled for LightRAG.

Quick start
-----------
- Copy env: `cp .env.example .env`
- Start DB: `docker compose up -d`
- Logs: `docker compose logs -f postgres`
- Stop: `docker compose down`

Connect
-------
- psql: `psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:$POSTGRES_PORT/$POSTGRES_DB"`
- Verify: in psql, run `\\dx` and confirm `vector` is installed.

Extensions
----------
Extensions
----------
- Enabled by default: `vector` (pgvector)
- Optional (commented in `db/init/001_extensions.sql`): `pg_trgm`, `pgcrypto`, `uuid-ossp`, `citext`, `ltree`
- To enable later without reinitializing, run `CREATE EXTENSION ...;` in your DB.

Notes
-----
- The `./db/init` folder runs only on first initialization of the volume (`pgdata`).
  You can install additional extensions later via `CREATE EXTENSION ...;` without dropping data.

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
