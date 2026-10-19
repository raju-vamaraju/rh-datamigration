Use [ADVICE_ETL_PRD]
go

--drop view if exists [sfrhd].[vw_upsert_AccountContactRelation-Shadforth]
--go

--create view [sfrhd].[vw_upsert_AccountContactRelation-Shadforth] as
with cte_User as (
    select
        u.[Id]
        ,u.[Metazoa_External_ID__c]
    from [ADVICE_ETL_PRD].[sfrhd].[User] u (nolock)
    join [ADVICE_ETL_PRD].[sfrhd].[Account] a (nolock)
        on a.[id] = u.[AccountId]
        and a.[Licensee__c] = 'Shadforth'
    where 1=1
    and u.[Metazoa_External_ID__c] is not null
)
,cte_Account as (
    --select
    --    [Id]
    --    ,[Metazoa_External_ID__c]
    --from [ADVICE_ETL_PRD].[sfrhd].[Account] (nolock)
    --where 1=1
    --and [Metazoa_External_ID__c] is not null
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Account] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Account] r (nolock)
        --on r.[Name] = replace(i.[Name],'Shadforth','Navara')
        --on r.[Name] = i.[Name]
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] = 'Shadforth'
    where 1=1
    and i.[Licensee__c] = 'Shadforth'
)
,cte_Contact as (
    --select
    --    [Id]
    --    ,[Metazoa_External_ID__c]
    --from [ADVICE_ETL_PRD].[sfrhd].[Contact] (nolock)
    --where 1=1
    --and [Metazoa_External_ID__c] is not null
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Contact] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Contact] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] = 'Shadforth'
    where 1=1
    and i.[Licensee__c] = 'Shadforth'
)
,cte_RecordType as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[RecordType] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[RecordType] r (nolock)
        on r.[Name] = i.[Name]
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [ADVICE_ETL_PRD].[sf].[AccountContactRelation] s (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[AccountContactRelation] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
        and t.[Licensee__c] = 'Shadforth'
    where 1=1
    and s.[Licensee__c] like 'Shadforth'
)
select -- top 1
    [Id] = s.[Id-tgt]
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Comments__c]
    ,s.[EDP_External_Id__c]
    ,s.[Email__c]
    ,s.[EndDate]
    ,[IsActive] = iif(s.[IsActive] = 1, 'true', 'false')
    ,[IsDirect] = iif(s.[IsDirect] = 1, 'true', 'false')
    ,s.[Metazoa_External_ID__c]
    ,s.[Relationship_Strength__c]
    ,s.[Roles]
    ,s.[StartDate]
    ,s.[Status__c]
    ,[AccountId] = coalesce(x.[Id-tgt],'')
    ,[ContactId] = coalesce(x.[Id-tgt],'')
from cte_src s
left join [cte_RecordType] rrt
    on rrt.[id-src] = s.[RecordTypeId]
left join [cte_Account] ram
    on ram.[id-src] = s.[MasterRecordId]
left join [cte_User] rus
    on rus.[Metazoa_External_ID__c] = s.[Licensee_Supervisor__c]
left join [cte_User] ruc
    on ruc.[Metazoa_External_ID__c] = s.[Licensee_Consultant__c]
go
