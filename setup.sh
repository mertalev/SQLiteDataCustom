#!/usr/bin/env bash

set -eu

GRDB_VERSION="${GRDB_VERSION:-v7.8.0}"
SQLITE_VERSION="${SQLITE_VERSION:-3510000}"
SQLITE_YEAR="${SQLITE_YEAR:-2025}"
SQLITEDATA_VERSION="${SQLITEDATA_VERSION:-1.3.0}"
USEARCH_VERSION="${USEARCH_VERSION:-v2.21.3}"
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
echo "  USearch: ${USEARCH_VERSION}"

rm -rf "${OUTPUT_DIR}/Sources"
mkdir -p "${OUTPUT_DIR}/Sources"/{GRDB,SQLiteCustom,SQLiteData,SQLiteExtensions/include}
mkdir -p "${OUTPUT_DIR}/Sources"/USearchExtension/{include/usearch,stringzilla/include/stringzilla,stringzilla/c,simsimd/include/simsimd,fp16/include/fp16}
cd "${OUTPUT_DIR}"

TEMP=$(mktemp -d)
trap "rm -rf ${TEMP}" EXIT

echo "Downloading GRDB..."
git clone --quiet --depth 1 --branch "${GRDB_VERSION}" \
    https://github.com/groue/GRDB.swift.git "${TEMP}/grdb"
cp -R "${TEMP}/grdb/GRDB/." Sources/GRDB/
cp "${TEMP}/grdb/LICENSE" Sources/GRDB/LICENSE

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
cp "${TEMP}/sqlitedata/LICENSE" Sources/SQLiteData/LICENSE
rm -rf Sources/SQLiteData/CloudKit Sources/SQLiteData/Documentation.docc 2>/dev/null || true

echo "Downloading USearch..."
git clone --quiet --depth 1 --branch "${USEARCH_VERSION}" --recursive \
    https://github.com/unum-cloud/USearch.git "${TEMP}/usearch"
cp "${TEMP}/usearch/include/usearch/"*.hpp Sources/USearchExtension/include/usearch/
cp "${TEMP}/usearch/sqlite/lib.cpp" Sources/USearchExtension/
cp "${TEMP}/usearch/LICENSE" Sources/USearchExtension/LICENSE
cp "${TEMP}/usearch/stringzilla/include/stringzilla/"*.h Sources/USearchExtension/stringzilla/include/stringzilla/
cp "${TEMP}/usearch/stringzilla/include/stringzilla/"*.hpp Sources/USearchExtension/stringzilla/include/stringzilla/
cp "${TEMP}/usearch/stringzilla/c/lib.c" Sources/USearchExtension/stringzilla/c/
cp "${TEMP}/usearch/stringzilla/LICENSE" Sources/USearchExtension/stringzilla/LICENSE
cp "${TEMP}/usearch/simsimd/include/simsimd/"*.h Sources/USearchExtension/simsimd/include/simsimd/
cp "${TEMP}/usearch/simsimd/LICENSE" Sources/USearchExtension/simsimd/LICENSE
cp "${TEMP}/usearch/fp16/include/fp16/"*.h Sources/USearchExtension/fp16/include/fp16/
cp "${TEMP}/usearch/fp16/LICENSE" Sources/USearchExtension/fp16/LICENSE

cp "${TEMPLATES_DIR}/shim.h" Sources/SQLiteCustom/
cp "${TEMPLATES_DIR}/GRDBSQLite.h" Sources/SQLiteCustom/
cp "${TEMPLATES_DIR}/SQLiteExtensions/initialize-extensions.c" Sources/SQLiteExtensions/
cp "${TEMPLATES_DIR}/SQLiteExtensions/include/initialize-extensions.h" Sources/SQLiteExtensions/include/
