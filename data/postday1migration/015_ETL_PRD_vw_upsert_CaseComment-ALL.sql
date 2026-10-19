Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_CaseComment-ALL]
go

create view [sfrhd].[vw_upsert_CaseComment-ALL] as
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
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[CaseComment] s (nolock)
    join [SalesforceMigration].[sf].[Case] c (nolock)
        on c.[Id] = s.[ParentId]
        and c.[Licensee_Name__c] = 'Shadforth'
    left join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = c.[Practice_Name__c]
        and a.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sf].[Account] aa (nolock)
        on aa.[Id] = c.[AccountId]
        and aa.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sf].[Contact] ct (nolock)
        on ct.[Id] = c.[ContactId]
        and ct.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Case] tc (nolock)
        on tc.[Metazoa_External_ID__c] = s.[ParentId]
    left join [SalesforceMigration].[sfrhd].[CaseComment] t (nolock)
        on t.[ParentId] = tc.[Id]
        and t.[CommentBody] = s.[CommentBody]
    where 1=1
    and coalesce(a.[Id],aa.[Id],ct.[Id]) is not null
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[CommentBody]
    ,[IsPublished] = iif(s.[IsPublished] = 1, 'true', 'false')
    ,[ParentId] = coalesce(rc.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
join [cte_Case] rc
    on rc.[Id-src] = s.[ParentId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[ParentId],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[ParentId],'') is null
)
go
