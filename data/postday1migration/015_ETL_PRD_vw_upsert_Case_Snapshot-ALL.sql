Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Case_Snapshot-ALL]
go

create view [sfrhd].[vw_upsert_Case_Snapshot-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
,cte_Case as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[CaseNumber-src] = i.[CaseNumber]
        ,[CaseNumber-tgt] = r.[CaseNumber]
    from [SalesforceMigration].[sf].[Case] i (nolock)
    join [SalesforceMigration].[sfrhd].[Case] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    where 1=1
)
,cte_src1 as (
    select s.*
    from [SalesforceMigration].[sf].[Case] s (nolock)
    join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = s.[Practice_Name__c]
        and a.[Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_src2 as (
    select s.*
    from [SalesforceMigration].[sf].[Case] s (nolock)
    join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = s.[AccountId]
        and a.[Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_src3 as (
    select s.*
    from [SalesforceMigration].[sf].[Case] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = s.[ContactId]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_all as (
    select [Id] from [cte_src1]
    union
    select [Id] from [cte_src2]
    union
    select [Id] from [cte_src3]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Case_Snapshot__c] s (nolock)
    join [cte_all] a (nolock)
        on a.[Id] = s.[Case__c]
    left join [SalesforceMigration].[sfrhd].[Case_Snapshot__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Case_Type__c]
    ,s.[EDP_External_Id__c]
    ,s.[Name]
    ,s.[Schedule_Date__c]
    ,s.[Schedule_Type__c]
    ,s.[Status__c]
    ,[Case__c] = coalesce(rc.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Case] rc
    on rc.[Id-src] = s.[Case__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[Case__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Case__c],'') is null
)
GO
