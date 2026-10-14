USE [SalesforceMigration]
go

-- DELETE FROM [dbo].[AttachmentMigrationLedger] where [ParentObject] = 'Assurance_Review__c'

with cte_src_task as (
    SELECT
        a.[Id]
        ,a.[Name]
        ,a.[ParentId]
        ,a.[ContentType]
        ,a.[BodyLength]
    FROM [ADVICE_ETL_PRD].[sf].[Attachment] a
    join [ADVICE_ETL_PRD].[sf].[Assurance_Review__c] s (nolock)
        on s.[Id] = a.[ParentId]
    join [ADVICE_ETL_PRD].[sf].[Contact] t (nolock)
        on t.[Id] = s.[Adviser__c]
        and t.[Licensee__c] = 'Shadforth'
)
,cte_src_tgt_map as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Assurance_Review__c] i (nolock)
    join [ADVICE_ETL_PRD].[sf].[Contact] c (nolock)
        on c.[Id] = i.[Adviser__c]
        and c.[Licensee__c] = 'Shadforth'
    left join [ADVICE_ETL_PRD].[sfrhd].[Assurance_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    left join [ADVICE_ETL_PRD].[sfrhd].[Contact] rc (nolock)
        on rc.[Id] = r.[Adviser__c]
        and rc.[Licensee__c] = 'Shadforth'
    where 1=1
    and r.[Id] is not null
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
    ,[ParentObject] = 'Assurance_Review__c'
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
-- 506
