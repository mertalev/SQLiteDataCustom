// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SQLiteDataCustom",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "GRDB", targets: ["GRDB"]),
        .library(name: "SQLiteExtensions", targets: ["SQLiteExtensions"]),
        .library(name: "SQLiteData", targets: ["SQLiteData"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.0"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-structured-queries", from: "0.24.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "GRDBSQLite",
            path: "Sources/SQLiteCustom",
            sources: ["sqlite3.c"],
            publicHeadersPath: ".",
            cSettings: [
                .define("SQLITE_ENABLE_SNAPSHOT"),
                .define("SQLITE_ENABLE_FTS5"),
                .define("SQLITE_ENABLE_PREUPDATE_HOOK"),
                .define("SQLITE_ENABLE_RTREE"),
                .define("SQLITE_THREADSAFE", to: "2"),
                .define("SQLITE_DQS", to: "0"),
                .define("SQLITE_DEFAULT_MEMSTATUS", to: "0"),
                .define("SQLITE_LIKE_DOESNT_MATCH_BLOBS"),
                .define("SQLITE_MAX_EXPR_DEPTH", to: "0"),
                .define("SQLITE_OMIT_PROGRESS_CALLBACK"),
                .define("SQLITE_OMIT_SHARED_CACHE"),
                .define("SQLITE_OMIT_AUTHORIZATION"),
                .define("SQLITE_USE_ALLOCA"),
                .define("SQLITE_OMIT_AUTOINIT"),
                .define("SQLITE_OMIT_DEPRECATED"),
                .define("SQLITE_TEMP_STORE", to: "2"),
                .define("SQLITE_ENABLE_STAT4"),
                .define("SQLITE_CORE"),
                .define("SQLITE_DEFAULT_CACHE_SIZE", to: "10000"),
                .define("SQLITE_DEFAULT_WAL_SYNCHRONOUS"),
                .define("SQLITE_ENABLE_PERCENTILE"),
                .define("SQLITE_ENABLE_MATH_FUNCTIONS"),
                .define("SQLITE_UNTESTABLE"),
				.define("SQLITE_OMIT_TRACE"),
                .define("SQLITE_OMIT_TCL_VARIABLE"),
                .define("SQLITE_HAVE_ISNAN"),
                .define("SQLITE_HAVE_LOCALTIME_R"),
				.define("SQLITE_HAVE_LOCALTIME_S"),
				.define("SQLITE_HAVE_MALLOC_USABLE_SIZE"),
                .define("SQLITE_HAVE_STRCHRNUL"),
                .define("SQLITE_ENABLE_GEOPOLY"),
                .define("NDEBUG", .when(configuration: .release)),
                .unsafeFlags(["-Wno-ambiguous-macro"])
            ],
        ),
        .target(
            name: "GRDB",
            dependencies: ["GRDBSQLite"],
            path: "Sources/GRDB",
            exclude: ["Documentation.docc", "PrivacyInfo.xcprivacy"],
            swiftSettings: [
                .define("SQLITE_ENABLE_SNAPSHOT"),
                .define("SQLITE_ENABLE_FTS5"),
                .define("SQLITE_ENABLE_PREUPDATE_HOOK"),
                .define("GRDBCUSTOMSQLITE")
            ]
        ),
        .target(
            name: "SQLiteExtensions",
            dependencies: ["GRDBSQLite"],
            path: "Sources/SQLiteExtensions",
            publicHeadersPath: "include",
            cSettings: [.define("SQLITE_CORE", to: "1")]
        ),
        .target(
            name: "SQLiteData",
            dependencies: [
                "GRDB",
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "Sharing", package: "swift-sharing"),
                .product(name: "StructuredQueriesSQLite", package: "swift-structured-queries"),
            ],
            path: "Sources/SQLiteData",
            swiftSettings: [
                .define("SQLITE_ENABLE_SNAPSHOT"),
                .define("SQLITE_ENABLE_FTS5"),
                .define("SQLITE_ENABLE_PREUPDATE_HOOK")
            ]
        )
    ],
    cLanguageStandard: .c11
)
