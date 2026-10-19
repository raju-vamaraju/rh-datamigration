Use [ADVICE_ETL_PRD]
go

drop view if exists [sfrhd].[vw_upsert_GroupMember-Shadforth]
go

create view [sfrhd].[vw_upsert_GroupMember-Shadforth] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [ADVICE_ETL_PRD].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    and [Licensee__c] = 'Shadforth'
)
,cte_Account as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Account] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Account] r (nolock)
        --on r.[Name] = replace(i.[Name],'Shadforth','Navara')
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] = 'Shadforth'
    where 1=1
    and i.[Licensee__c] = 'Shadforth'
)
,cte_Contact as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Contact] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Contact] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] = 'Shadforth'
    where 1=1
    and i.[Licensee__c] = 'Shadforth'
)
,cte_Assurance_Review as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Assurance_Review__c] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Assurance_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] like '%Shadforth%'
    where 1=1
    and i.[Licensee__c] like '%Shadforth%'
)
,cte_BusinessHours as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [ADVICE_ETL_PRD].[sf].[BusinessHours] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[BusinessHours] r (nolock)
        on r.[Name] = i.[Name]
    where 1=1
    and nullif(r.[Name],'') is not null
)
,cte_Campaign as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Campaign] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Campaign] r (nolock)
        on r.[Name] = i.[Name]
    where 1=1
    and nullif(r.[Name],'') is not null
)
,cte_Case as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[CaseNumber-src] = i.[CaseNumber]
        ,[CaseNumber-tgt] = r.[CaseNumber]
    from [ADVICE_ETL_PRD].[sf].[Case] i (nolock)
    join [ADVICE_ETL_PRD].[sf].[Contact] c (nolock)
        on c.[Id] = i.[ContactId]
        and c.[Licensee__c] = 'Shadforth'
    left join [ADVICE_ETL_PRD].[sfrhd].[Case] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    left join [ADVICE_ETL_PRD].[sfrhd].[Contact] rc (nolock)
        on rc.[Id] = r.[ContactId]
        and rc.[Licensee__c] = 'Shadforth'
    where 1=1
)
,cte_Con_Mgt as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Consequence_Management_Forum_Entry__c] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Consequence_Management_Forum_Entry__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] = 'Shadforth'
    where 1=1
    and i.[Licensee__c] = 'Shadforth'
)
,cte_Group as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Group] i (nolock)
    join [ADVICE_ETL_PRD].[sfrhd].[Group] r (nolock)
        on r.[Name] = i.[Name]
        and r.[Name] like '%Shadforth%'
    where 1=1
    and i.[Name] like '%Shadforth%'
)
,cte_Opportunity as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Opportunity] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Opportunity] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] = 'Shadforth'
    where 1=1
    and i.[Licensee__c] = 'Shadforth'
)
,cte_Product2 as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Product2] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Product2] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
)
,cte_PriceBook2 as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Pricebook2] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Pricebook2] r (nolock)
        on r.[Name] = i.[Name]
    where 1=1
    and nullif(r.[Name],'') is not null
    -- 'Shadforth Head Office Customer User' is missing in RH
)
,cte_Question_Responses as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Question_Responses__c] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Question_Responses__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and i.[Licensee__c] like '%Shadforth%'
    where 1=1
    and i.[licensee__c] like '%Shadforth%'
)
,cte_RecordType as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [ADVICE_ETL_PRD].[sf].[RecordType] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[RecordType] r (nolock)
        on r.[Name] = i.[Name]
    where 1=1
    and nullif(r.[Name],'') is not null
    -- 'Shadforth Head Office Customer User' is missing in RH
)
,cte_tgt as (
    select s.*
        ,[GroupId-src] = ig.[Id]
        ,[UserOrGroupId-src] = u.[Metazoa_External_ID__c]
    from [ADVICE_ETL_PRD].[sfrhd].[GroupMember] s (nolock)
    join [ADVICE_ETL_PRD].[sfrhd].[User] u (nolock)
        on u.[Id] = s.[UserOrGroupId]
        and u.[AdviserONE_Licensee__c] like '%Shadforth%'
    join [ADVICE_ETL_PRD].[sfrhd].[Group] g (nolock)
        on g.[id] = s.[GroupId]
    join [ADVICE_ETL_PRD].[sf].[Group] ig (nolock)
        on ig.[DeveloperName] = g.[DeveloperName]
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [ADVICE_ETL_PRD].[sf].[GroupMember] s (nolock)
    join [ADVICE_ETL_PRD].[sf].[User] u (nolock)
        on u.[Id] = s.[UserOrGroupId]
    join [ADVICE_ETL_PRD].[sf].[Contact] c
        on c.[Id] = u.[ContactId] 
        and c.[Licensee__c] like '%Shadforth%'
    left join [cte_tgt] t (nolock)
        on t.[GroupId-src] = s.[GroupId]
        and t.[UserOrGroupId-src] = s.[UserOrGroupId]
    where 1=1
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[UserOrGroupId] = coalesce(ru.[Id],'')
    ,[GroupId] = coalesce(rg.[Id-tgt],'')
from cte_src s
join [cte_Group] rg
    on rg.[Id-src] = s.[GroupId]
join [cte_User] ru
    on ru.[Metazoa_External_ID__c] = s.[UserOrGroupId]
where 1=1
go
