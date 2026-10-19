Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_CSO-ALL]
go

create view [sfrhd].[vw_upsert_CSO-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[CSO__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[CSO__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Activity_Achieved__c]
    ,s.[Activity_Exceed__c]
    ,s.[Activity_Partial_achieved__c]
    ,s.[Area__c]
    ,s.[Business_City__c]
    ,s.[Business_State_Province__c]
    ,s.[Business_Street__c]
    ,s.[Business_Zip_Postal_Code__c]
    ,s.[CSOStatus__c]
    ,s.[Email__c]
    ,s.[First_Name__c]
    ,s.[FTE__c]
    ,s.[Last_Name__c]
    ,s.[Mobile__c]
    ,s.[Name]
    ,s.[Preferred_Name__c]
    ,s.[Recovery_Charge_Rate__c]
    ,s.[Responsibility__c]
    ,s.[Salutation__c]
    ,s.[Team_Leader__c]
    ,s.[XPLAN_ID__c]
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
