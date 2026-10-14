SELECT TOP (1000) [Id]
      ,[SourceAttachmentId]
      ,[TargetAttachmentId]
      ,[SourceParentId]
      ,[TargetParentId]
      ,[ParentObject]
      ,[FileName]
      ,[BodyLength]
      ,[Status]
      ,[RetryCount]
      ,[ErrorMessage]
      ,[CreatedAt]
      ,[UpdatedAt]
-- update tbl set [Status] = 'Pending'
FROM [SalesforceMigration].[dbo].[AttachmentMigrationLedger] tbl
where 1=1
--and [SourceAttachmentId] = '00P6F00003J3NO0UAN'
--and [TargetAttachmentId] is null
