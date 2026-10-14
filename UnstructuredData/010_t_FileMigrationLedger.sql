Use [SalesforceMigration]
go

drop TABLE if exists [FileMigrationLedger]
go

CREATE TABLE [FileMigrationLedger] (
    Id INT IDENTITY PRIMARY KEY,
    SourceContentVersionId VARCHAR(18),
    SourceContentDocumentId VARCHAR(18),
    TargetContentVersionId VARCHAR(18),
    TargetContentDocumentId VARCHAR(18),
    SourceParentId VARCHAR(18),
    TargetParentId VARCHAR(18),
    FileName NVARCHAR(255),
    FileSize BIGINT,
    Checksum VARBINARY(32),
    Status VARCHAR(20),
    RetryCount INT,
    ErrorMessage NVARCHAR(MAX),
    RunId UNIQUEIDENTIFIER,
    BatchId VARCHAR(50),
    CreatedAt DATETIME2,
    UpdatedAt DATETIME2
);
