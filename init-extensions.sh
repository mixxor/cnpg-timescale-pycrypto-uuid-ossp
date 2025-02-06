#!/bin/bash
set -ex

psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
    CREATE EXTENSION IF NOT EXISTS pgcrypto;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EOSQL