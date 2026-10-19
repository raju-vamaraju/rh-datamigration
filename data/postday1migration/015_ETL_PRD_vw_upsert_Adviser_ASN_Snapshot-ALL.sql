Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Adviser_ASN_Snapshot-ALL]
go

create view [sfrhd].[vw_upsert_Adviser_ASN_Snapshot-ALL] as
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
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Adviser_ASN_Snapshot__c] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c
        on c.[Id] = s.[Adviser__c] 
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Contact] ct (nolock)
        on ct.[Metazoa_External_ID__c] = s.[Adviser__c]
    left join [SalesforceMigration].[sfrhd].[Adviser_ASN_Snapshot__c] t (nolock)
        on t.[Adviser__c] = ct.[Id]
        and t.[Execution_Time__c] = s.[Execution_Time__c]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Adviser_ASN__c]
    ,s.[ASN_Source__c]
    ,s.[ASN_Start_Date__c]
    ,s.[Execution_Time__c]
    ,s.[Name]
    ,[Adviser__c] = coalesce(rcp.[Id-tgt],'')
,[OwnerId] = u1.[Id]
,[CreatedById] = u2.[Id]
,[LastModifiedById] = u3.[Id]
,s.[CreatedDate]
,s.[LastActivityDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Contact] rcp
    on rcp.[Id-src] = s.[Adviser__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rcp.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
go
