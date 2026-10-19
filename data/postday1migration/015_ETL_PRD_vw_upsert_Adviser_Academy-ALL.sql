Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Adviser_Academy-ALL]
go

create view [sfrhd].[vw_upsert_Adviser_Academy-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
,cte_Account as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Account] i (nolock)
    join [SalesforceMigration].[sfrhd].[Account] r (nolock)
        --on r.[Name] = replace(i.[Name],'Shadforth','Navara')
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
)
,cte_Contact as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Contact] i (nolock)
    join [SalesforceMigration].[sfrhd].[Contact] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
)
,cte_RecordType as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[RecordType] i (nolock)
    left join [SalesforceMigration].[sfrhd].[RecordType] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
        and r.[SobjectType] = i.[SobjectType]
    where 1=1
)
,cte_tgt as (
    select s.*
    from [SalesforceMigration].[sfrhd].[Adviser_Academy__c] s (nolock)
    join [SalesforceMigration].[sfrhd].[Account] t
        on t.[Id] = s.[Practice__c] 
        --and t.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Adviser_Academy__c] s (nolock)
    join [SalesforceMigration].[sf].[Account] c
        on c.[Id] = s.[Practice__c] 
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [cte_tgt] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Name]
    ,[Practice__c] = coalesce(ra.[Id-tgt],'')
    ,[Principe_contact__c] = coalesce(rcp.[Id-tgt],'')
    ,[Secondary_Contact__c] = coalesce(rcs.[Id-tgt],'')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
    ,[Advice_Coach__c] = coalesce(ruh.[Id],'')
    ,[Advice_Consultant__c] = coalesce(rus.[Id],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastActivityDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ra
    on ra.[Id-src] = s.[Practice__c]
left join [cte_Contact] rcp
    on rcp.[Id-src] = s.[Principe_contact__c]
left join [cte_Contact] rcs
    on rcs.[Id-src] = s.[Secondary_Contact__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
left join [cte_User] ruh
    on ruh.[Metazoa_External_ID__c] = s.[Advice_Coach__c]
left join [cte_User] rus
    on rus.[Metazoa_External_ID__c] = s.[Advice_Consultant__c]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Practice__c],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[Practice__c],'') is null
)
and ((nullif(s.[Principe_contact__c],'') is not null
and nullif(rcp.[id-tgt],'') is not null)
or nullif(s.[Principe_contact__c],'') is null
)
and ((nullif(s.[Secondary_Contact__c],'') is not null
and nullif(rcs.[id-tgt],'') is not null)
or nullif(s.[Secondary_Contact__c],'') is null
)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
and ((nullif(s.[Advice_Coach__c],'') is not null
and nullif(ruh.[id],'') is not null)
or nullif(s.[Advice_Coach__c],'') is null
)
and ((nullif(s.[Advice_Consultant__c],'') is not null
and nullif(rus.[id],'') is not null)
or nullif(s.[Advice_Consultant__c],'') is null
)
go
