Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Client_Service_Model_Implementation-ALL]
go

create view [sfrhd].[vw_upsert_Client_Service_Model_Implementation-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
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
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
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
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
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
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Client_Service_Model_Implementation__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Client_Service_Model_Implementation__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
        --and t.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[ACR_Go_Live__c]
    ,s.[ACR_Initiative_Comments__c]
    ,s.[ACR_Question_1__c]
    ,s.[ACR_Question_2__c]
    ,s.[ACR_Question_3__c]
    ,s.[ACR_Question_4__c]
    ,s.[ACR_Question_5__c]
    ,s.[Additional_Support__c]
    ,s.[Advice_Case_Framework_Comments__c]
    ,s.[Answer_1__c]
    ,s.[Answer_2__c]
    ,s.[Answer_3__c]
    ,s.[Answer_4__c]
    ,s.[Answer_5__c]
    ,s.[CKRI_A9__c]
    ,s.[CKRI_NotUmlaut_Comments__c]
    ,s.[CKRI_Q7__c]
    ,s.[CKRI_Q8__c]
    ,s.[CKRI_Q9__c]
    ,s.[CombinationBanner__c]
    ,s.[Comments_for_Combination__c]
    ,s.[Completion_Date__c]
    ,s.[CRKI_A1__c]
    ,s.[CRKI_A10__c]
    ,s.[CRKI_A11__c]
    ,s.[CRKI_A2_Number_of_Years__c]
    ,s.[CRKI_A3__c]
    ,s.[CRKI_A4__c]
    ,s.[CRKI_A5_c__c]
    ,s.[CRKI_A6__c]
    ,s.[CRKI_A7__c]
    ,s.[CRKI_Answer_0__c]
    ,s.[CRKI_Comments_A1__c]
    ,s.[CRKI_Q1__c]
    ,s.[CRKI_Q11__c]
    ,s.[CRKI_Q11_Comments__c]
    ,s.[CRKI_Q2__c]
    ,s.[CRKI_Q3__c]
    ,s.[CRKI_Q4__c]
    ,s.[CRKI_Q5__c]
    ,s.[CRKI_Q6__c]
    ,s.[CRKI_Question_0__c]
    ,s.[Cyber_Assessment_Due_Date__c]
    ,[Cyber_Assessment_Required__c] = iif(s.[Cyber_Assessment_Required__c] = 1, 'true', 'false')
    ,s.[Cyber_Insurance_Expiry_Date__c]
    ,s.[CyberAssessment_Completed_Date__c]
    ,s.[CyberSecurity_Assessment_Comments__c]
    --,s.[CyberSecurity_Assessment_Due_Date__c]     -- not exists
    ,s.[Date_of_2nd_Assessment__c]
    ,s.[Date_of_Assessment__c]
    ,s.[Date_of_Engagement__c]
    ,s.[Date_of_Engagement_2__c]
    ,s.[Date_of_Engagement_3__c]
    ,s.[Date_of_outcome_report__c]
    ,s.[Decision_Made_on_New_Licensee__c]
    ,s.[Detect_Score__c]
    ,s.[Electronic_Storage_Requirement_Comments__c]
    ,s.[Engaged_Advisers2__c]
    ,s.[Estimated_Completion_Date_of_Pre_Work__c]
    ,s.[Estimated_Final_Completion_Date__c]
    ,s.[Identify_Score__c]
    ,s.[Impacted_by_Advice_2_0__c]
    ,s.[LicenseeSupervisorEmail__c]
    ,s.[Manage_Client_Reviews_Comments__c]
    ,s.[Minimum_Data_Requirement_Comments__c]
    ,s.[Name]
    ,s.[Number_of_Client_Files__c]
    ,s.[Number_of_Years_Digital__c]
    ,s.[Number_of_Years_Paper__c]
    ,s.[Number_of_Years_XPLAN__c]
    ,s.[Overall_Comments__c]
    ,s.[Overall_Score__c]
    ,s.[Practice_contact__c]
    ,s.[PracticeEmail__c]
    ,s.[Pricing__c]
    ,s.[Protect_Score__c]
    ,s.[Question_1__c]
    ,s.[Question_1_Comments__c]
    ,s.[Question_10__c]
    ,s.[Question_2__c]
    ,s.[Question_2_Comments__c]
    ,s.[Question_3__c]
    ,s.[Question_3_Comments__c]
    ,s.[Question_4__c]
    ,s.[Question_4_Comments__c]
    ,s.[Recover_Score__c]
    ,s.[Respond_Score__c]
    ,[Risk_Insurance_Only__c] = iif(s.[Risk_Insurance_Only__c] = 1, 'true', 'false')
    ,s.[Services__c]
    ,s.[Stage_1_Status__c]
    ,s.[Stage_2_Status__c]
    ,s.[Status__c]
    ,s.[System_Xplan__c]
    ,s.[Transition_Process__c]
    ,s.[What_CRM_or_server_system_does_the_pract__c]
    ,[Practice__c] = coalesce(ram.[Id-tgt],'')
    ,[Primary_Practice__c] = coalesce(rapp.[Id-tgt],'')
    ,[Advisers_Engaged__c] = coalesce(ra.[Id-tgt],'')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
    ,[Owner__c] = coalesce(ruo.[Id],'')
    ,[OwnerBackBookAttestation__c] = coalesce(rub.[Id],'')
    ,[OwnerProjectEngagement__c] = coalesce(rupe.[Id],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ram
    on ram.[Id-src] = s.[Practice__c]
left join [cte_Account] rapp
    on rapp.[Id-src] = s.[Primary_Practice__c]
left join [cte_Contact] ra
    on ra.[Id-src] = s.[Advisers_Engaged__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
left join [cte_User] ruo
    on ruo.[Metazoa_External_ID__c] = s.[Owner__c]
left join [cte_User] rub
    on rub.[Metazoa_External_ID__c] = s.[OwnerBackBookAttestation__c]
left join [cte_User] rupe
    on rupe.[Metazoa_External_ID__c] = s.[OwnerProjectEngagement__c]
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
and ((nullif(s.[Primary_Practice__c],'') is not null
and nullif(rapp.[id-tgt],'') is not null)
or nullif(s.[Primary_Practice__c],'') is null
)
and ((nullif(s.[Advisers_Engaged__c],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[Advisers_Engaged__c],'') is null
)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
and ((nullif(s.[Owner__c],'') is not null
and nullif(ruo.[id],'') is not null)
or nullif(s.[Owner__c],'') is null
)
and ((nullif(s.[OwnerBackBookAttestation__c],'') is not null
and nullif(rub.[id],'') is not null)
or nullif(s.[OwnerBackBookAttestation__c],'') is null
)
and ((nullif(s.[OwnerProjectEngagement__c],'') is not null
and nullif(rupe.[id],'') is not null)
or nullif(s.[OwnerProjectEngagement__c],'') is null
)
go
