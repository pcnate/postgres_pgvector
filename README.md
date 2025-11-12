Postgres + pgvector + AGE for LightRAG
=======================================

Spin up a PostgreSQL instance with pgvector and Apache AGE (graph database) enabled for LightRAG.

Quick start
-----------
- Copy env: `cp .env.example .env`
- Start DB: `docker compose up -d`
- Logs: `docker compose logs -f postgres`
- Stop: `docker compose down`
- Test: `./test.sh` (runs all extension tests)

Dockerfile (alternative to Compose)
----------------------------------
- Build image: `docker build -t lightrag-pgvector .`
- Run container:
  - `docker run -d --name lightrag-postgres \
      -p 5432:5432 \
      -e POSTGRES_DB=lightrag \
      -e POSTGRES_USER=lightrag \
      -e POSTGRES_PASSWORD=lightrag \
      -v pgdata:/var/lib/postgresql/data \
      lightrag-pgvector`
- Notes:
  - Init scripts in `db/init` are baked into the image and run only on first init of a fresh volume.
  - Change port or credentials by overriding `-p` and `-e` flags when running.

Connect
-------
- psql: `psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:$POSTGRES_PORT/$POSTGRES_DB"`
- Verify: in psql, run `\\dx` and confirm both `vector` and `age` extensions are installed.

Extensions
----------
- Enabled by default:
  - `vector` (pgvector v0.7.4) - Vector embeddings and similarity search
  - `age` (Apache AGE v1.6.0) - Graph database functionality for PostgreSQL 17
- Optional (commented in `db/init/001_extensions.sql`): `pg_trgm`, `pgcrypto`, `uuid-ossp`, `citext`, `ltree`
- To enable later without reinitializing, run `CREATE EXTENSION ...;` in your DB.

Notes
-----
- The `./db/init` folder runs only on first initialization of the volume (`pgdata`).
  You can install additional extensions later via `CREATE EXTENSION ...;` without dropping data.

Example schema (optional)
-------------------------

### pgvector example
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

### Apache AGE example
```sql
-- Create a graph for entity relationships
SELECT create_graph('chunk_entity_relation');

-- Create a vertex (requires setting search path)
SET search_path = ag_catalog, "$user", public;
SELECT * FROM cypher('chunk_entity_relation', $$
  CREATE (n:Entity {name: 'Example', type: 'document'})
  RETURN n
$$) as (v agtype);

-- Query the graph
SELECT * FROM cypher('chunk_entity_relation', $$
  MATCH (n:Entity)
  RETURN n
$$) as (v agtype);
```

Testing
-------
A comprehensive test script is included to verify both extensions work correctly:

```bash
./test.sh
```

The test script verifies:
- PostgreSQL connection
- pgvector extension installation and functionality
- AGE extension installation and functionality
- Graph creation, vertex operations, and queries
- Vector data type operations

**CI/CD Testing:**
GitHub Actions automatically runs tests on every push and pull request to `main` and `development` branches. See `.github/workflows/test.yml` for details.

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

**Git Workflow:**
1. Install git hooks: `./install-hooks.sh`
2. Create feature branch: `git checkout -b feat/your-feature`
3. Make changes and commit
4. Push and create PR

The pre-commit hook prevents direct commits to `main` and `development` branches, enforcing the feature branch workflow.
# test
