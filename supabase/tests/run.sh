#!/usr/bin/env bash
# Migratsiyani toza lokal Postgres bazasida sinaydi.
# Talab: PostgreSQL 16 + PostGIS + pg_cron (shared_preload_libraries = 'pg_cron', cron.database_name = 'ekokelajak_test').
set -euo pipefail
cd "$(dirname "$0")/.."
DB=ekokelajak_test
PSQL=(psql -v ON_ERROR_STOP=1 -q -X)
"${PSQL[@]}" -d postgres -c "drop database if exists $DB with (force)" -c "create database $DB"
"${PSQL[@]}" -d $DB -f tests/00_supabase_stubs.sql
"${PSQL[@]}" -d $DB -c "set search_path = public, extensions" -f migrations/20261010000000_init.sql
"${PSQL[@]}" -d $DB -f tests/10_flow_test.sql >/dev/null
echo "OK: barcha DB sinovlari o'tdi"
