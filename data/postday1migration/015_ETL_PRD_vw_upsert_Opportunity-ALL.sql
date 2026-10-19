Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Opportunity-ALL]
go

create view [sfrhd].[vw_upsert_Opportunity-ALL] as
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
    where 1=1
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
    where 1=1
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
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Opportunity] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Opportunity] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[IsDeleted]
    ,[AccountId] = coalesce(ram.[id-tgt],'')
    ,[RecordTypeId] = coalesce(rrt.[id-tgt],'')
    ,s.[IsPrivate]
    ,s.[Name]
    --,s.[Description]
    ,s.[StageName]
    ,s.[Amount]
    --,s.[Probability]
    ,s.[ExpectedRevenue]
    ,s.[TotalOpportunityQuantity]
    ,s.[CloseDate]
    ,s.[NextStep]
    ,s.[LeadSource]
    ,s.[IsClosed]
    ,s.[IsWon]
    ,s.[ForecastCategory]
    ,s.[ForecastCategoryName]
    ,[CampaignId] = coalesce(s.[CampaignId],'')
    ,s.[HasOpportunityLineItem]
    ,[Pricebook2Id] = coalesce(rpb.[Id-tgt],'')
    ,s.[SystemModstamp]
    ,s.[LastActivityDate]
    ,s.[PushCount]
    ,s.[LastStageChangeDate]
    ,s.[FiscalQuarter]
    ,s.[FiscalYear]
    ,s.[Fiscal]
    ,[ContactId] = coalesce(rc.[Id-tgt],'')
    ,s.[LastViewedDate]
    ,s.[LastReferencedDate]
    ,[SyncedQuoteId] = ''
    ,s.[ContractId]
    ,s.[HasOpenActivity]
    ,s.[HasOverdueTask]
    ,s.[LastAmountChangedHistoryId]     -- all null
    ,s.[LastCloseDateChangedHistoryId]     -- all null
    ,s.[Budget_Confirmed__c]
    ,s.[Discovery_Completed__c]
    ,s.[ROI_Analysis_Completed__c]
    ,s.[AFP_Police_Check_Date__c]
    ,s.[Loss_Reason__c]
    ,s.[AFP_Police_Check__c]
    ,s.[ARC_Login_Cancelled_Date__c]
    ,s.[ARC_login_cancelled__c]
    ,s.[AR_CAR_Agreements_Scanned_Saved_Date__c]
    ,s.[AR_CAR_Agreements_Scanned_Saved__c]
    ,s.[AR_CAR_Agreements_issued_Date__c]
    ,s.[AR_CAR_Agreements_issued__c]
    ,s.[AR_CAR_Agreements_received_Date__c]
    ,s.[AR_CAR_Agreements_received__c]
    ,s.[ASIC_Ceased_Date__c]
    ,s.[ASIC_Ceased__c]
    ,s.[ASIC_Notification_Date__c]
    ,s.[ASIC_Notification__c]
    ,s.[Actual_Agreed_Cancellation_Date__c]
    ,s.[Advice_Systems_Xplan_Questionnaire__c]
    ,s.[Adviser_Application_Form_Date__c]
    ,s.[Adviser_Application_Form__c]
    ,s.[Adviser_Codes_Date__c]
    ,[Adviser__c] = coalesce(ra.[Id-tgt],'')
    ,s.[Agreement_Return_and_Execution_Date__c]
    ,s.[Any_Special_Conditions__c]
    ,s.[Application_Completion_Date__c]
    ,s.[Application_signoff__c]
    ,s.[Adviser_Codes__c]
    ,s.[Age__c]
    ,s.[Agreement_Return_and_Execution__c]
    ,s.[Authorise_Xplan_Data_Conversion_Date__c]
    ,s.[Authorise_Xplan_data_conversion__c]
    ,s.[Authority_Letter_Returned_Date__c]
    ,s.[Authority_Letter_Returned__c]
    ,s.[Authorize_Xplan_Data_Conversion_Date__c]
    ,s.[Authorize_Xplan_data_conversion__c]
    ,s.[Bank_Details_Received_Date__c]
    ,s.[Bank_Details_Received__c]
    ,s.[Brokerage_Update_Date__c]
    ,s.[Brokerage_update__c]
    ,s.[CPD_Records_Date__c]
    ,s.[CPD_Records__c]
    ,s.[Client_Book_Transfer__c]
    ,s.[Client_Release_Required__c]
    ,s.[Commentary__c]
    ,s.[Compliance_reports_Date__c]
    ,s.[Compliance_reports__c]
    ,s.[Copy_of_CV_Employment_History_Completed__c]
    ,s.[Licensee__c]
    ,s.[Licensee_confirm_clients_transition_Date__c]
    ,s.[Licensee_confirmed_client_data_Date__c]
    ,s.[Licensee_confirmed_clients_transition__c]
    ,s.[Licensee_opp__c]
    ,s.[Marketing_Brand_Collateral_Received_Date__c]
    ,s.[Marketing_Brand_Collateral__c]
    ,s.[Copy_of_CV_or_Employment_History__c]
    ,s.[EDP_External_Id__c]
    ,s.[Evidence_of_PI_Run_off_Cover_Received__c]
    ,s.[Evidence_of_PI_Run_off_Cover__c]
    ,s.[Exit_Reason__c]
    ,s.[Exit_Requirements_Checklist_Sent_Date__c]
    ,s.[Exit_Requirements_Checklist_Sent__c]
    ,s.[FDS_Confirmation__c]
    ,s.[FDS_Confirmation_date__c]
    ,s.[FDS_Example_Date__c]
    ,s.[FDS_Example__c]
    ,s.[Final_Disclosure_Confirmation_Date__c]
    ,s.[Final_Disclosure_Confirmation__c]
    ,s.[HasCompletedDueDiligence__c]
    ,s.[Identity_Check_Date__c]
    ,s.[Identity_Check__c]
    ,s.[Internet_Social_Media_Check_Comp_Date__c]
    ,s.[Internet_Social_Media_Check_Complete__c]
    ,s.[Issue_Practicing_Certificate_Date__c]
    ,s.[Issue_Practising__c]
    ,s.[Letter_sent_date__c]
    ,s.[Licensee_GM_approval_Date__c]
    ,s.[Licensee_GM_approval__c]
    ,s.[Licensee_GM_or_Delegate_Approval_date__c]
    ,s.[Licensee_Name__c]
    ,s.[Licensee_Supervisor__c]
    ,s.[Licensee_GM_or_Delegate_Approval__c]
    ,s.[Licensee_confirmed_client_data__c]
    ,s.[MyWorkSpace_updated__c]
    ,s.[MyWorkspace_Updated_Date__c]
    ,s.[Negative_Consent_end_date__c]
    ,s.[Negative_Consent_letter_sent__c]
    ,s.[Notice_of_Obligations_sent__c]
    ,s.[Notice_of_Obligations_sent_date__c]
    ,s.[Notification_Date__c]
    ,s.[Notify_Brokerage_Team_Date__c]
    ,s.[Notify_Brokerage_Team__c]
    ,s.[Notify_Internal_Licensee_Support_Staff__c]
    ,s.[Notify_Internal_Teams_Date__c]
    ,s.[Notify_Internal_Teams__c]
    ,s.[Notify_Licensee_Support_Staff_Date__c]
    ,s.[Number_Of_Open_Child_Cases__c]
    ,s.[Offer_Letter_Received_Date__c]
    ,s.[Offer_Letter_Status__c]
    ,s.[Onboarding_basic_URL__c]
    ,s.[PI_Run_Of_Declaration_Form_Date__c]
    ,s.[PI_Run_Of_Declaration_Form__c]
    ,s.[Practice_Application_Received_Date__c]
    ,s.[Practice_Application_Received__c]
    ,s.[Practice_Financials_Attestation_Date__c]
    ,s.[Practice_Financials_Attestation__c]
    ,s.[Practice_Manager__c]
    ,s.[Practice_Restructure_Date__c]
    ,s.[Practice_Restructure__c]
    ,s.[Product_Listing_Received__c]
    ,s.[Product_Listing__c]
    ,s.[Proprietor_confirmed_client_Date__c]
    ,s.[Proprietor_confirmed_client_transition__c]
    ,s.[Qualifications_Including_CPD_Points_Date__c]
    ,s.[Qualifications_Including_CPD_Points__c]
    ,s.[Qualifications_Reviewed_Date__c]
    ,s.[Qualifications_Reviewed__c]
    ,s.[Recruitment_Fact_Find_Received_Date__c]
    ,s.[Recruitment_Fact_Find__c]
    ,s.[Reference_Check_Date__c]
    ,s.[Reference_Check__c]
    ,s.[Release_Letter_Provided_Date__c]
    ,s.[Release_letter_provided__c]
    ,s.[Reminder_email_to_Proprietor_Date__c]
    ,s.[Reminder_email_to_Proprietor_Sent_Date__c]
    ,s.[Reminder_email_to_Proprietor__c]
    ,s.[Research_Access_Revoked_Date__c]
    ,s.[Research_Access_Revoked__c]
    ,s.[Research_Tools_Access_Date__c]
    ,s.[Research_Tools_Access__c]
    ,s.[Retained_clients_allocated_by_Licensee__c]
    ,s.[Retained_clients_allocation_date__c]
    ,s.[Sanctions_Check_Complete_Date__c]
    ,s.[Sanctions_Check_Revoked_Date__c]
    ,s.[Sanctions_Check_Revoked__c]
    ,s.[Sanctions_Checking_Submission_Date__c]
    ,s.[Signed_Recruitment_Fact_Find_Received__c]
    ,s.[Signed_Reference_Check_Form_Date__c]
    ,s.[Signed_Transfer_Deed_Date__c]
    ,s.[Signed_Transfer_Deed__c]
    ,s.[Sanctions_Check_Complete__c]
    ,s.[Sanctions_Checking_Submission__c]
    ,s.[Signed_Recruitment_Fact_Find__c]
    ,s.[Signed_exit_requirements_checklist_Date__c]
    ,s.[Signed_exit_requirements_checklist__c]
    ,s.[Special_Conditions__c]
    ,s.[Submitted_Date__c]
    ,s.[Transferee__c]
    ,s.[Tripartite_Agreement_Date__c]
    ,s.[Tripartite_Agreement__c]
    ,s.[Trust_Deed_Obtained_Date__c]
    ,s.[Trust_Deed_Obtained__c]
    ,s.[Type_of_adviser__c]
    ,s.[Update_Data_In_Adviser_Hub_Date__c]
    ,s.[Update_Data_In_Adviser_Hub__c]
    ,s.[Welcome_Email_Pack_Date__c]
    ,s.[Welcome_Email_Pack__c]
    ,s.[Work_Entitlement_Date__c]
    ,s.[Work_Entitlement__c]
    ,s.[Work_Item_Number__c]
    ,s.[Xplan_Questionaire_Received__c]
    ,s.[Xplan_Questionaire__c]
    ,s.[Xplan_Questionnaire_Data_conversion__c]
    ,s.[Xplan_Questionnaire_Received_Date__c]
    ,s.[Xplan_Questionnaire_Sent_To_ASST_Date__c]
    ,s.[Xplan_Questionnaire_Sent_To_ASST__c]
    ,s.[Approvals_Obtained__c]
    ,s.[ASIC_Levy_Date__c]
    ,s.[ASIC_Levy__c]
    ,s.[CyberAssessment_Due_Date_Added__c]
    ,s.[Date_CyberAssessment_DueDate_added__c]
    ,s.[Cyber_Insurance_Evidence_Received_Date__c]
    ,s.[Cyber_Insurance_Evidence_Received__c]
    ,s.[Licensee_Supervisor_Checklist__c]
    ,s.[Supervisor_Checklist_Received_Date__c]
,[OwnerId] = coalesce(u1.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ram
    on ram.[Id-src] = s.[AccountId]
left join [cte_Campaign] rcp
    on rcp.[Id-src] = s.[CampaignId]
left join [cte_Contact] ra
    on ra.[Id-src] = s.[Adviser__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[ContactId]
left join [cte_PriceBook2] rpb
    on rpb.[Id-src] = s.[Pricebook2Id]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[AccountId],'') is not null
and nullif(ram.[id-tgt],'') is not null)
or nullif(s.[AccountId],'') is null
)
and ((nullif(s.[Adviser__c],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
and ((nullif(s.[ContactId],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[ContactId],'') is null
)
and ((nullif(s.[CampaignId],'') is not null
and nullif(rcp.[id-tgt],'') is not null)
or nullif(s.[CampaignId],'') is null
)
go
