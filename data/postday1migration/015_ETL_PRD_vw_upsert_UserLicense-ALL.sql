Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_UserLicense-ALL]
go

create view [sfrhd].[vw_upsert_UserLicense-ALL] as
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
    from [SalesforceMigration].[sf].[UserLicense] s (nolock)
    left join [SalesforceMigration].[sfrhd].[UserLicense] t (nolock)
        on t.[Name] = s.[Name]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[LicenseDefinitionKey]
    ,s.[MasterLabel]
    ,s.[Name]
    ,s.[Status]
    ,s.[TotalLicenses]
    ,s.[UsedLicenses]
    ,s.[UsedLicensesLastUpdated]
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
where 1=1
go
