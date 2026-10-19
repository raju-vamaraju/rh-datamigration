Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_ASN_Indicator_History-ALL]
go

create view [sfrhd].[vw_upsert_ASN_Indicator_History-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
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
,cte_Assurance_Review as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Assurance_Review__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Assurance_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] like '%Shadforth%'
    where 1=1
    --and i.[Licensee__c] like '%Shadforth%'
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[ASN_Indicator_History__c] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = s.[Adviser__c]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[ASN_Indicator_History__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
    --and s.[Licensee__c] like '%Shadforth%'
and t.[Id] is null
)
select -- top 10
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[ASN__c]
    ,s.[Review_Count_or_Average__c]
    ,s.[Type__c]
    ,[Assurance_Review__c] = coalesce(rar.[Id-tgt],'')
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Assurance_Review] rar
    on rar.[Id-src] = s.[Assurance_Review__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[Assurance_Review__c],'') is not null
and nullif(rar.[id-tgt],'') is not null)
or nullif(s.[Assurance_Review__c],'') is null
)
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
go
