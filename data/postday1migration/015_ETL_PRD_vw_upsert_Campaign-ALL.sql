Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Campaign-ALL]
go

create view [sfrhd].[vw_upsert_Campaign-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Campaign as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Campaign] i (nolock)
    join [SalesforceMigration].[sfrhd].[Campaign] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_RecordType as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[RecordType] i (nolock)
    join [SalesforceMigration].[sfrhd].[RecordType] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
        and r.[SobjectType] = i.[SobjectType]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Campaign] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Campaign] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[ActualCost]
    ,s.[AmountAllOpportunities]
    ,s.[AmountWonOpportunities]
    ,s.[BudgetedCost]
    ,s.[Description]
    ,s.[Duration__c]
    ,s.[EndDate]
    ,s.[ExpectedResponse]
    ,s.[ExpectedRevenue]
    ,[IsActive] = iif(s.[IsActive] = 1, 'true', 'false')
    ,s.[Location__c]
    ,s.[Name]
    ,s.[NPS__c]
    ,s.[NumberOfContacts]
    ,s.[NumberOfConvertedLeads]
    ,s.[NumberOfLeads]
    ,s.[NumberOfOpportunities]
    ,s.[NumberOfResponses]
    ,s.[NumberOfWonOpportunities]
    ,s.[NumberSent]
    ,s.[Reason_for_training__c]
    ,s.[StartDate]
    ,s.[Status]
    ,s.[Topic_Area__c]
    ,s.[Total_Bridges_Attendees__c]
    ,s.[Total_Consultum_Attendees__c]
    ,s.[Total_FSP_Attendees__c]
    ,s.[Total_GPG_Attendees__c]
    ,s.[Total_Internal_Attendees__c]
    ,s.[Total_Lonsdale_Attendees__c]
    ,s.[Total_M3_Attendees__c]
    ,s.[Total_PY_Attendees__c]
    ,s.[Total_RI_Attendees__c]
    ,s.[Total_Shadforth_Attendees__c]
    ,s.[Total_TenFifty_Attendees__c]
    ,s.[Training_mode_Method_of_contact__c]
    ,s.[Training_Start_Date__c]
    ,s.[Type]
    ,[ParentId] = coalesce(rc.[Id-tgt],'')
    ,[CampaignMemberRecordTypeId] = coalesce(rrc.[Id-tgt],'')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastActivityDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Campaign] rc
    on rc.[Id-src] = s.[ParentId]
left join [cte_RecordType] rrc
    on rrc.[Id-src] = s.[CampaignMemberRecordTypeId]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
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
and ((nullif(s.[CampaignMemberRecordTypeId],'') is not null
and nullif(rrc.[id-tgt],'') is not null)
or nullif(s.[CampaignMemberRecordTypeId],'') is null
)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
go
