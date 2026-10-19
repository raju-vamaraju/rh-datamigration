Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Third_Party_Provider-ALL]
go

create view [sfrhd].[vw_upsert_Third_Party_Provider-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Third_Party_Provider__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Third_Party_Provider__c] t (nolock)
        on t.[Third_Party_Provider_Name__c] = s.[Third_Party_Provider_Name__c]
    where 1=1
and t.[Id] is null  -- only new records
)
select -- top 1
    s.[Email_Address_1__c]
    ,s.[Email_Address_2__c]
    ,s.[Email_Address_3__c]
    ,s.[Name]
    ,s.[Third_Party_Provider_End_Date__c]
    ,s.[Third_Party_Provider_Name__c]
    ,s.[Third_Party_Provider_Start_Date__c]
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
go
