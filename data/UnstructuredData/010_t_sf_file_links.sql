USE [SalesforceMigration]
GO

drop table if exists [dbo].[sf_file_links]
go

CREATE TABLE [dbo].[sf_file_links] (
    link_id                   BIGINT IDENTITY(1,1) PRIMARY KEY,

    source_type               VARCHAR(20) NOT NULL,  -- ATTACHMENT | FILE
    source_file_id            CHAR(18)    NOT NULL,  -- Attachment.Id OR ContentDocumentId
    source_parent_id          CHAR(18)    NOT NULL,

    target_parent_id          CHAR(18)    NULL,
    target_content_document_id CHAR(18)   NULL,
    target_link_id            CHAR(18)    NULL,

    share_type                VARCHAR(1)  NOT NULL CONSTRAINT df_sf_file_links_share DEFAULT ('V'),
    visibility                VARCHAR(20) NOT NULL CONSTRAINT df_sf_file_links_vis DEFAULT ('AllUsers'),

    status                    VARCHAR(20) NOT NULL CONSTRAINT df_sf_file_links_status DEFAULT ('PLANNED'),
    error_message             NVARCHAR(MAX) NULL,
    link_run_ts               DATETIME2    NULL,

    batch_id                  VARCHAR(50)  NOT NULL
);

CREATE INDEX ix_sf_file_links_batch_status
    ON dbo.sf_file_links(batch_id, status);
CREATE INDEX ix_sf_file_links_src
    ON dbo.sf_file_links(source_type, source_file_id);
GO
