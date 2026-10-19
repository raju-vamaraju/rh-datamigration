Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_CommPay_Supplier-ALL]
go

create view [sfrhd].[vw_upsert_CommPay_Supplier-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
,cte_ThirdPartyProvider as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Third_Party_Provider_Name__c]
        ,[Name-tgt] = r.[Third_Party_Provider_Name__c]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Third_Party_Provider__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Third_Party_Provider__c] r (nolock)
        on r.[Third_Party_Provider_Name__c] = i.[Third_Party_Provider_Name__c]
        and r.[Email_Address_1__c] = i.[Email_Address_1__c]
    where 1=1
    and nullif(r.[Name],'') is not null
    -- 'Shadforth Head Office Customer User' is missing in RH
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[CommPay_Supplier__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[CommPay_Supplier__c] t (nolock)
        on t.[CommPay_Supplier_Name__c] = s.[CommPay_Supplier_Name__c]
        --and t.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 1
    [Id] = s.[Id-tgt]
    ,s.[CommPay_Supplier_Name__c]
    ,s.[Licensee__c]
    ,s.[Name]
    ,[Third_Party_Provider__c] = coalesce(rtpp.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_ThirdPartyProvider] rtpp
    on rtpp.[Id-src] = s.[Third_Party_Provider__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[Third_Party_Provider__c],'') is not null
and nullif(rtpp.[id-tgt],'') is not null)
or nullif(s.[Third_Party_Provider__c],'') is null
)
go
