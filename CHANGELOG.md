# [1.0.0-RC.6](https://github.com/pcnate/postgres_pgvector/compare/v1.0.0-RC.5...v1.0.0-RC.6) (2025-11-12)


### Bug Fixes

* set search_path with public first to prevent pgvector crash ([87dd0a1](https://github.com/pcnate/postgres_pgvector/commit/87dd0a1ec51b3b019e0e7f6fe2a1fddeeb21ce57))

# [1.0.0-RC.5](https://github.com/pcnate/postgres_pgvector/compare/v1.0.0-RC.4...v1.0.0-RC.5) (2025-11-12)


### Bug Fixes

* remove LOAD 'age' from init script to prevent server crash ([9dfd2ad](https://github.com/pcnate/postgres_pgvector/commit/9dfd2ad73595ffcdadeb674e3aa1170a56cfec24))

# [1.0.0-RC.4](https://github.com/pcnate/postgres_pgvector/compare/v1.0.0-RC.3...v1.0.0-RC.4) (2025-11-12)


### Bug Fixes

* add LOAD 'age' to enable AGE extension in sessions ([d4f2fff](https://github.com/pcnate/postgres_pgvector/commit/d4f2fffa36f09c547f2c6958f9e89430324069e7))

# [1.0.0-RC.3](https://github.com/pcnate/postgres_pgvector/compare/v1.0.0-RC.2...v1.0.0-RC.3) (2025-11-12)


### Features

* add Apache AGE graph database extension support ([c742fb1](https://github.com/pcnate/postgres_pgvector/commit/c742fb1792f25f48db7fe94f2afc62bc42a53d4b)), closes [#6](https://github.com/pcnate/postgres_pgvector/issues/6)

# [1.0.0-RC.2](https://github.com/pcnate/postgres_pgvector/compare/v1.0.0-RC.1...v1.0.0-RC.2) (2025-11-12)


### Bug Fixes

* upgrade PostgreSQL from 16 to 17 on Debian Trixie ([788542a](https://github.com/pcnate/postgres_pgvector/commit/788542a89d6b537a3d48001ec17dddcd3b4dc587)), closes [#4](https://github.com/pcnate/postgres_pgvector/issues/4)

# 1.0.0-RC.1 (2025-11-12)


### Features

* add Docker image publishing to GHCR on release ([0550d14](https://github.com/pcnate/postgres_pgvector/commit/0550d14c00b2729f321851208ad9adeef5025e15))
* add multi-stage Dockerfile for pgvector ([f7a4543](https://github.com/pcnate/postgres_pgvector/commit/f7a45433cefbf49cb4f1d1a01b684d141c45b3f4))
* build from local Dockerfile instead of pgvector image ([38a64c4](https://github.com/pcnate/postgres_pgvector/commit/38a64c4bc284249998a242978eafd8301e51982d))

# Changelog

All notable changes to this project will be documented in this file by semantic-release.
