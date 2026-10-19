Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_EventRelation-ALL]
go

create view [sfrhd].[vw_upsert_EventRelation-ALL] as
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
,cte_Event as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Subject-src] = i.[Subject]
        ,[Subject-tgt] = r.[Subject]
    from [SalesforceMigration].[sf].[Event] i (nolock)
    join [SalesforceMigration].[sfrhd].[Event] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_tgt as (
    select s.*
        ,[AccountId-src] = t.[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[EventRelation] s (nolock)
    join [SalesforceMigration].[sfrhd].[Account] t (nolock)
        on t.[Id] = s.[AccountId]
        and t.[Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
        ,[ContactId-src] = c.[Id]
    from [SalesforceMigration].[sf].[EventRelation] s (nolock)
    join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = s.[AccountId]
        and a.[Licensee__c] in ('Bridges', 'Shadforth')
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = s.[RelationId]
    left join [cte_tgt] t (nolock)
        on t.[AccountId-src] = s.[AccountId]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[IsInvitee] = iif(s.[IsInvitee] = 1, 'true', 'false')
    ,[IsParent] = iif(s.[IsParent] = 1, 'true', 'false')
    ,[IsWhat] = iif(s.[IsWhat] = 1, 'true', 'false')
    ,s.[RespondedDate]
    ,s.[Response]
    ,s.[Status]
    ,[RelationId] = coalesce(rc.[Id-tgt],'')
    ,[AccountId] = coalesce(ra.[Id-tgt],'')
    ,[EventId] = coalesce(re.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ra
    on ra.[Id-src] = s.[AccountId]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[RelationId]
left join [cte_Event] re
    on re.[Id-src] = s.[EventId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[AccountId],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[AccountId],'') is null
)
and ((nullif(s.[RelationId],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[RelationId],'') is null
)
and ((nullif(s.[EventId],'') is not null
and nullif(re.[id-tgt],'') is not null)
or nullif(s.[EventId],'') is null
)
go
