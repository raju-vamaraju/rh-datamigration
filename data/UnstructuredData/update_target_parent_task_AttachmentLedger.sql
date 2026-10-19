UPDATE aml
SET aml.TargetParentId = tt.Id
FROM [SalesforceMigration].[dbo].[AttachmentMigrationLedger] aml
INNER JOIN [SalesforceMigration].[sf].[Attachment] a
    ON a.Id = aml.SourceAttachmentId
INNER JOIN [SalesforceMigration].[sf].[Task] t
    ON t.Id = a.ParentId
INNER JOIN [SalesforceMigration].[sfrhd].[Task] tt
    ON t.Id = tt.Metazoa_External_ID__c
WHERE aml.ErrorMessage IS NOT NULL
  AND tt.Id IS NOT NULL
  AND aml.TargetParentId IS NULL;