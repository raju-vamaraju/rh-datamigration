Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_AdviserHUB_Wave_Definition-ALL]
go

create view [sfrhd].[vw_upsert_AdviserHUB_Wave_Definition-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
,cte_tgt as (
    select s.*
    from [SalesforceMigration].[sfrhd].[AdviserHUB_Wave_Definition__c] s (nolock)
    join [SalesforceMigration].[sfrhd].[User] t
        on t.[Id] = s.[User__c] 
        --and t.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[AdviserHUB_Wave_Definition__c] s (nolock)
    join [SalesforceMigration].[sf].[User] c
        on c.[Id] = s.[User__c] 
        and c.[AdviserONE_Licensee__c] in ('Bridges', 'Shadforth')
    left join [cte_tgt] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[App__c]
    ,s.[Area__c]
    ,s.[Asset_Type__c]
    ,s.[Dashboard_Name__c]
    ,s.[Name]
    ,s.[RECORD_ID__c]
    ,[User__c] = coalesce(ru.[Id],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
join [cte_User] ru
    on ru.[Metazoa_External_ID__c] = s.[User__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[User__c],'') is not null
and nullif(ru.[id],'') is not null)
or nullif(s.[User__c],'') is null
)
go
