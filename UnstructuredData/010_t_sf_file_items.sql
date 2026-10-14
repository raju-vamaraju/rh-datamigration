USE [SalesforceMigration]
GO

drop table if exists [dbo].[sf_file_items]
go

CREATE TABLE dbo.sf_file_items (
      item_id                   BIGINT IDENTITY(1,1) PRIMARY KEY,
      source_type               VARCHAR(20)  NOT NULL,  -- ATTACHMENT | FILE
      source_file_id            CHAR(18)     NOT NULL,  -- Attachment.Id OR ContentDocumentId
      source_version_id         CHAR(18)     NULL,      -- Attachment.Id OR ContentVersion.Id
      source_created_date       DATETIME2    NULL,

      file_name                 NVARCHAR(255) NOT NULL,
      file_ext                  VARCHAR(20)   NULL,
      mime_type                 VARCHAR(100)  NULL,
      file_size_bytes           BIGINT        NOT NULL,

      download_url              NVARCHAR(400) NOT NULL, -- relative /services/data/.../Body or /VersionData
      local_path                NVARCHAR(400) NULL,
      sha256                    CHAR(64)      NULL,

      status                    VARCHAR(20)   NOT NULL CONSTRAINT df_sf_file_items_status DEFAULT ('PLANNED'),
      error_message             NVARCHAR(MAX) NULL,

      extract_run_ts            DATETIME2     NOT NULL,
      batch_id                  VARCHAR(50)   NOT NULL,

      target_content_version_id CHAR(18)      NULL,
      target_content_document_id CHAR(18)     NULL,
      upload_run_ts             DATETIME2     NULL
  );

CREATE UNIQUE INDEX ux_sf_file_items_source
    ON dbo.sf_file_items(source_type, source_file_id, source_version_id);
CREATE INDEX ix_sf_file_items_batch_status
    ON dbo.sf_file_items(batch_id, status);
GO
