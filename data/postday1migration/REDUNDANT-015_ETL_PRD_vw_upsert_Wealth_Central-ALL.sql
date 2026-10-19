Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Wealth_Central-ALL]
go

create view [sfrhd].[vw_upsert_Wealth_Central-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
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
    from [SalesforceMigration].[sf].[Account] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Account] r (nolock)
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
    from [SalesforceMigration].[sf].[Contact] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Contact] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] = 'Shadforth'
    where 1=1
    and i.[Licensee__c] = 'Shadforth'
)
,cte_A1_Support_Staff_Registrations as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[A1_Support_Staff_Registrations__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[A1_Support_Staff_Registrations__c] r (nolock)
        on r.[Email_Address__c] = i.[Email_Address__c]
        --and r.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_Area_of_Advice as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Area_of_Advice__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Area_of_Advice__c] r (nolock)
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
    from [SalesforceMigration].[sf].[Assurance_Review__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Assurance_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] like '%Shadforth%'
    where 1=1
    and i.[Licensee__c] like '%Shadforth%'
)
,cte_ASN_Indicator_History as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[ASN_Indicator_History__c] i (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = i.[Adviser__c]
        and c.[Licensee__c] like '%Shadforth%'
    left join [SalesforceMigration].[sfrhd].[ASN_Indicator_History__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_BusinessHours as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[BusinessHours] i (nolock)
    left join [SalesforceMigration].[sfrhd].[BusinessHours] r (nolock)
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
    from [SalesforceMigration].[sf].[Campaign] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Campaign] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    where 1=1
    and nullif(r.[Name],'') is not null
)
,cte_Case as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[CaseNumber-src] = i.[CaseNumber]
        ,[CaseNumber-tgt] = r.[CaseNumber]
    from [SalesforceMigration].[sf].[Case] i (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = i.[ContactId]
        and c.[Licensee__c] = 'Shadforth'
    left join [SalesforceMigration].[sfrhd].[Case] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    left join [SalesforceMigration].[sfrhd].[Contact] rc (nolock)
        on rc.[Id] = r.[ContactId]
        and rc.[Licensee__c] = 'Shadforth'
    where 1=1
)
,cte_Client_Service_Model_Implementation as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Client_Service_Model_Implementation__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Client_Service_Model_Implementation__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    where 1=1
)
,cte_Con_Mgt as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Consequence_Management_Forum_Entry__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Consequence_Management_Forum_Entry__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] = 'Shadforth'
    where 1=1
    and i.[Licensee__c] = 'Shadforth'
)
,cte_EmailMessage as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[EmailMessage] i (nolock)
    left join [SalesforceMigration].[sfrhd].[EmailMessage] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Name] like '%Shadforth%'
    where 1=1
    --and i.[Name] like '%Shadforth%'
)
,cte_EmailTemplate as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[EmailTemplate] i (nolock)
    left join [SalesforceMigration].[sfrhd].[EmailTemplate] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
        --and r.[Name] like '%Shadforth%'
    where 1=1
    --and i.[Name] like '%Shadforth%'
)
,cte_Group as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Group] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Group] r (nolock)
        on r.[Name] = i.[Name]
        and r.[Name] like '%Shadforth%'
    where 1=1
    and i.[Name] like '%Shadforth%'
)
,cte_Incident_File_Review as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Incident_File_Review__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Incident_File_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] = 'Shadforth'
    where 1=1
    and i.[Licensee__c] = 'Shadforth'
)
,cte_LookupName as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[LookupName__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[LookupName__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    --    and r.[Licensee__c] = 'Shadforth'
    --where 1=1
    --and i.[Licensee__c] = 'Shadforth'
)
,cte_Master_Questions as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Master_Questions__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Master_Questions__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
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
    from [SalesforceMigration].[sf].[MasterQuestions_Targetedreviews__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[MasterQuestions_Targetedreviews__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
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
    from [SalesforceMigration].[sf].[Opportunity] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Opportunity] r (nolock)
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
    from [SalesforceMigration].[sf].[Product2] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Product2] r (nolock)
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
    from [SalesforceMigration].[sf].[Pricebook2] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Pricebook2] r (nolock)
        on r.[Name] = i.[Name]
    where 1=1
    and nullif(r.[Name],'') is not null
    -- 'Shadforth Head Office Customer User' is missing in RH
)
,cte_Qualification_Type as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Qualification_Type__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Qualification_Type__c] r (nolock)
        on r.[Name] = i.[Name]
        --and i.[Licensee__c] like '%Shadforth%'
    where 1=1
    --and i.[licensee__c] like '%Shadforth%'
)
,cte_Question_Responses as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Question_Responses__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Question_Responses__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and i.[Licensee__c] like '%Shadforth%'
    where 1=1
    and i.[licensee__c] like '%Shadforth%'
)
,cte_Question_Group as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Question_Group__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Question_Group__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and i.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_RecordType as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[RecordType] i (nolock)
    left join [SalesforceMigration].[sfrhd].[RecordType] r (nolock)
        on r.[DeveloperName] = i.[DeveloperName]
        and r.[SobjectType] = i.[SobjectType]
    where 1=1
)
,cte_Registered_Training_Organisation as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Registered_Training_Organisation__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Registered_Training_Organisation__c] r (nolock)
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
    from [SalesforceMigration].[sf].[Response_Finding__c] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Response_Finding__c] r (nolock)
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
    from [SalesforceMigration].[sf].[Task] i (nolock)
    join [SalesforceMigration].[sfrhd].[Task] r
        on r.[Metazoa_External_ID__c] = i.[Id] 
        --and t.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Wealth_Central__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Wealth_Central__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Name]
    ,s.[Please_explain__c]
    ,s.[Reasons_for_not_using_WC_Components__c]
    ,s.[WC_Components_Embedded__c]
    ,[Practice__c] = coalesce(a.[Id-tgt],'')
    ,[RecordTypeId] = coalesce(rtt.[Id-tgt],'')
from cte_src s
left join [cte_Account] a
    on a.[id-src] = s.[Practice__c]
left join [cte_RecordType] rtt
    on rtt.[id-src] = s.[RecordTypeId]
where 1=1
and s.[id-tgt] is null
GO
