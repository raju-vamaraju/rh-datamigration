Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Product_Questions-ALL]
go

create view [sfrhd].[vw_upsert_Product_Questions-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Master_Questions as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Master_Questions__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Master_Questions__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Name] like '%Shadforth%'
    where 1=1
    --and i.[Name] like '%Shadforth%'
)
,cte_Product2 as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Product2] i (nolock)
    join [SalesforceMigration].[sfrhd].[Product2] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Product_Questions__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Product_Questions__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[EDP_External_Id__c]
    ,s.[ExternalID__c]
    ,s.[Name]
    ,[Master_Question__c] = coalesce(mq.[Id-tgt],'')
    ,[Product__c] = coalesce(p.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Master_Questions] mq
    on mq.[id-src] = s.[Master_Question__c]
left join [cte_Product2] p
    on p.[id-src] = s.[Product__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Master_Question__c],'') is not null
and nullif(mq.[id-tgt],'') is not null)
or nullif(s.[Master_Question__c],'') is null
)
and ((nullif(s.[Product__c],'') is not null
and nullif(p.[id-tgt],'') is not null)
or nullif(s.[Product__c],'') is null
)
go
