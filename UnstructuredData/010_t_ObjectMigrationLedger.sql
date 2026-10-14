Use [SalesforceMigration]
go

drop TABLE if exists [ObjectMigrationLedger]
go

CREATE TABLE [ObjectMigrationLedger] (
    Id INT IDENTITY PRIMARY KEY,
    ObjectName VARCHAR(50),
    SourceId VARCHAR(18),
    TargetId VARCHAR(18),
    Status VARCHAR(20),
    RetryCount INT,
    ErrorMessage NVARCHAR(MAX),
    RunId UNIQUEIDENTIFIER,
    CreatedAt DATETIME2,
    UpdatedAt DATETIME2
);
