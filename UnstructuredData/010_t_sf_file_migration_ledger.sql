Use [SalesforceMigration]
go

CREATE TABLE [dbo].[sf_file_migration_ledger] (
    ledger_id                BIGINT IDENTITY(1,1) PRIMARY KEY,

    -- Source identity
    source_org                VARCHAR(50) NOT NULL,
    source_object              VARCHAR(50) NOT NULL,    -- Attachment | ContentDocument
    source_parent_object       VARCHAR(50) NOT NULL,    -- Account, Case, etc
    source_parent_id           CHAR(18) NOT NULL,
    source_file_id             CHAR(18) NOT NULL,
    source_version_id          CHAR(18) NULL,
    source_created_date        DATETIME2 NOT NULL,

    -- File metadata
    file_name                  NVARCHAR(255) NOT NULL,
    file_extension             VARCHAR(20),
    file_size_bytes            BIGINT NOT NULL,
    mime_type                  VARCHAR(100),

    -- Integrity
    file_hash_sha256           CHAR(64) NOT NULL,

    -- Target identity
    target_org                 VARCHAR(50),
    target_parent_id           CHAR(18),
    target_file_id             CHAR(18),
    target_version_id          CHAR(18),
    target_created_date        DATETIME2,

    -- Governance
    migration_batch_id         VARCHAR(50) NOT NULL,
    extract_run_ts             DATETIME2 NOT NULL,
    load_run_ts                DATETIME2,
    migration_status           VARCHAR(20) NOT NULL,    -- PLANNED | EXTRACTED | LOADED | FAILED | SKIPPED
    error_message              NVARCHAR(MAX),

    CONSTRAINT uq_file_version UNIQUE (
        source_org,
        source_file_id,
        source_version_id
    )
)
go
