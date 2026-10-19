Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Assurance_Review-ALL]
go

create view [sfrhd].[vw_upsert_Assurance_Review-ALL] as
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
)
,cte_Assurance_Event as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Assurance_Event__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Assurance_Event__c] r (nolock)
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
    join [SalesforceMigration].[sfrhd].[BusinessHours] r (nolock)
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
    join [SalesforceMigration].[sfrhd].[Campaign] r (nolock)
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
    join [SalesforceMigration].[sfrhd].[Case] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    join [SalesforceMigration].[sfrhd].[Contact] rc (nolock)
        on rc.[Id] = r.[ContactId]
)
,cte_Con_Mgt as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Consequence_Management_Forum_Entry__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Consequence_Management_Forum_Entry__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_PriceBook2 as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Pricebook2] i (nolock)
    join [SalesforceMigration].[sfrhd].[Pricebook2] r (nolock)
        on r.[Name] = i.[Name]
    where 1=1
    and nullif(r.[Name],'') is not null
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
    select 
    a.[Licensee__c],
    s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Assurance_Review__c] s (nolock)
    join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = s.[Practice__c]
--        and a.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Assurance_Review__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and s.[Id] in (
'a096F00002gp1tQQAQ'
,'a096F00002gp1t2QAA'
,'a096F00002gp1spQAA'
,'a096F00002gp1szQAA'
)
--and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Actions_from_Vetting_Result__c]
    ,s.[Advice_Document_Type__c]
    ,s.[Advice_Document_Type_AdviserONE__c]
    ,s.[Advice_Risk_Escalation_Comments__c]
    ,s.[Advice_Risk_Escalation_Recommendations__c]
    ,[All_Response_Yes__c] = iif(s.[All_Response_Yes__c] = 1, 'true', 'false')
    ,s.[Any_Outstanding_Remediation__c]
    ,s.[Appeal_Closed_Date__c]
    ,s.[Appeal_Received_Date__c]
    ,s.[Appeal_Status__c]
    ,s.[Appointment_Date__c]
    ,s.[Appointment_Location__c]
    ,s.[Appointment_Time__c]
    ,s.[Are_all_Documents_Received__c]
    ,s.[Areas_of_Advice_for_Vetting__c]
    ,s.[ASN_Score__c]
    ,s.[Atleast_Two_Potential_Repeat_Offence_s__c]
    ,s.[Client_Name__c]
    ,s.[ClientID_Xplan__c]
    ,s.[Closed_Date__c]
    ,s.[Comment__c]
    ,s.[Comment1__c]
    ,s.[Comment2__c]
    ,s.[Comment3__c]
    ,s.[Comment4__c]  -- not exists
    ,s.[Comments_for_Targeted_Review__c]
    ,s.[Comments_on_Repeat_Offence_s__c]
    ,s.[Continue__c]
    ,s.[Current_Score__c]
    ,s.[Data_Source_For_Client_File_Selection__c]
    ,s.[Debrief_Attendees__c]     -- not exists
    ,s.[Debrief_Date__c]
    ,s.[Debrief_Minutes__c]
    ,s.[Debrief_Notes__c]
    ,s.[Debrief_Time__c]      -- not exists
    ,s.[Document_Received_Date__c]
    ,s.[Draft_Report_Sent_Date__c]
    ,s.[Draft_Score__c]
    ,s.[EDP_External_Id__c]
    ,s.[Escalate_to_Advice_Risk__c]
    ,s.[Final_Report_Sent_Date__c]
    ,s.[Final_Score_after_Appeal__c]
    ,s.[Final_Score_before_Appeal__c]
    ,s.[First_Report_Sent_Date__c]
    ,s.[Future_Review_Created__c]     -- not exists
    ,s.[General_Advice_Score_Impact__c]
    ,s.[Guidance_for_General_Advice_Overview__c]
    ,s.[Guidance_for_Potential_Compliance_Issues__c]
    ,s.[Guidance_for_Potential_Repeat_Offences__c]
    ,s.[Guidance_for_Targeted_Review_Suggestion__c]
    ,[Hidden_in_AdviserONE__c] = iif(s.[Hidden_in_AdviserONE__c] = 1, 'true', 'false')
    ,s.[Initial_Owner_Assignment_Status__c]
    ,s.[Interim_or_Final_Report_Modified_on_Date__c]
    ,s.[Interim_Report_Sent_Date__c]
    ,s.[Is_Review_in_Flight__c]     -- not exists
    ,[Is_Reviewer_Assigned__c] = iif(s.[Is_Reviewer_Assigned__c] = 1, 'true', 'false')
    ,[Is_Root_Cause_Analysis_Completed__c] = iif(s.[Is_Root_Cause_Analysis_Completed__c] = 1, 'true', 'false')
    ,s.[Is_targeted_review_recommended__c]
    ,s.[Is_this_a_No_report_review__c]
    ,[IsDeleted] = iif(s.[IsDeleted] = 1, 'true', 'false')
    ,s.[Last_Draft_Report_Sent_Date__c]     -- not exists
    ,s.[Last_Review_Client_File_Xplan_Id__c]
    ,s.[Last_Review_Period__c]
    ,s.[LastReferencedDate]
    ,s.[LastViewedDate]
    ,s.[Licensee_Name__c]
    ,[MandatoryQuestionsFail__c] = iif(s.[MandatoryQuestionsFail__c] = 1, 'true', 'false')
    ,s.[Name]
    ,s.[Number_of_High_Issues__c]
    ,s.[Number_of_Improvement_Options__c]
    ,s.[Number_of_Low_Issues__c]
    ,s.[Number_of_Medium_Issues__c]
    ,s.[Number_Of_Open_Tasks__c]
    ,s.[Number_of_Time_Critical_Advice__c]
    ,s.[Number_of_Total_Tasks__c]
    ,[On_Hold__c] = iif(s.[On_Hold__c] = 1, 'true', 'false')
    ,[One_Client_File_Reviewed__c] = iif(s.[One_Client_File_Reviewed__c] = 1, 'true', 'false')
    ,s.[Oustanding_Remediation_Actions__c]
    ,s.[Overview_Completion_Status__c]
    ,s.[Overview_Questionnaire_Status__c]
    ,s.[Partner_AFSL__c]
    ,s.[Picked_For_Accredited_QA__c]     -- not exists
    ,s.[Picked_For_Standard_QA__c]     -- not exists
    ,s.[Pre_review_Completion_Status__c]
    ,s.[Pre_Review_Questionnaire_Status__c]
    ,s.[Priority__c]
    ,s.[QA_Done__c]     -- not exists
    ,[QA_Done_Draft__c] = iif(s.[QA_Done_Draft__c] = 1, 'true', 'false')
    ,[QA_Done_Final__c] = iif(s.[QA_Done_Final__c] = 1, 'true', 'false')
    ,[QA_Done_Interim__c] = iif(s.[QA_Done_Interim__c] = 1, 'true', 'false')
    ,s.[QA_Task_Status__c]
    ,s.[Re_submission_Status__c]
    ,s.[Reason_for_Cancellation__c]
    ,s.[Reason_for_No_Advice_Review__c]
    ,[Reason_for_Review__c] = coalesce(s.[Reason_for_Review__c],'')
    ,s.[Reason_for_Review_AdviserONE__c]
    ,s.[Reason_for_Review_Date_Change__c]
    ,s.[Received_Date__c]
    ,s.[Recommendation1__c]
    ,s.[Recommendation2__c]
    ,s.[Recommendation3__c]
    ,s.[Recommendations_for_Repeat_Offence_s__c]
    ,s.[Recommendations_for_Targeted_Review__c]
    ,s.[Recommendations_to_Continue_Doing__c]
    ,s.[Recommendations_to_Start_Doing__c]
    ,s.[Recommendations_to_Stop_Doing__c]
    ,s.[Regulatory_Compliance_Score_Impact__c]
    ,s.[Remedial_Actions__c]
    ,s.[Remediation_Due_Date__c]
    ,s.[Replacement_of_product__c]
    ,s.[Report_Finalized_Date__c]
    ,s.[Report_Type__c]
    ,s.[Require_Vetting__c]
    ,s.[Response_Days__c]
    ,s.[Response_Due_Date__c]
    ,s.[Response1__c]
    ,s.[Response2__c]
    ,s.[Response3__c]
    ,s.[Response4__c]
    ,s.[Response5__c]
    ,s.[Review_Closed_Date__c]
    ,s.[Review_Date__c]
    ,s.[Review_Due_Date__c]
    ,s.[Review_Period__c]
    ,s.[Review_Status__c]
    ,s.[Review_Type_Options__c]
    ,[Scheduling_Frequency__c] = coalesce(s.[Scheduling_Frequency__c],'')
    ,s.[Should_the_adviser_be_put_on_vetting__c]
    ,s.[Stage__c]
    ,s.[Start__c]
    ,s.[Stop__c]
    ,s.[Sub_Stage__c]
    ,s.[Supress_Advice_Assurance_Score__c]     -- not exists
    ,s.[SystemModstamp]
    ,[Three_or_More_Client_Files_Reviewed__c] = iif(s.[Three_or_More_Client_Files_Reviewed__c] = 1, 'true', 'false')
    ,s.[Total_Number_of_Issues__c]
    ,[Two_Client_Files_Reviewed__c] = iif(s.[Two_Client_Files_Reviewed__c] = 1, 'true', 'false')
    ,s.[Unanswered_Overview_Questions__c]
    ,s.[Vetting__c]
    ,s.[Vetting_Commencement_Date__c]
    ,s.[Vetting_Report_Text__c]
    ,s.[Vetting_Result__c]
    ,[Workflow_Step__c] = coalesce(s.[Workflow_Step__c],'')
    ,[Practice__c] = coalesce(ram.[Id-tgt],'')
    ,[Assurance_Event__c] = coalesce(rae.[Id-tgt],'')
    ,[Cloned_Targeted_Review__c] = coalesce(rar.[Id-tgt],s.[Cloned_Targeted_Review__c]+'+')
    ,[Original_Request_Number__c] = coalesce(rao.[Id-tgt],s.[Original_Request_Number__c]+'+')
    ,[Resubmission_case__c] = coalesce(ras.[Id-tgt],s.[Resubmission_case__c]+'+')
    ,[Risk_Forum__c] = coalesce(cm.[Id-tgt],s.[Risk_Forum__c]+'+')
    ,[Adviser__c] = coalesce(ra.[Id-tgt],s.[Adviser__c]+'+')
    ,[Adviser_AdviserONE__c] = coalesce(rc.[Id-tgt],s.[Adviser_AdviserONE__c]+'+')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
    ,[Assurance_Reviewer__c] = coalesce(ruar.[Id],s.[Assurance_Reviewer__c]+'+')
    ,[Licensee_Supervisor_Name__c] = coalesce(ruls.[Id],'')
