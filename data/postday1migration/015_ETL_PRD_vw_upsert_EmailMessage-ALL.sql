Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_EmailMessage-ALL]
go

create view [sfrhd].[vw_upsert_EmailMessage-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_A1_Support_Staff_Registrations as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[A1_Support_Staff_Registrations__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[A1_Support_Staff_Registrations__c] r (nolock)
        on r.[Email_Address__c] = i.[Email_Address__c]
        --and r.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_Case as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[CaseNumber-src] = i.[CaseNumber]
        ,[CaseNumber-tgt] = r.[CaseNumber]
    from [SalesforceMigration].[sf].[Case] i (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = i.[ContactId]
    join [SalesforceMigration].[sfrhd].[Case] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    where 1=1
)
,cte_EmailMessage as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[EmailMessage] i (nolock)
    join [SalesforceMigration].[sfrhd].[EmailMessage] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Name] like '%Shadforth%'
    where 1=1
    --and i.[Name] like '%Shadforth%'
)
,cte_EmailTemplate as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[EmailTemplate] i (nolock)
    join [SalesforceMigration].[sfrhd].[EmailTemplate] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
        --and r.[Name] like '%Shadforth%'
    where 1=1
    --and i.[Name] like '%Shadforth%'
)
,cte_Task as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Task_Number__c]
        ,[Name-tgt] = r.[Task_Number__c]
        ,r.[Task_Number__c]
    from [SalesforceMigration].[sf].[Task] i (nolock)
    join [SalesforceMigration].[sfrhd].[Task] r
        on r.[Metazoa_External_ID__c] = i.[Id] 
        --and t.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_tgt as (
    select s.*
    from [SalesforceMigration].[sfrhd].[EmailMessage] s (nolock)
    join [SalesforceMigration].[sfrhd].[Case] c
        on c.[Id] = s.[ParentId] 
    join [SalesforceMigration].[sfrhd].[Contact] ct
        on ct.[Id] = c.[AccountId] 
        --and t.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[EmailMessage] s (nolock)
    join [SalesforceMigration].[sf].[Case] c
        on c.[Id] = s.[ParentId] 
    join [SalesforceMigration].[sf].[Contact] ct
        on ct.[Id] = c.[AccountId]
        and ct.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [cte_tgt] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[BccAddress]
    ,s.[CcAddress]
    ,s.[ClientThreadIdentifier]
    ,s.[EDP_External_Id__c]
    ,s.[FirstOpenedDate]
    ,s.[FromAddress]
    ,s.[FromName]
    ,[HasAttachment] = iif(s.[HasAttachment] = 1, 'true', 'false')
    ,s.[Headers]
    ,s.[HtmlBody]
    ,[Incoming] = iif(s.[Incoming] = 1, 'true', 'false')
    ,[IsBounced] = iif(s.[IsBounced] = 1, 'true', 'false')
    ,[IsClientManaged] = iif(s.[IsClientManaged] = 1, 'true', 'false')
    ,[IsExternallyVisible] = iif(s.[IsExternallyVisible] = 1, 'true', 'false')
    ,[IsOpened] = iif(s.[IsOpened] = 1, 'true', 'false')
    ,[IsPrivateDraft] = iif(s.[IsPrivateDraft] = 1, 'true', 'false')
    ,[IsTracked] = iif(s.[IsTracked] = 1, 'true', 'false')
    ,s.[LastOpenedDate]
    ,s.[MessageDate]
    ,s.[MessageIdentifier]
    ,s.[Name]
    ,s.[Status]
    ,s.[Subject]
    ,s.[TextBody]
    ,s.[ThreadIdentifier]
    ,s.[ToAddress]
    ,s.[ValidatedFromAddress]
    ,[RelatedToId] = coalesce(a1.[Id-tgt],'')
    ,[ParentId] = coalesce(c.[Id-tgt],'')
    ,[ReplyToEmailMessageId] = coalesce(em.[Id-tgt],'')
    ,[EmailTemplateId] = coalesce(et.[Id-tgt],'')
    ,[ActivityId] = coalesce(tk.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_A1_Support_Staff_Registrations] a1
    on a1.[id-src] = s.[RelatedToId]
left join [cte_Case] c
    on c.[id-src] = s.[ParentId]
left join [cte_EmailMessage] em
    on em.[id-src] = s.[ReplyToEmailMessageId]
left join [cte_EmailTemplate] et
    on et.[id-src] = s.[EmailTemplateId]
left join [cte_Task] tk
    on tk.[id-src] = s.[ActivityId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[RelatedToId],'') is not null
and nullif(a1.[id-tgt],'') is not null)
or nullif(s.[RelatedToId],'') is null
)
and ((nullif(s.[ParentId],'') is not null
and nullif(c.[id-tgt],'') is not null)
or nullif(s.[ParentId],'') is null
)
and ((nullif(s.[ReplyToEmailMessageId],'') is not null
and nullif(em.[id-tgt],'') is not null)
or nullif(s.[ReplyToEmailMessageId],'') is null
)
and ((nullif(s.[EmailTemplateId],'') is not null
and nullif(et.[id-tgt],'') is not null)
or nullif(s.[EmailTemplateId],'') is null
)
and ((nullif(s.[ActivityId],'') is not null
and nullif(tk.[id-tgt],'') is not null)
or nullif(s.[ActivityId],'') is null
)
go
