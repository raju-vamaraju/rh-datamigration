Use [SalesforceMigration]
go

drop PROCEDURE if exists [sp_GetNextUnstructuredBatch]
go

CREATE PROCEDURE [sp_GetNextUnstructuredBatch]
    @BatchSize INT
AS
BEGIN
    UPDATE TOP (@BatchSize) [UnstructuredMigrationLedger]
    SET [Status] = 'InProgress',
        [UpdatedAt] = SYSDATETIME()
    OUTPUT inserted.*
    WHERE [Status] IN ('Pending','Failed')
      AND [RetryCount] < 3;
END
go
