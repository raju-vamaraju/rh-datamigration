Use [SalesforceMigration]
go

drop PROCEDURE if exists [sp_MarkUnstructuredSuccess]
go

CREATE PROCEDURE [sp_MarkUnstructuredSuccess]
    @Id INT,
    @TargetId VARCHAR(18)
AS
BEGIN
    UPDATE [UnstructuredMigrationLedger]
    SET [Status] = 'Success',
        [TargetId] = @TargetId,
        [UpdatedAt] = SYSDATETIME()
    WHERE [Id] = @Id;
END
go
