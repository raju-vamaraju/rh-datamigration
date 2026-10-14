USE [SalesforceMigration]
go

-- DELETE FROM [dbo].[AttachmentMigrationLedger] where [ParentObject] = 'Task'

with cte_src_task as (
    SELECT
        a.[Id]
        ,a.[Name]
        ,a.[ParentId]
        ,a.[ContentType]
        ,a.[BodyLength]
    FROM [ADVICE_ETL_PRD].[sf].[Attachment] a
    join [ADVICE_ETL_PRD].[sf].[Task] s (nolock)
        on s.[Id] = a.[ParentId]
    join [ADVICE_ETL_PRD].[sf].[Account] t (nolock)
        on t.[Id] = s.[AccountId]
        and t.[Licensee__c] = 'Shadforth'
)
,cte_src_tgt_map as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[TaskNumber-src] = i.[Task_Number__c]
        ,[TaskNumber-tgt] = r.[Task_Number__c]
    from [ADVICE_ETL_PRD].[sf].[Task] i (nolock)
    join [ADVICE_ETL_PRD].[sf].[Account] c (nolock)
        on c.[Id] = i.[AccountId]
        and c.[Licensee__c] = 'Shadforth'
    left join [ADVICE_ETL_PRD].[sfrhd].[Task] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    left join [ADVICE_ETL_PRD].[sfrhd].[Account] rc (nolock)
        on rc.[Id] = r.[AccountId]
        and rc.[Licensee__c] = 'Shadforth'
    where 1=1
    --and r.[Id] is not null
)
--INSERT INTO [dbo].[AttachmentMigrationLedger] (
--    [SourceAttachmentId]
--    ,[TargetAttachmentId]
--    ,[SourceParentId]
--    ,[TargetParentId]
--    ,[ParentObject]
--    ,[FileName]
--    ,[BodyLength]
--    ,[Status]
--    ,[RetryCount]
--    ,[ErrorMessage]
--    ,[CreatedAt]
--    ,[UpdatedAt])
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
