-- Enable required extensions for LightRAG usage
CREATE EXTENSION IF NOT EXISTS vector;   -- pgvector (required)
CREATE EXTENSION IF NOT EXISTS age;      -- Apache AGE graph database (required)

-- Load AGE extension into session
LOAD 'age';

-- Configure AGE search path to include ag_catalog
ALTER DATABASE lightrag SET search_path = ag_catalog, "$user", public;

-- Add optional extensions below if desired
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;   -- trigram similarity (optional)
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- gen_random_uuid()
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- uuid_generate_v4()
-- CREATE EXTENSION IF NOT EXISTS citext;     -- case-insensitive text
-- CREATE EXTENSION IF NOT EXISTS ltree;      -- label tree paths
