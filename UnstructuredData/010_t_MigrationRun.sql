Use [SalesforceMigration]
go

drop TABLE if exists [MigrationRun]
go

CREATE TABLE [MigrationRun] (
    RunId UNIQUEIDENTIFIER PRIMARY KEY,
    RunName VARCHAR(100),
    StartTime DATETIME2,
    EndTime DATETIME2,
    Status VARCHAR(20),
    TotalRecords INT,
    TotalFiles INT
);
