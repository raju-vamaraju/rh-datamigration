USE [SalesforceMigration]
go

--select count(parentobject), ParentObject from  [dbo].[AttachmentMigrationLedger] group by parentobject

-- DELETE FROM [dbo].[AttachmentMigrationLedger] where [ParentObject] = 'Task'

with cte_src_task as (
    SELECT
        a.[Id]
        ,a.[Name]
        ,a.[ParentId]
        ,a.[ContentType]
        ,a.[BodyLength]
    FROM [sf].[Attachment] a
    join [sf].[Task] s (nolock)
        on s.[Id] = a.[ParentId]
    join [sf].[Account] t (nolock)
        on t.[Id] = s.[AccountId]
        and t.[Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_src_tgt_map as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[TaskNumber-src] = i.[Task_Number__c]
        ,[TaskNumber-tgt] = r.[Task_Number__c]
    from [sf].[Task] i (nolock)
    join [sf].[Account] c (nolock)
        on c.[Id] = i.[AccountId]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [sfrhd].[Task] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    left join [sfrhd].[Account] rc (nolock)
        on rc.[Id] = r.[AccountId]
        and rc.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    --and r.[Id] is not null
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
    ,[ParentObject] = 'Task'
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
-- 6539