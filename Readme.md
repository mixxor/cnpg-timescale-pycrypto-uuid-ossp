# PostgreSQL + TimescaleDB + Barman Cloud Docker Image

This repository contains a Docker image for PostgreSQL 16 with TimescaleDB, Barman Cloud, and essential extensions. It is optimized for use with the CloudNative-PG operator in Kubernetes.

## Features
- **PostgreSQL 16**: The latest stable version of PostgreSQL.
- **TimescaleDB 2.17.2**: Scalable time-series data handling.
- **Barman Cloud**: Backup and recovery for CloudNative-PG.
- **Pre-installed Extensions**:
  - `timescaledb`: Time-series data management.
  - `pgcrypto`: Cryptographic functions.
  - `uuid-ossp`: UUID generation.

## Usage

### Pull the Image
The image is available on GitHub Container Registry (GHCR):

```bash
docker pull ghcr.io/mixxor/cnpg-timescale:16
```