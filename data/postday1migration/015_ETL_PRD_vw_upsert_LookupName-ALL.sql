Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_LookupName-ALL]
go

create view [sfrhd].[vw_upsert_LookupName-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
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
    from [SalesforceMigration].[sf].[LookupName__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[LookupName__c] t (nolock)
        on t.[metazoa_external_id__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Action_Required__c]
    ,s.[Issue_Identified__c]
    ,s.[Name]
    ,s.[Remediation_Timeframe__c]
    ,s.[Security_Measure__c]
    ,s.[SecurityCode__c]
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
go
