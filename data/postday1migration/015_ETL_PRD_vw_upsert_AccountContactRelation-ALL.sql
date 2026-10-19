Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_AccountContactRelation-ALL]
go

create view [sfrhd].[vw_upsert_AccountContactRelation-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Account as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Account] i (nolock)
    join [SalesforceMigration].[sfrhd].[Account] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
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
)
,cte_tgt as (
    select
        r.[Id]
        ,r.[Metazoa_External_ID__c]
        ,[AccountId-src] = a.[Metazoa_External_ID__c]
        ,[AccountId-tgt] = r.[AccountId]
        ,[ContactId-src] = c.[Metazoa_External_ID__c]
        ,[ContactId-tgt] = r.[ContactId]
        ,r.[Licensee__c]
    from [SalesforceMigration].[sfrhd].[AccountContactRelation] r (nolock)
    join [SalesforceMigration].[sfrhd].[Contact] c (nolock)
        on c.[Id] = r.[ContactId]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    join [SalesforceMigration].[sfrhd].[Account] a (nolock)
        on a.[Id] = r.[AccountId]
        and a.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    and r.[Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[AccountContactRelation] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = s.[ContactId]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = s.[AccountId]
        and a.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [cte_tgt] t (nolock)
        on t.[AccountId-src] = s.[AccountId]
        and t.[ContactId-src] = s.[ContactId]
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Comments__c]
    ,s.[EDP_External_Id__c]
    ,s.[Email__c]
    ,s.[EndDate]
    ,[IsActive] = iif(s.[IsActive] = 1, 'true', 'false')
    ,[IsDirect] = iif(s.[IsDirect] = 1, 'true', 'false')
    ,s.[Relationship_Strength__c]
    ,s.[Roles]
    ,s.[StartDate]
    ,s.[Status__c]
    ,[AccountId] = coalesce(ram.[Id-tgt],'')
    ,[ContactId] = coalesce(rc.[Id-tgt],'')
,[CreatedById] = u2.[Id]
,[LastModifiedById] = u3.[Id]
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ram
    on ram.[Id-src] = s.[AccountId]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[ContactId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[AccountId],'') is not null
and nullif(ram.[id-tgt],'') is not null)
or nullif(s.[AccountId],'') is null
)
and ((nullif(s.[ContactId],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[ContactId],'') is null
)
go
