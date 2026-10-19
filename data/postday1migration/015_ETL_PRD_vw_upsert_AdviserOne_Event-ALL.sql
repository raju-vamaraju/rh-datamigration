Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_AdviserOne_Event-ALL]
go

create view [sfrhd].[vw_upsert_AdviserOne_Event-ALL] as
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
    from [SalesforceMigration].[sf].[AdviserOne_Event__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[AdviserOne_Event__c] t (nolock)
        on t.[Event_Date__c] = s.[Event_Date__c]
        and t.[Event_Time__c] = s.[Event_Time__c]
        and t.[Event_Link__c] = s.[Event_Link__c]
    where 1=1
    and s.[Licensees__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,s.[Article__c]
    ,s.[Detail_URL__c]
    ,[Display_on_Home_Page__c] = iif(s.[Display_on_Home_Page__c] = 1, 'true', 'false')
    ,s.[Display_URL__c]
    ,s.[Event_Date__c]
    ,s.[Event_Registration_Link__c]
    ,s.[Event_Summary__c]
    ,s.[Event_Time__c]
    ,s.[Event_Type__c]
    ,s.[Home_Page_Display_Expiry__c]
    ,s.[Licensees__c]
    ,s.[Licensees_Formula__c]
    ,s.[Name]
    ,s.[Provider__c]
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
