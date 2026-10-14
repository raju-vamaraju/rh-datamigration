Use [SalesforceMigration]
go

drop TABLE if exists AttachmentMigrationLedger
go

CREATE TABLE AttachmentMigrationLedger (
    Id INT IDENTITY PRIMARY KEY,
    SourceAttachmentId VARCHAR(18),
    TargetAttachmentId VARCHAR(18),
    SourceParentId VARCHAR(18),
    TargetParentId VARCHAR(18),
    ParentObject VARCHAR(50),
    FileName NVARCHAR(255),
    BodyLength INT,
    Status VARCHAR(20),
    RetryCount INT DEFAULT 0,
    ErrorMessage NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2
);