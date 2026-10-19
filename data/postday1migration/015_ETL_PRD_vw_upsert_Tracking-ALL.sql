Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Tracking-ALL]
go

create view [sfrhd].[vw_upsert_Tracking-ALL] as
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
,cte_Target as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Target__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Target__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Tracking__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Tracking__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Comments__c]
    ,s.[Date__c]
    ,s.[End_Date__c]
    ,s.[Hrs__c]
    ,s.[Name]
    ,s.[Start_date__c]
    ,s.[TrackingUniqueKey__c]
    ,s.[Type__c]
    ,[RecordTypeId] = coalesce(rtt.[Id-tgt],'')
    ,[Target__c] = coalesce(tg.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_RecordType] rtt
    on rtt.[id-src] = s.[RecordTypeId]
left join [cte_Target] tg
    on tg.[id-src] = s.[Target__c]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rtt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
and ((nullif(s.[Target__c],'') is not null
and nullif(tg.[id-tgt],'') is not null)
or nullif(s.[Target__c],'') is null
)
go
