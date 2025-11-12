#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CONTAINER_NAME="${CONTAINER_NAME:-lightrag-postgres}"
DB_USER="${POSTGRES_USER:-lightrag}"
DB_NAME="${POSTGRES_DB:-lightrag}"

echo -e "${YELLOW}=== Testing PostgreSQL Extensions ===${NC}\n"

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}✗ Container $CONTAINER_NAME is not running${NC}"
    echo "Start it with: docker compose up -d"
    exit 1
fi
echo -e "${GREEN}✓ Container is running${NC}"

# Test PostgreSQL connection
echo -e "\n${YELLOW}Testing PostgreSQL connection...${NC}"
if docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT version();" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PostgreSQL connection successful${NC}"
else
    echo -e "${RED}✗ PostgreSQL connection failed${NC}"
    exit 1
fi

# Test pgvector extension
echo -e "\n${YELLOW}Testing pgvector extension...${NC}"
result=$(docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM pg_extension WHERE extname = 'vector';")
if [ "$result" -eq 1 ]; then
    version=$(docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT extversion FROM pg_extension WHERE extname = 'vector';" | xargs)
    echo -e "${GREEN}✓ pgvector extension installed (version: $version)${NC}"
else
    echo -e "${RED}✗ pgvector extension not installed${NC}"
    exit 1
fi

# Test vector operations
echo -e "${YELLOW}  Testing vector operations...${NC}"
docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT '[1,2,3]'::vector;" > /dev/null 2>&1
echo -e "${GREEN}  ✓ Vector data type works${NC}"

# Test AGE extension
echo -e "\n${YELLOW}Testing AGE extension...${NC}"
result=$(docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM pg_extension WHERE extname = 'age';")
if [ "$result" -eq 1 ]; then
    version=$(docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT extversion FROM pg_extension WHERE extname = 'age';" | xargs)
    echo -e "${GREEN}✓ AGE extension installed (version: $version)${NC}"
else
    echo -e "${RED}✗ AGE extension not installed${NC}"
    exit 1
fi

# Test AGE graph operations
echo -e "${YELLOW}  Testing AGE graph operations...${NC}"

# Create test graph
docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT drop_graph('test_graph_script', true);" > /dev/null 2>&1 || true
docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT create_graph('test_graph_script');" > /dev/null 2>&1
echo -e "${GREEN}  ✓ create_graph() function works${NC}"

# Create vertex
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" > /dev/null 2>&1 <<'EOSQL'
LOAD 'age';
SET search_path = ag_catalog, "$user", public;
SELECT * FROM cypher('test_graph_script', $$
  CREATE (n:TestNode {name: 'test', value: 42})
  RETURN n
$$) as (v agtype);
EOSQL
echo -e "${GREEN}  ✓ Create vertex works${NC}"

# Query graph
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" > /dev/null 2>&1 <<'EOSQL'
LOAD 'age';
SET search_path = ag_catalog, "$user", public;
SELECT * FROM cypher('test_graph_script', $$
  MATCH (n:TestNode)
  RETURN n.name, n.value
$$) as (name agtype, value agtype);
EOSQL
echo -e "${GREEN}  ✓ Graph query works${NC}"

# Clean up test graph
docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT drop_graph('test_graph_script', true);" > /dev/null 2>&1
echo -e "${GREEN}  ✓ drop_graph() function works${NC}"

echo -e "\n${GREEN}=== All tests passed! ===${NC}"
