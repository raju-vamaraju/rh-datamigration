Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_PermissionSetAssignment-Internal]
go

create view [sfrhd].[vw_upsert_PermissionSetAssignment-Internal] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_ps as (
    select [Id-src] = s.[Id]
        ,[Id-tgt] = t.[Id]
        ,[Name-src] = s.[Name]
        ,[Name-tgt] = t.[Name]
    from [SalesforceMigration].[sf].[PermissionSet] s (nolock)
    join [SalesforceMigration].[sfrhd].[PermissionSet] t (nolock)
        on t.[Name] = s.[Name]
)
,cte_psg as (
    select [Id-src] = s.[Id]
        ,[Id-tgt] = t.[Id]
        ,[Name-src] = s.[DeveloperName]
        ,[Name-tgt] = t.[DeveloperName]
    from [SalesforceMigration].[sf].[PermissionSetGroup] s (nolock)
    join [SalesforceMigration].[sfrhd].[PermissionSetGroup] t (nolock)
        on t.[DeveloperName] = s.[DeveloperName]
)
,cte_tgt as (
    select [Id] = s.[Id]
        ,[PermissionSetId-src] = ps.[Id-src]
        ,[PermissionSetId-tgt] = ps.[Id-tgt]
        ,[PermissionSetGroupId-src] = psg.[Id-src]
        ,[PermissionSetGroupId-tgt] = psg.[Id-tgt]
        ,[AssigneeId-src] = u.[Metazoa_External_ID__c]
        ,[AssigneeId-tgt] = u.[Id]
    from [SalesforceMigration].[sfrhd].[PermissionSetAssignment] s (nolock)
    join [cte_ps] ps (nolock)
        on ps.[Id-tgt] = s.[PermissionSetId]
    left join [cte_psg] psg (nolock)
        on psg.[Id-tgt] = s.[PermissionSetGroupId]
    join [SalesforceMigration].[sfrhd].[User] u (nolock)
        on u.[Id] = s.[AssigneeId]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[PermissionSetAssignment] s (nolock)
    join [SalesforceMigration].[sf].[User] u (nolock)
        on u.[Id] = s.[AssigneeId]
        and (u.[Licensee__c] like '%Bridges%'
        or u.[Licensee__c] like '%Shadforth%'
        )
    left join [cte_tgt] t (nolock)
        on t.[PermissionSetId-src] = s.[PermissionSetId]
        and t.[PermissionSetGroupId-src] = s.[PermissionSetGroupId]
        and t.[AssigneeId-src] = s.[AssigneeId]
    where 1=1
    and u.[AccountId] is null
    and u.[ContactId] is null
and (1=0
or u.[Name] like 'Lisa%Ng%Maharjan%'
or u.[Name] like 'anita%huang'
or u.[Name] like 'Chloe%Cerchiara'
or u.[Name] like 'Saga%Chandab'
or u.[Name] like 'Emma%Adolph'
)
    and s.[IsActive] = 1
    and s.[IsRevoked] = 0
and t.[Id] is null
)
select -- top 10
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[ExpirationDate]
    ,[IsActive] = iif(s.[IsActive] = 1, 'true', 'false')
    ,[IsRevoked] = iif(s.[IsRevoked] = 1, 'true', 'false')
    --,[PermissionSetId] = iif(coalesce(psg.[Id-tgt],'') is null, coalesce(ps.[Id-tgt],''),s.[PermissionSetId]+'+')
    ,[PermissionSetId] = iif(coalesce(psg.[Id-tgt],'') is null, coalesce(ps.[Id-tgt],''),'')
    ,[PermissionSetGroupId] = coalesce(psg.[Id-tgt],s.[PermissionSetGroupId]+'+')
    ,[AssigneeId] = coalesce(u.[Id],s.[AssigneeId]+'+')
from cte_src s
left join [cte_ps] ps
    on ps.[Id-src] = s.[PermissionSetId]
left join [cte_psg] psg
    on psg.[Id-src] = s.[PermissionSetGroupId]
left join [cte_User] u
    on u.[Metazoa_External_ID__c] = s.[AssigneeId]
where 1=1
and ((nullif(s.[PermissionSetId],'') is not null
and nullif(ps.[id-tgt],'') is not null)
or nullif(s.[PermissionSetId],'') is null
)
and ((nullif(s.[PermissionSetGroupId],'') is not null
and nullif(psg.[id-tgt],'') is not null)
or nullif(s.[PermissionSetGroupId],'') is null
)
and ((nullif(s.[AssigneeId],'') is not null
and nullif(u.[id],'') is not null)
or nullif(s.[AssigneeId],'') is null
)
and psg.[Id-tgt] is not null
go
