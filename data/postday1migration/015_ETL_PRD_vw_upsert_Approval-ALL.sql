Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Approval-ALL]
go

create view [sfrhd].[vw_upsert_Approval-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_Opportunity as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Opportunity] i (nolock)
    join [SalesforceMigration].[sfrhd].[Opportunity] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] in ('Bridges', 'Shadforth')     -- not needed
    where 1=1
--and i.[Id] = '0066F00001BxpJMQAZ'
    --and i.[Licensee__c] in ('Bridges', 'Shadforth')
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Approval__c] s (nolock)
    --join [SalesforceMigration].[sf].[User] u (nolock)
    --    on u.[Id] = s.[Approver__c]
    --join [SalesforceMigration].[sf].[Account] c (nolock)
    --    on c.[Id] = u.[AccountId]
    --    and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Approval__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Approval_Decision__c]
    ,s.[Comments__c]
    ,s.[Decision_Date__c]
    ,s.[EDP_External_Id__c]
    ,s.[Name]
    ,[Onboarding_Offboarding_Application__c] = coalesce(ro.[Id-tgt],'')
    ,[Approver__c] = coalesce(rua.[Id],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Opportunity] ro
    on ro.[Id-src] = s.[Onboarding_Offboarding_Application__c]
left join [cte_User] rua
    on rua.[Metazoa_External_ID__c] = s.[Approver__c]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[Onboarding_Offboarding_Application__c],'') is not null
and nullif(ro.[id-tgt],'') is not null)
or nullif(s.[Onboarding_Offboarding_Application__c],'') is null
)
and ((nullif(s.[Approver__c],'') is not null
and nullif(rua.[id],'') is not null)
or nullif(s.[Approver__c],'') is null
)
go
