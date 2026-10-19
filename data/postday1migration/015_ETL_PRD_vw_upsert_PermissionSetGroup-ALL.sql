Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_PermissionSetGroup-ALL]
go

create view [sfrhd].[vw_upsert_PermissionSetGroup-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[PermissionSetGroup] s (nolock)
    left join [SalesforceMigration].[sfrhd].[PermissionSetGroup] t (nolock)
        on t.[DeveloperName] = s.[DeveloperName]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Description]
    ,s.[DeveloperName]
    ,[HasActivationRequired] = iif(s.[HasActivationRequired] = 1, 'true', 'false')
    ,s.[Language]
    ,s.[MasterLabel]
    ,s.[NamespacePrefix]
    ,s.[Status]
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
go
