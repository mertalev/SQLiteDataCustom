#define SQLITE_CORE 1
#include "sqlite3.h"

// Initialize SQLite extensions. Add sqlite3_auto_extension() calls here.
// Example:
//   extern int sqlite3_vec_init(sqlite3*, char**, const sqlite3_api_routines*);
//   sqlite3_auto_extension((void *)sqlite3_vec_init);

int initialize_sqlite3_extensions(void) {
    return 0;
}
