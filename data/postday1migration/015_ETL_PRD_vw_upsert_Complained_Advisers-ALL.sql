Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Complained_Advisers-ALL]
go

create view [sfrhd].[vw_upsert_Complained_Advisers-ALL] as
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
,cte_tgt as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sfrhd].[Complained_Advisers__c] s (nolock)
    join [SalesforceMigration].[sfrhd].[Contact] t (nolock)
        on t.[Id] = s.[Adviser__c]
        and t.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Complained_Advisers__c] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = s.[Adviser__c]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [cte_tgt] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[EDP_External_Id__c]
    ,s.[Name]
    ,[Case__c] = coalesce(ra.[Id-tgt],'')
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
,[Review__c] = coalesce(ra.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Case] ra
    on ra.[Id-src] = s.[Case__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Case__c],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[Case__c],'') is null
)
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
go
