Use [SalesforceMigration]
go

drop TABLE if exists [ParentMapping]
go

CREATE TABLE [ParentMapping] (
    ObjectName VARCHAR(50),
    SourceId VARCHAR(18),
    TargetId VARCHAR(18),
    PRIMARY KEY (ObjectName, SourceId)
);