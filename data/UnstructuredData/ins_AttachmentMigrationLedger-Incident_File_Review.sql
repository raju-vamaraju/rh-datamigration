USE [SalesforceMigration]
go

-- DELETE FROM [dbo].[AttachmentMigrationLedger] where [ParentObject] = 'Incident_File_Review__c'

with cte_src_task as (
    SELECT
        a.[Id]
        ,a.[Name]
        ,a.[ParentId]
        ,a.[ContentType]
        ,a.[BodyLength]
    FROM [sf].[Attachment] a
    join [sf].[Incident_File_Review__c] s (nolock)
        on s.[Id] = a.[ParentId]
        and s.[Licensee__c] in ('Bridges', 'Shadforth')
    -- 1259
)
,cte_src_tgt_map as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [sf].[Incident_File_Review__c] i (nolock)
    left join [sfrhd].[Incident_File_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    and i.[Licensee__c] in ('Bridges', 'Shadforth')
)
INSERT INTO [dbo].[AttachmentMigrationLedger] (
    [SourceAttachmentId]
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
    ,[UpdatedAt])
select
    [SourceAttachmentId] = c.[Id]
    ,[TargetAttachmentId] = null
    ,[SourceParentId] = c.[ParentId]
    ,[TargetParentId] = m.[id-tgt]
    ,[ParentObject] = 'Incident_File_Review__c'
    ,[FileName] = c.[Name]
    ,[BodyLength]
    ,[Status] = 'Pending'
    ,[RetryCount] = 0
    ,[ErrorMessage] = null
    ,[CreatedAt] = getdate()
    ,[UpdatedAt] = getdate()
from [cte_src_task] c
join [cte_src_tgt_map] m
    on m.[id-src] = c.[ParentId]
go
-- 2647
