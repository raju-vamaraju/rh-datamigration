Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Incident_File_Review-ALL]
go

create view [sfrhd].[vw_upsert_Incident_File_Review-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Account as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Account] i (nolock)
    join [SalesforceMigration].[sfrhd].[Account] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_Contact as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Contact] i (nolock)
    join [SalesforceMigration].[sfrhd].[Contact] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_Assurance_Review as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Assurance_Review__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Assurance_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and (i.[Licensee__c] like '%Bridges%' or i.[Licensee__c] like '%Shadforth%')
)
--,cte_BusinessHours as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[BusinessHours] i (nolock)
--    join [SalesforceMigration].[sfrhd].[BusinessHours] r (nolock)
--        on r.[Name] = i.[Name]
--)
--,cte_Campaign as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[Campaign] i (nolock)
--    join [SalesforceMigration].[sfrhd].[Campaign] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
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
--    join [SalesforceMigration].[sfrhd].[Case] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--    --left join [SalesforceMigration].[sfrhd].[Contact] rc (nolock)
--    --    on rc.[Id] = r.[ContactId]
--    --    and rc.[Licensee__c] in ('Bridges', 'Shadforth')
--    --where 1=1
--)
--,cte_Con_Mgt as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--    from [SalesforceMigration].[sf].[Consequence_Management_Forum_Entry__c] i (nolock)
--    join [SalesforceMigration].[sfrhd].[Consequence_Management_Forum_Entry__c] r (nolock)
--        on r.[Metazoa_External_ID__c] = i.[Id]
--    --    and r.[Licensee__c] in ('Bridges', 'Shadforth')
--    --where 1=1
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
        --and r.[Licensee__c] = 'Shadforth'
    --where 1=1
    --and i.[Licensee__c] = 'Shadforth'
)
--,cte_PriceBook2 as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--        ,r.[Name]
--    from [SalesforceMigration].[sf].[Pricebook2] i (nolock)
--    join [SalesforceMigration].[sfrhd].[Pricebook2] r (nolock)
--        on r.[Name] = i.[Name]
--    --where 1=1
--    --and nullif(r.[Name],'') is not null
--    -- 'Shadforth Head Office Customer User' is missing in RH
--)
--,cte_RecordType as (
--    select
--        [id-src] = i.[Id]
--        ,[id-tgt] = r.[Id]
--        ,[Name-src] = i.[Name]
--        ,[Name-tgt] = r.[Name]
--    from [SalesforceMigration].[sf].[RecordType] i (nolock)
--    join [SalesforceMigration].[sfrhd].[RecordType] r (nolock)
--        on r.[DeveloperName] = i.[DeveloperName]
--        and r.[SobjectType] = i.[SobjectType]
--)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Incident_File_Review__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Incident_File_Review__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 10
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[A1__c]
    ,s.[A2__c]
    ,s.[A3__c]
    ,s.[A4__c]
    ,s.[A5__c]
    ,s.[Account_Number__c]
    ,s.[Actions_Completed_to_Date__c]
    ,s.[Application_Date__c]
    ,s.[ASIC_Notification__c]
    ,s.[Client_Name__c]
    ,s.[Close_Date__c]
    ,s.[Comments__c]
    ,s.[COR_ID__c]
    ,s.[COR_Logged_Date__c]
    ,s.[COR_Status__c]
    ,s.[Date_Closed_in_COR__c]
    ,s.[Date_Occurred__c]
    ,s.[Date_of_ASIC_Notification__c]
    ,s.[Date_of_Governance_Forum_Escalation__c]
    ,s.[Date_of_Payment__c]
    ,s.[Date_of_Referral__c]
    ,s.[Date_PI_Insurer_Notified__c]
    ,s.[Discovery_Date__c]
    ,s.[EDP_External_Id__c]
    ,s.[Event_Type__c]
    ,s.[Fact_Find_Date__c]
    ,s.[Fault_Area__c]
    ,[Hidden_in_AdviserONE__c] = iif(s.[Hidden_in_AdviserONE__c] = 1, 'true', 'false')
    ,s.[Incident_Category_Field__c]
    ,s.[Incident_Description__c]
    ,s.[Incident_Title__c]
    ,s.[Incident_Type__c]
    ,s.[Is_Service_Arrangement_Documented__c]
    ,s.[Is_there_a_fee_discrepancy__c]
    ,s.[Is_there_client_authorisation_evidence__c]
    ,s.[Is_there_service_delivery_evidence__c]
    ,[Is_this_a_Major_Incident__c] = iif(s.[Is_this_a_Major_Incident__c] = 1, 'true', 'false')
    ,s.[Licensee__c]
    ,[Locked_in_AdviserONE__c] = iif(s.[Locked_in_AdviserONE__c] = 1, 'true', 'false')
    ,s.[Logged_Date__c]
    ,[Mark_as_Confidential__c] = iif(s.[Mark_as_Confidential__c] = 1, 'true', 'false')
    ,s.[Name]
    ,s.[Number_of_Clients_Impacted__c]
    ,s.[Number_of_High_issues__c]
    ,s.[Number_of_Low_issues__c]
    ,s.[Number_of_Medium_issues__c]
    ,s.[Number_of_Open_Incidents__c]
    ,s.[Partner_AFSL__c]
    ,s.[PI_Insurer_Indemnity_Status__c]
    ,s.[PI_Insurer_Notified__c]
    ,s.[PI_Reference__c]
    ,s.[Potential_Loss_in_terms__c]
    ,s.[Prior_Owner__c]
    ,s.[Product_Provider__c]
    ,s.[Professional_Indemnity_Amount__c]
    ,s.[Related_to_a_Service_Arrangement__c]
    ,s.[Relevant_Service_Period_End_Date__c]
    ,s.[Relevant_Service_Period_Start_Date__c]
    ,s.[Remediation_Due_Date__c]
    ,s.[Remediation_Provided_Date__c]
    ,s.[Report_Sent_Date__c]
    ,s.[REV__c]
    ,s.[Root_Cause__c]
    ,s.[Service_Arrangement_Type__c]
    ,s.[SOA_Date__c]
    ,s.[SOA_Produced_By__c]
    ,s.[Source__c]
    ,s.[Stage__c]
    ,s.[Submitted_Date__c]
    ,s.[Total_Number_of_Incidents__c]
    ,s.[Total_number_of_issues__c]
    ,s.[Wave_Internal__c]
    ,s.[Xplan_ID__c]
    ,[Practice__c] = coalesce(ram.[Id-tgt],'')
    ,[Assurance_Review__c] = coalesce(ras.[Id-tgt],'')
    ,[Adviser__c] = coalesce(ra.[Id-tgt],s.[Adviser__c]+'+')
    ,[Adviser_AdviserONE__c] = coalesce(rc.[Id-tgt],'')
    ,[Area_of_Advice__c] = coalesce(rp.[Id-tgt],'')
    ,[AssignedTo__c] = coalesce(ruat.[Id],'')
    ,[Licensee_Supervisor__c] = coalesce(ruls.[Id],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastActivityDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ram
    on ram.[Id-src] = s.[Practice__c]
left join [cte_Assurance_Review] ras
    on ras.[id-src] = s.[Assurance_Review__c]
left join [cte_Contact] ra
    on ra.[Id-src] = s.[Adviser__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser_AdviserONE__c]
left join [cte_Product2] rp
    on rp.[Id-src] = s.[Area_of_Advice__c]
left join [cte_User] ruls
    on ruls.[Metazoa_External_ID__c] = s.[Licensee_Supervisor__c]
left join [cte_User] ruat
    on ruat.[Metazoa_External_ID__c] = s.[AssignedTo__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[Practice__c],'') is not null
and nullif(ram.[id-tgt],'') is not null)
or nullif(s.[Practice__c],'') is null
)
and ((nullif(s.[Assurance_Review__c],'') is not null
and nullif(ras.[id-tgt],'') is not null)
or nullif(s.[Assurance_Review__c],'') is null
)
and ((nullif(s.[Adviser__c],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
and ((nullif(s.[Adviser_AdviserONE__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser_AdviserONE__c],'') is null
)
and ((nullif(s.[Area_of_Advice__c],'') is not null
and nullif(rp.[id-tgt],'') is not null)
or nullif(s.[Area_of_Advice__c],'') is null
)
and ((nullif(s.[Licensee_Supervisor__c],'') is not null
and nullif(ruls.[id],'') is not null)
or nullif(s.[Licensee_Supervisor__c],'') is null
)
and ((nullif(s.[AssignedTo__c],'') is not null
and nullif(ruat.[id],'') is not null)
or nullif(s.[AssignedTo__c],'') is null
)
go
