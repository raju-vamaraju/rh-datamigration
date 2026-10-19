USE [SalesforceMigration]
go

-- DELETE FROM [dbo].[AttachmentMigrationLedger] where [ParentObject] = 'EmailTemplate'

with cte_src_task as (
    SELECT
        a.[Id]
        ,a.[Name]
        ,a.[ParentId]
        ,a.[ContentType]
        ,a.[BodyLength]
    FROM [sf].[Attachment] a
    join [sf].[EmailTemplate] s (nolock)
        on s.[Id] = a.[ParentId]
    -- 3
)
,cte_src_tgt_map as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [sf].[EmailTemplate] i (nolock)
    left join [sfrhd].[EmailTemplate] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
    where 1=1
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
    ,[ParentObject] = 'EmailTemplate'
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
-- 3
