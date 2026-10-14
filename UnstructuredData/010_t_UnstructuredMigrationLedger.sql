Use [SalesforceMigration]
go

drop TABLE if exists [UnstructuredMigrationLedger]
go

CREATE TABLE [UnstructuredMigrationLedger] (
    Id INT IDENTITY PRIMARY KEY,

    SourceType VARCHAR(20), -- Attachment | ContentVersion

    SourceId VARCHAR(18),
    TargetId VARCHAR(18),

    SourceParentId VARCHAR(18),
    TargetParentId VARCHAR(18),

    ParentObject VARCHAR(50),

    FileName NVARCHAR(255),
    FileSize BIGINT,

    MigrationMode VARCHAR(20), 
    -- 'AttachmentToAttachment'
    -- 'AttachmentToFile'
    -- 'FileToFile'

    Status VARCHAR(20),
    RetryCount INT DEFAULT 0,
    ErrorMessage NVARCHAR(MAX),

    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2
);

/*
UPDATE l
SET ParentObject = pm.ObjectName,
    TargetParentId = pm.TargetId
FROM UnstructuredMigrationLedger l
JOIN ParentMapping pm
    ON l.SourceParentId = pm.SourceId
*/
