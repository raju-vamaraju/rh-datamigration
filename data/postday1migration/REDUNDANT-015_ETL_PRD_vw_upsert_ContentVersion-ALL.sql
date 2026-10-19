Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_ContentVersion-ALL]
go

create view [sfrhd].[vw_upsert_ContentVersion-ALL] as
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
,cte_tgt as (
    select s.*
    from [SalesforceMigration].[sfrhd].[ContentVersion] s (nolock)
    --join [SalesforceMigration].[sfrhd].[Contact] t
    --    on t.[Id] = s.[Adviser__c] 
        --and t.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_src as (
    select s.*
        --,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[ContentVersion] s (nolock)
    left join [SalesforceMigration].[sf].[Case] cs (nolock)
        on cs.[Id] = s.[Case__c]
    left join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = cs.[ContactId]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [cte_tgt] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
,s.[Checksum]
,s.[ContentLocation]
,s.[ContentModifiedDate]
,s.[ContentSize]
,s.[ContentUrl]
,s.[Description]
,s.[EDP_External_Id__c]
,s.[ExternalDocumentInfo1]
,s.[ExternalDocumentInfo2]
,s.[FeaturedContentBoost]
,s.[FeaturedContentDate]
,s.[FileExtension]
,s.[FileType]
,[IsAssetEnabled] = iif(s.[IsAssetEnabled] = 1, 'true', 'false')
,[IsEncrypted] = iif(s.[IsEncrypted] = 1, 'true', 'false')
,[IsLatest] = iif(s.[IsLatest] = 1, 'true', 'false')
,[IsMajorVersion] = iif(s.[IsMajorVersion] = 1, 'true', 'false')
,s.[Language]
,s.[Metazoa_External_ID__c]
,s.[NegativeRatingCount]
,s.[Origin]
,s.[PathOnClient]
,s.[PositiveRatingCount]
,s.[PublishStatus]
,s.[RatingCount]
,s.[ReasonForChange]
,s.[SharingOption]
,s.[SharingPrivacy]
,s.[TagCsv]
,s.[TextPreview]
,s.[Title]
,s.[VersionData]
,s.[VersionDataUrl]
,s.[VersionNumber]
,[FirstPublishLocationId] = coalesce(x.[Id-tgt],'')
,[ContentBodyId] = coalesce(x.[Id-tgt],'')
,[ContentDocumentId] = coalesce(x.[Id-tgt],'')
,[ExternalDataSourceId] = coalesce(x.[Id-tgt],'')
,[NetworkId] = coalesce(x.[Id-tgt],'')
,[ContentModifiedById] = coalesce(x.[Id-tgt],'')
    ,[Case__c] = coalesce(rc.[Id-tgt],'')
from cte_src s
left join [cte_A1_Support_Staff_Registrations] ra
    on ra.[Id-src] = s.[FirstPublishLocationId]
left join [cte_Case] rc
    on rc.[Id-src] = s.[Case__c]
where 1=1
and s.[id-tgt] is null
go
