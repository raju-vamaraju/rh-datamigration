Use [ADVICE_ETL_PRD]
go

drop view if exists [sfrhd].[vw_upsert_TaskRelation-Shadforth]
go

create view [sfrhd].[vw_upsert_TaskRelation-Shadforth] as
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
,cte_Area_of_Advice as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sfrhd].[Area_of_Advice__c] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Area_of_Advice__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] like '%Shadforth%'
    where 1=1
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
--,cte_ASN_Indicator_History as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--    from [ADVICE_ETL_PRD].[sf].[ASN_Indicator_History__c] i (nolock)
--    left join [ADVICE_ETL_PRD].[sfrhd].[ASN_Indicator_History__c] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--        and r.[Licensee__c] like '%Shadforth%'
--    where 1=1
--    and i.[Licensee__c] like '%Shadforth%'
--)
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
    left join [ADVICE_ETL_PRD].[sfrhd].[Group] r (nolock)
        on r.[Name] = i.[Name]
        and r.[Name] like '%Shadforth%'
    where 1=1
    and i.[Name] like '%Shadforth%'
)
,cte_Master_Questions as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Master_Questions__c] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Master_Questions__c] r (nolock)
        on r.[Name] = i.[Name]
        --and r.[Name] like '%Shadforth%'
    where 1=1
    --and i.[Name] like '%Shadforth%'
)
,cte_MasterQuestions_Targetedreviews as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [ADVICE_ETL_PRD].[sf].[MasterQuestions_Targetedreviews__c] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[MasterQuestions_Targetedreviews__c] r (nolock)
        on r.[Name] = i.[Name]
        --and r.[Name] like '%Shadforth%'
    where 1=1
    --and i.[Name] like '%Shadforth%'
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
,cte_Qualification_Type as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Qualification_Type__c] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Qualification_Type__c] r (nolock)
        on r.[Name] = i.[Name]
        --and i.[Licensee__c] like '%Shadforth%'
    where 1=1
    --and i.[licensee__c] like '%Shadforth%'
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
,cte_Registered_Training_Organisation as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Registered_Training_Organisation__c] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Registered_Training_Organisation__c] r (nolock)
        on r.[Name] = i.[Name]
        --and i.[Licensee__c] like '%Shadforth%'
    where 1=1
    --and i.[licensee__c] like '%Shadforth%'
)
,cte_Response_Finding as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [ADVICE_ETL_PRD].[sf].[Response_Finding__c] i (nolock)
    left join [ADVICE_ETL_PRD].[sfrhd].[Response_Finding__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id] 
        --and i.[Licensee__c] like '%Shadforth%'
    where 1=1
    --and i.[licensee__c] like '%Shadforth%'
)
,cte_Task as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Task_Number__c]
        ,[Name-tgt] = r.[Task_Number__c]
        ,r.[Task_Number__c]
    from [ADVICE_ETL_PRD].[sf].[Task] i (nolock)
    join [ADVICE_ETL_PRD].[sfrhd].[Task] r
        on r.[Metazoa_External_ID__c] = i.[Id] 
        --and t.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_tgt as (
    select s.*
        ,[AccountId-src] = t.[Metazoa_External_ID__c]
    from [ADVICE_ETL_PRD].[sfrhd].[TaskRelation] s (nolock)
    join [ADVICE_ETL_PRD].[sfrhd].[Account] t
        on t.[Id] = s.[AccountId] 
        and t.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [ADVICE_ETL_PRD].[sf].[TaskRelation] s (nolock)
    join [ADVICE_ETL_PRD].[sf].[Account] c
        on c.[Id] = s.[AccountId] 
        and c.[Licensee__c] like '%Shadforth%'
    left join [cte_tgt] t (nolock)
        on t.[AccountId-src] = s.[AccountId]
    where 1=1
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
--    ,[Metazoa_External_ID__c] = s.[Id]
    ,[IsWhat] = iif(s.[IsWhat] = 1, 'true', 'false')
    ,[RelationId] = ''  -- coalesce(x.[Id-tgt],'')
    ,[AccountId] = coalesce(ra.[Id-tgt],'')
    ,[TaskId] = coalesce(rt.[Id-tgt],'')
from cte_src s
left join [cte_Account] ra
    on ra.[Id-src] = s.[AccountId]
left join [cte_Task] rt
    on rt.[Id-src] = s.[TaskId]
go
