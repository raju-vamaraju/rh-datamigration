Use [SalesforceMigration]
go

drop PROCEDURE if exists [sp_MarkUnstructuredFailure]
go

CREATE PROCEDURE [sp_MarkUnstructuredFailure]
    @Id INT,
    @Error NVARCHAR(MAX)
AS
BEGIN
    UPDATE [UnstructuredMigrationLedger]
    SET [Status] = 'Failed',
        [RetryCount] = [RetryCount] + 1,
        [ErrorMessage] = @Error,
        [UpdatedAt] = SYSDATETIME()
    WHERE [Id] = @Id;
END
go
