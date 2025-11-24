#!/usr/bin/env bash

set -eu

GRDB_VERSION="${GRDB_VERSION:-v7.8.0}"
SQLITE_VERSION="${SQLITE_VERSION:-3510000}"
SQLITE_YEAR="${SQLITE_YEAR:-2025}"
SQLITEDATA_VERSION="${SQLITEDATA_VERSION:-1.3.0}"
OUTPUT_DIR="${1:-.}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"

if [ ! -d "${TEMPLATES_DIR}" ]; then
    echo "Error: templates/ directory not found at ${TEMPLATES_DIR}"
    exit 1
fi

echo "Creating GRDB + SQLiteData package..."
echo "  GRDB: ${GRDB_VERSION}"
echo "  SQLite: ${SQLITE_VERSION}"
echo "  SQLiteData: ${SQLITEDATA_VERSION}"

rm -rf "${OUTPUT_DIR}/Sources"
mkdir -p "${OUTPUT_DIR}/Sources"/{GRDB,SQLiteCustom,SQLiteData,SQLiteExtensions/include}
cd "${OUTPUT_DIR}"

TEMP=$(mktemp -d)
trap "rm -rf ${TEMP}" EXIT

echo "Downloading GRDB..."
git clone --quiet --depth 1 --branch "${GRDB_VERSION}" \
    https://github.com/groue/GRDB.swift.git "${TEMP}/grdb"
cp -R "${TEMP}/grdb/GRDB/." Sources/GRDB/

echo "Downloading SQLite..."
curl -sL "https://www.sqlite.org/${SQLITE_YEAR}/sqlite-amalgamation-${SQLITE_VERSION}.zip" \
    -o "${TEMP}/sqlite.zip"
unzip -q "${TEMP}/sqlite.zip" -d "${TEMP}"
SQLITE_DIR=$(find "${TEMP}" -type d -name "sqlite-amalgamation-*" | head -1)
cp "${SQLITE_DIR}/sqlite3.c" Sources/SQLiteCustom/
cp "${SQLITE_DIR}/sqlite3.h" Sources/SQLiteCustom/
cp "${SQLITE_DIR}/sqlite3ext.h" Sources/SQLiteCustom/

echo "Downloading SQLiteData..."
git clone --quiet --depth 1 --branch "${SQLITEDATA_VERSION}" \
    https://github.com/pointfreeco/sqlite-data.git "${TEMP}/sqlitedata"
cp -R "${TEMP}/sqlitedata/Sources/SQLiteData/." Sources/SQLiteData/
rm -rf Sources/SQLiteData/CloudKit Sources/SQLiteData/Documentation.docc 2>/dev/null || true

cp "${TEMPLATES_DIR}/shim.h" Sources/SQLiteCustom/
cp "${TEMPLATES_DIR}/GRDBSQLite.h" Sources/SQLiteCustom/
cp "${TEMPLATES_DIR}/SQLiteExtensions/initialize-extensions.c" Sources/SQLiteExtensions/
cp "${TEMPLATES_DIR}/SQLiteExtensions/include/initialize-extensions.h" Sources/SQLiteExtensions/include/
