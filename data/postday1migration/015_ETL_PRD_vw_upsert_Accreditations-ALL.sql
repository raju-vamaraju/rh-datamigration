Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Accreditations-ALL]
go

create view [sfrhd].[vw_upsert_Accreditations-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] in ('Bridges', 'Shadforth')
)
--,cte_Account as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--    from [SalesforceMigration].[sf].[Account] i (nolock)
--    join [SalesforceMigration].[sfrhd].[Account] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--        --and r.[Licensee__c] in ('Bridges', 'Shadforth')
--    where 1=1
--    --and i.[Licensee__c] in ('Bridges', 'Shadforth')
--)
,cte_Contact as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Contact] i (nolock)
    join [SalesforceMigration].[sfrhd].[Contact] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    --and i.[Licensee__c] in ('Bridges', 'Shadforth')
)
--,cte_Assurance_Review as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--    from [SalesforceMigration].[sf].[Assurance_Review__c] i (nolock)
--    join [SalesforceMigration].[sfrhd].[Assurance_Review__c] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--        and r.[Licensee__c] like '%Shadforth%'
--    where 1=1
--    and i.[Licensee__c] like '%Shadforth%'
--)
--,cte_BusinessHours as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[BusinessHours] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[BusinessHours] r (nolock)
--        on r.[Name] = i.[Name]
--    where 1=1
--    and nullif(r.[Name],'') is not null
--)
--,cte_Campaign as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[Campaign] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[Campaign] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--    where 1=1
--    and nullif(r.[Name],'') is not null
--)
--,cte_Case as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[CaseNumber-src] = i.[CaseNumber]
--        ,[CaseNumber-tgt] = r.[CaseNumber]
--    from [SalesforceMigration].[sf].[Case] i (nolock)
--    join [SalesforceMigration].[sf].[Contact] c (nolock)
--        on c.[Id] = i.[ContactId]
--        and c.[Licensee__c] in ('Bridges', 'Shadforth')
--    left join [SalesforceMigration].[sfrhd].[Case] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--    left join [SalesforceMigration].[sfrhd].[Contact] rc (nolock)
--        on rc.[Id] = r.[ContactId]
--        and rc.[Licensee__c] in ('Bridges', 'Shadforth')
--    where 1=1
--)
--,cte_Client_File as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--    from [SalesforceMigration].[sf].[Client_File__c] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[Client_File__c] r (nolock)
--        on r.[Name] = i.[Name]
--    where 1=1
--)
--,cte_Con_Mgt as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--    from [SalesforceMigration].[sf].[Consequence_Management_Forum_Entry__c] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[Consequence_Management_Forum_Entry__c] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--        and r.[Licensee__c] in ('Bridges', 'Shadforth')
--    where 1=1
--    and i.[Licensee__c] in ('Bridges', 'Shadforth')
--)
--,cte_IFR as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[Incident_File_Review__c] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[Incident_File_Review__c] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--        and r.[Licensee__c] in ('Bridges', 'Shadforth')
--    where 1=1
--    and i.[Licensee__c] in ('Bridges', 'Shadforth')
--)
--,cte_Master_Questions as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[Master_Questions__c] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[Master_Questions__c] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--        --and r.[Licensee__c] in ('Bridges', 'Shadforth')
--    where 1=1
--    --and i.[Licensee__c] in ('Bridges', 'Shadforth')
--)
--,cte_MasterQuestions_TR as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[MasterQuestions_Targetedreviews__c] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[MasterQuestions_Targetedreviews__c] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--        --and r.[Licensee__c] in ('Bridges', 'Shadforth')
--    where 1=1
--    --and i.[Licensee__c] in ('Bridges', 'Shadforth')
--)
,cte_Product2 as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Product2] i (nolock)
    join [SalesforceMigration].[sfrhd].[Product2] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and r.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    --and i.[Licensee__c] in ('Bridges', 'Shadforth')
)
--,cte_PriceBook2 as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[Pricebook2] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[Pricebook2] r (nolock)
--        on r.[Name] = i.[Name]
--    where 1=1
--    and nullif(r.[Name],'') is not null
--    -- 'Shadforth Head Office Customer User' is missing in RH
--)
--,cte_QA as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[QA__c] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[QA__c] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--    where 1=1
--)
--,cte_RecordType as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--    from [SalesforceMigration].[sf].[RecordType] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[RecordType] r (nolock)
--        on r.[DeveloperName] = i.[DeveloperName]
--        and r.[SobjectType] = i.[SobjectType]
--    where 1=1
--)
--,cte_Vetting_Result as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[Vetting_Result__c] i (nolock)
--    left join [SalesforceMigration].[sfrhd].[Vetting_Result__c] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--    where 1=1
--    -- 'Shadforth Head Office Customer User' is missing in RH
--)
,cte_tgt as (
    select
        r.[Id]
        ,r.[Metazoa_External_ID__c]
        ,[ContactId-src] = c.[Metazoa_External_ID__c]
        ,[ContactId-tgt] = r.[Adviser__c]
        ,c.[Licensee__c]
    from [SalesforceMigration].[sfrhd].[Accreditations__c] r (nolock)
    join [SalesforceMigration].[sfrhd].[Contact] c (nolock)
        on c.[Id] = r.[Adviser__c]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    --and r.[Metazoa_External_ID__c] is null  -- records to fix
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Accreditations__c] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = s.[Adviser__c]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [cte_tgt] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 10
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Document_Received_Date__c]
    ,s.[EDP_External_Id__c]
    ,s.[Kaplan_Training_Date__c]
    ,s.[Name]
    ,s.[Product_Family__c]
    ,s.[Revoke_Date__c]
    ,s.[Start_Date__c]
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
    ,[AccreditationType__c] = coalesce(rp.[Id-tgt],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastActivityDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
left join [cte_Product2] rp
    on rp.[Id-src] = s.[AccreditationType__c]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
and ((nullif(s.[AccreditationType__c],'') is not null
and nullif(rp.[id-tgt],'') is not null)
or nullif(s.[AccreditationType__c],'') is null
)
go
