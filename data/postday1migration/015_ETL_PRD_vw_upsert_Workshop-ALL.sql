Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Workshop-ALL]
go

create view [sfrhd].[vw_upsert_Workshop-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
,cte_Adviser_Academy as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Adviser_Academy__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Adviser_Academy__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_Master_Workshop as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Master_Workshop__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Master_Workshop__c] r (nolock)
        on r.[Name] = i.[Name]
    where 1=1
    and nullif(r.[Name],'') is not null
    -- 'Shadforth Head Office Customer User' is missing in RH
)
,cte_RecordType as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[RecordType] i (nolock)
    join [SalesforceMigration].[sfrhd].[RecordType] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
        and r.[SobjectType] = i.[SobjectType]
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Workshop__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Workshop__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Name]
    ,s.[Type_of_Workshop__c]
    ,s.[UniqueMasterWorkshopAA__c]
    ,s.[Workshop_Attended_Date__c]
    ,[Adviser_Academy__c] = coalesce(aa.[Id-tgt],'')
    ,[Workshop__c] = coalesce(mw.[Id-tgt],'')
    ,[RecordTypeId] = coalesce(rtt.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Adviser_Academy] aa
    on aa.[id-src] = s.[Adviser_Academy__c]
left join [cte_Master_Workshop] mw
    on mw.[id-src] = s.[Workshop__c]
left join [cte_RecordType] rtt
    on rtt.[id-src] = s.[RecordTypeId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Adviser_Academy__c],'') is not null
and nullif(aa.[id-tgt],'') is not null)
or nullif(s.[Adviser_Academy__c],'') is null
)
and ((nullif(s.[Workshop__c],'') is not null
and nullif(mw.[id-tgt],'') is not null)
or nullif(s.[Workshop__c],'') is null
)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rtt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
go