,[OwnerId] = coalesce(u1.[Id],[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastActivityDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ram
    on ram.[Id-src] = s.[Practice__c]
left join [cte_Assurance_Event] rae
    on rae.[Id-src] = s.[Assurance_Event__c]
left join [cte_Assurance_Review] rar
    on rar.[Id-src] = s.[Cloned_Targeted_Review__c]
left join [cte_Assurance_Review] rao
    on rao.[Id-src] = s.[Original_Request_Number__c]
left join [cte_Assurance_Review] ras
    on ras.[Id-src] = s.[Resubmission_case__c]
left join [cte_Con_Mgt] cm
    on cm.[id-src] = s.[Risk_Forum__c]
left join [cte_Contact] ra
    on ra.[Id-src] = s.[Adviser__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser_AdviserONE__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
left join [cte_User] ruar
    on ruar.[Metazoa_External_ID__c] = s.[Assurance_Reviewer__c]
left join [cte_User] ruls
    on ruls.[Metazoa_External_ID__c] = s.[Licensee_Supervisor_Name__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Practice__c],'') is not null
and nullif(ram.[id-tgt],'') is not null)
or nullif(s.[Practice__c],'') is null
)
and ((nullif(s.[Assurance_Event__c],'') is not null
and nullif(rae.[id-tgt],'') is not null)
or nullif(s.[Assurance_Event__c],'') is null
)
and ((nullif(s.[Cloned_Targeted_Review__c],'') is not null
and nullif(rar.[id-tgt],'') is not null)
or nullif(s.[Cloned_Targeted_Review__c],'') is null
)
--and ((nullif(s.[Original_Request_Number__c],'') is not null
--and nullif(rao.[id-tgt],'') is not null)
--or nullif(s.[Original_Request_Number__c],'') is null
--)
--and ((nullif(s.[Resubmission_case__c],'') is not null
--and nullif(ras.[id-tgt],'') is not null)
--or nullif(s.[Resubmission_case__c],'') is null
--)
--and ((nullif(s.[Risk_Forum__c],'') is not null
--and nullif(cm.[id-tgt],'') is not null)
--or nullif(s.[Risk_Forum__c],'') is null
--)
and ((nullif(s.[Adviser__c],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
and ((nullif(s.[Adviser_AdviserONE__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser_AdviserONE__c],'') is null
)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
and ((nullif(s.[Assurance_Reviewer__c],'') is not null
and nullif(ruar.[id],'') is not null)
or nullif(s.[Assurance_Reviewer__c],'') is null
)
and ((nullif(s.[Licensee_Supervisor_Name__c],'') is not null
and nullif(ruls.[id],'') is not null)
or nullif(s.[Licensee_Supervisor_Name__c],'') is null
)
go
