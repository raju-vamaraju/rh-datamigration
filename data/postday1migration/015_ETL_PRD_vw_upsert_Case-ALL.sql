Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Case-ALL]
go

create view [sfrhd].[vw_upsert_Case-ALL] as
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
,cte_Case as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[CaseNumber-src] = i.[CaseNumber]
        ,[CaseNumber-tgt] = r.[CaseNumber]
    from [SalesforceMigration].[sf].[Case] i (nolock)
    join [SalesforceMigration].[sfrhd].[Case] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    where 1=1
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
,cte_LookupName as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[LookupName__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[LookupName__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_Oppo as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Opportunity] i (nolock)
    join [SalesforceMigration].[sfrhd].[Opportunity] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_Product2 as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Product2] i (nolock)
    join [SalesforceMigration].[sfrhd].[Product2] r (nolock)
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
    where 1=1
)
,cte_src1 as (
    select s.*
    from [SalesforceMigration].[sf].[Case] s (nolock)
    join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = s.[Practice_Name__c]
        and a.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Case] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
,cte_src2 as (
    select s.*
    from [SalesforceMigration].[sf].[Case] s (nolock)
    join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = s.[AccountId]
        and a.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Case] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
,cte_src3 as (
    select s.*
    from [SalesforceMigration].[sf].[Case] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = s.[ContactId]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Case] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
,cte_all as (
    select [Id] from [cte_src1]
    union
    select [Id] from [cte_src2]
    union
    select [Id] from [cte_src3]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Case] s (nolock)
    join [cte_all] a
        on a.[Id] = s.[Id]
    left join [SalesforceMigration].[sfrhd].[Case] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
-- and t.[Id] is null
)
select
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,[ABN_ACN_Check__c] = coalesce(s.[ABN_ACN_Check__c],'')
    ,s.[ABN_ACN_Check_Date__c]
    ,[Additional_Directorships_Check__c] = coalesce(s.[Additional_Directorships_Check__c],'')
    ,s.[Additional_Directorships_Check_Date__c]
    ,[ADG_ANZ_child__c] = coalesce(s.[ADG_ANZ_child__c],'')
    --,s.[Aged_care__c]
    --,s.[Aged_care_Completion_Date__c]
    ,s.[Amount_Paid_to_Client__c]
    ,s.[Approval_Comments__c]
    ,s.[Approvals_Professional_Standard__c]
    ,[APRA_Check__c] = coalesce(s.[APRA_Check__c],'')
    ,s.[APRA_Check_Date__c]
    ,[AR_Register_Check__c] = coalesce(s.[AR_Register_Check__c],'')
    ,s.[AR_Register_Check_Date__c]
    ,[Area_Responsible__c] = coalesce(s.[Area_Responsible__c],'')
    ,[ASIC_Check__c] = coalesce(s.[ASIC_Check__c],'')
    ,s.[ASIC_Check_Date__c]
    ,[ASIC_EU_Check__c] = coalesce(s.[ASIC_EU_Check__c],'')
    ,s.[ASIC_EU_Check_Date__c]
    ,[Banned_Disqualified_Check__c] = coalesce(s.[Banned_Disqualified_Check__c],'')
    ,s.[Banned_Disqualified_Check_Date__c]
    ,[Business_insurance__c] = coalesce(s.[Business_insurance__c],'')
    ,s.[Business_insurance_Completion_Date__c]
    ,[Case_Managed_by__c] = coalesce(s.[Case_Managed_by__c],'')
    --,s.[CaseNumber]
    ,s.[Claimed_Amount__c]
    ,s.[Client_1_First_Name__c]
    ,s.[Client_1_Last_Name__c]
    ,s.[Client_2_First_Name__c]
    ,s.[Client_2_Last_Name__c]
    ,s.[Client_3_First_Name__c]
    ,s.[Client_3_Last_Name__c]
    ,s.[Client_Name__c]
    ,s.[ClientID_Xplan__c]
    ,s.[Closed_by_EDR_Scheme__c]
    ,s.[ClosedDate]
    ,s.[Comments]
    ,[Complainant__c] = coalesce(s.[Complainant__c],'')
    ,[Complainant_age__c] = coalesce(s.[Complainant_age__c],'')
    ,s.[Complainant_Claim_Amount__c]
    ,[Complainant_gender__c] = coalesce(s.[Complainant_gender__c],'')
    ,s.[Complainant_postcode__c]
    ,[Complainant_Type__c] = coalesce(s.[Complainant_Type__c],'')
    ,s.[Complaint_Allegation__c]
    ,[Complaint_channel__c] = coalesce(s.[Complaint_channel__c],'')
    ,s.[Complaint_Closure_Checklist_completed__c]
    ,[Complaint_issue__c] = coalesce(s.[Complaint_issue__c],'')
    ,[Complaint_issue_14_b__c] = coalesce(s.[Complaint_issue_14_b__c],'')
    ,[Complaint_issue_14_c__c] = coalesce(s.[Complaint_issue_14_c__c],'')
    ,[Complaint_outcome__c] = coalesce(s.[Complaint_outcome__c],'')
    ,[Complaint_outcome_15_b__c] = coalesce(s.[Complaint_outcome_15_b__c],'')
    ,[Complaint_outcome_15_c__c] = coalesce(s.[Complaint_outcome_15_c__c],'')
    ,s.[Conciliation_Date__c]
    ,s.[Confirmation_Provided__c]
    ,s.[Consequence_Management_Form_required__c]
    ,s.[ContactEmail]
    ,s.[ContactFax]
    ,s.[ContactMobile]
    ,s.[ContactPhone]
    ,s.[COR_Closure_request__c]
    ,s.[COR_ID__c]
    ,s.[COR_Logged_date__c]
    ,[Credit_Bankruptcy__c] = coalesce(s.[Credit_Bankruptcy__c],'')
    ,s.[Credit_Bankruptcy_Check_Date__c]
    ,[Credit_Rep_Register_Check__c] = coalesce(s.[Credit_Rep_Register_Check__c],'')
    ,s.[Credit_Rep_Register_Check_Date__c]
    ,[CSA_Extension_Approval_Sent_To_Adviser__c] = iif(s.[CSA_Extension_Approval_Sent_To_Adviser__c] = 1, 'true', 'false')
    ,s.[CSA_extension_end_date__c]
    ,s.[Date_Closed__c]
    ,s.[Date_PI_insurer_notified__c]
    ,s.[Date_Received_by_Company_ADG__c]
    ,s.[Date_Received_by_Complaints_Team__c]
    ,s.[DDO_Product__c]
    ,[DDO_Reportable__c] = coalesce(s.[DDO_Reportable__c],'')
    ,s.[Description]
    ,s.[Determination_Date__c]
    --,s.[Direct_Shares__c]
    --,s.[Direct_Shares_Completion_Date__c]
    ,s.[EDP_External_Id__c]
    ,[EDR_Scheme__c] = coalesce(s.[EDR_Scheme__c],'')
    ,[Enforceable_Undertaking_Check__c] = coalesce(s.[Enforceable_Undertaking_Check__c],'')
    ,s.[Enforceable_Undertaking_Check_Date__c]
    ,s.[Extension_Letter_sent__c]
    ,s.[External_Reference_Number__c]
    ,[FAR_Check__c] = coalesce(s.[FAR_Check__c],'')
    ,s.[FAR_Check_Date__c]
    ,[Fee_Reimbursement_Program_Complaint__c] = coalesce(s.[Fee_Reimbursement_Program_Complaint__c],'')
    ,[Files_Available__c] = coalesce(s.[Files_Available__c],'')
    ,s.[Follow_up_comment__c]
    ,s.[Follow_up_Date__c]
    --,s.[Gearing__c]
    --,s.[Gearing_Completion_Date__c]
    ,s.[Has_a_reportable_situation_occurred__c]
    ,s.[Insurance__c]
    ,[Internet_And_Social_Media_Check__c] = coalesce(s.[Internet_And_Social_Media_Check__c],'')
    ,s.[Internet_And_Social_Media_Check_Date__c]
    ,s.[Investment__c]
    ,[Is_the_complaint_about_the_authorised_re__c] = coalesce(s.[Is_the_complaint_about_the_authorised_re__c],'')
    ,[IsClosed] = iif(s.[IsClosed] = 1, 'true', 'false')
    ,[IsClosedOnCreate] = iif(s.[IsClosedOnCreate] = 1, 'true', 'false')
    ,[IsEscalated] = iif(s.[IsEscalated] = 1, 'true', 'false')
    ,[IsStopped] = iif(s.[IsStopped] = 1, 'true', 'false')
    ,[Language] = coalesce(s.[Language],'')
    ,s.[Loss_Incurred_by_which_BSBCC__c]
    --,s.[Margin_Lending__c]
    --,s.[Margin_Lending_Completion_Date__c]
    --,s.[Metazoa_External_ID__c]
    ,[Method_Received__c] = coalesce(s.[Method_Received__c],'')
    --,s.[MilestoneStatus]
    ,s.[Monetary_remedy__c]
    ,[Non_Authorised_Director__c] = coalesce(s.[Non_Authorised_Director__c],'')
    ,s.[Non_Authorised_Director_Date__c]
    ,s.[Notified_to_Escalation_Teams__c]
    ,[Number_and_Type_13_a__c] = coalesce(s.[Number_and_Type_13_a__c],'')
    ,[Number_and_Type_13_b__c] = coalesce(s.[Number_and_Type_13_b__c],'')
    ,[Number_and_Type_13_c__c] = coalesce(s.[Number_and_Type_13_c__c],'')
    ,s.[Number_of_Open_Tasks__c]
    ,[Ongoing_Service_Client__c] = coalesce(s.[Ongoing_Service_Client__c],'')
    ,[Origin] = coalesce(s.[Origin],'')
    ,[Other_Product__c] = iif(s.[Other_Product__c] = 1, 'true', 'false')
    --,s.[Other_Qualifications__c]
    ,s.[Payment_Made__c]
    ,s.[Pension__c]
    ,[PEP__c] = iif(s.[PEP__c] = 1, 'true', 'false')
    ,s.[PEP_Client__c]
    ,[PI_insurer_indemnity_status__c] = coalesce(s.[PI_insurer_indemnity_status__c],'')
    ,[PI_Insurer_Notified__c] = coalesce(s.[PI_Insurer_Notified__c],'')
    ,s.[PI_Reference__c]
    ,s.[Platform_Other__c]
    ,[Priority] = coalesce(s.[Priority],'')
    ,[Privacy_Related__c] = coalesce(s.[Privacy_Related__c],'')
    ,[Product_Not_Applicable__c] = iif(s.[Product_Not_Applicable__c] = 1, 'true', 'false')
    ,[Product_or_service_13_a__c] = coalesce(s.[Product_or_service_13_a__c],'')
    ,[Product_or_service_13_b__c] = coalesce(s.[Product_or_service_13_b__c],'')
    ,[Product_or_service_13_c__c] = coalesce(s.[Product_or_service_13_c__c],'')
    ,[Product_or_service_category__c] = coalesce(s.[Product_or_service_category__c],'')
    ,[Product_or_service_category_FinAd__c] = coalesce(s.[Product_or_service_category_FinAd__c],'')
    ,[Product_or_service_category_LIL__c] = coalesce(s.[Product_or_service_category_LIL__c],'')
    ,[Product_or_service_category_Not_Prod__c] = coalesce(s.[Product_or_service_category_Not_Prod__c],'')
    ,[Product_or_service_category_SupA__c] = coalesce(s.[Product_or_service_category_SupA__c],'')
    ,[Product_or_service_category_TraTS__c] = coalesce(s.[Product_or_service_category_TraTS__c],'')
    ,[Product_or_service_number_and_type__c] = coalesce(s.[Product_or_service_number_and_type__c],'')
    ,[Product_or_service_number_and_type_FinAd__c] = coalesce(s.[Product_or_service_number_and_type_FinAd__c],'')
    ,[Product_or_service_number_and_type_LIL__c] = coalesce(s.[Product_or_service_number_and_type_LIL__c],'')
    ,[Product_or_service_number_and_type_NotP__c] = coalesce(s.[Product_or_service_number_and_type_NotP__c],'')
    ,[Product_or_service_number_and_type_SupA__c] = coalesce(s.[Product_or_service_number_and_type_SupA__c],'')
    ,[Product_or_service_number_and_type_TraTS__c] = coalesce(s.[Product_or_service_number_and_type_TraTS__c],'')
    ,s.[Product_Other__c]
    ,s.[Product_Type__c]
    ,s.[Qualifications__c]
    ,[Reason] = coalesce(s.[Reason],'')
    ,s.[Recommendation_Date__c]
    ,s.[Registration_Due__c]
    ,s.[Registration_Received__c]
    ,s.[Registration_Sent__c]
    ,[Reportable_as_an_incident__c] = coalesce(s.[Reportable_as_an_incident__c],'')
    ,s.[Resolved_in_5_Business_Days_Date_Closed__c]
    ,[Resolved_in_Favour__c] = coalesce(s.[Resolved_in_Favour__c],'')
    ,s.[Response__c]
    ,s.[Response_Letter_Approved_by_Licensee__c]
    ,s.[Review_Date__c]
    ,[RG146_Review__c] = coalesce(s.[RG146_Review__c],'')
    ,s.[RG146_Review_Date__c]
    ,[RI_Technical_Knowledge_Test__c] = coalesce(s.[RI_Technical_Knowledge_Test__c],'')
    ,s.[RI_Technical_Knowledge_Test_Date__c]
    ,[Root_Cause__c] = coalesce(s.[Root_Cause__c],'')
    ,[Sanctions_Check__c] = coalesce(s.[Sanctions_Check__c],'')
    ,s.[Sanctions_Check_Date__c]
    --,s.[SlaExitDate]
    ,s.[SlaStartDate]
    --,s.[Specialist_Accreditation__c]
    ,[Stage__c] = coalesce(s.[Stage__c],'')
    ,[State_of_Client__c] = coalesce(s.[State_of_Client__c],'')
    ,[Status] = coalesce(s.[Status],'')
    ,[Status_of_Apporval__c] = coalesce(s.[Status_of_Apporval__c],'')
    --,s.[StopStartDate]
    ,[Sub_Category_Subject_Area__c] = coalesce(s.[Sub_Category_Subject_Area__c],'')
    ,s.[Sub_Product_Type__c]
    ,s.[Sub_Root_Cause__c]
    ,[Sub_Sub_Category__c] = coalesce(s.[Sub_Sub_Category__c],'')
    ,[Subcategory_13_a__c] = coalesce(s.[Subcategory_13_a__c],'')
    ,[Subcategory_13_b__c] = coalesce(s.[Subcategory_13_b__c],'')
    ,[Subcategory_13_c__c] = coalesce(s.[Subcategory_13_c__c],'')
    ,s.[Subject]
    ,[Subject_Area__c] = coalesce(s.[Subject_Area__c],'')
    ,s.[Substantive_Response_Sent__c]
    ,s.[Super__c]
    ,s.[SuppliedCompany]
    ,s.[SuppliedName]
    ,s.[SuppliedPhone]
    ,[Tax_Practitioner_Board__c] = coalesce(s.[Tax_Practitioner_Board__c],'')
    ,s.[Technical_Knowledge_Date__c]
    ,[Technical_Knowledge_Test__c] = coalesce(s.[Technical_Knowledge_Test__c],'')
    ,s.[TPB_Check_Date__c]
    ,[Trust_Deed_Checks__c] = coalesce(s.[Trust_Deed_Checks__c],'')
    ,s.[Trust_Deed_Checks_Date__c]
    ,[Type] = coalesce(s.[Type],'')
    ,s.[Upcoming_Task_Due_Date__c]
    ,[AccountId] = coalesce(ram.[Id-tgt],s.[AccountId]+'+')
    ,[Practice_Name__c] = coalesce(rap.[Id-tgt],s.[Practice_Name__c]+'+')
    ,[AssetId] = s.[AssetId]
    ,[BusinessHoursId] = coalesce(rbh.[Id-tgt],'')
    ,[Escalation_Case__c] = coalesce(rce.[Id-tgt],s.[Escalation_Case__c]+'+')
    --,[MasterRecordId] = coalesce(rcm.[Id-tgt],'')
    ,[ParentId] = coalesce(rcp.[Id-tgt],s.[ParentId]+'+')
    ,[ContactId] = coalesce(rc.[Id-tgt],s.[ContactId]+'+')
    ,[SourceId] = s.[SourceId]
    ,[EntitlementId] = s.[EntitlementId]
    ,[Platform__c] = coalesce(rlp.[Id-tgt],s.[Platform__c]+'+')
    ,[Product__c] = coalesce(rld.[Id-tgt],s.[Product__c]+'+')
    ,[Onboarding_Offboarding__c] = coalesce(ro.[Id-tgt],s.[Onboarding_Offboarding__c]+'+')
    ,[ProductId] = coalesce(rp2.[Id-tgt],s.[ProductId]+'+')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
    ,[Internal_Raiser__c] = coalesce(rui.[Id],s.[Internal_Raiser__c]+'+')
    ,[Licensee_Supervisor_Name__c] = coalesce(u.[Id],s.[Licensee_Supervisor_Name__c]+'+')
    ,[Reviewer__c] = coalesce(rur.[Id],s.[Reviewer__c]+'+')
,[OwnerId] = coalesce(u1.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from [cte_src] s
left join [cte_Account] ram
    on ram.[Id-src] = s.[AccountId]
left join [cte_Account] rap
    on rap.[Id-src] = s.[Practice_Name__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[ContactId]
left join [cte_Case] rce
    on rce.[Id-src] = s.[Escalation_Case__c]
left join [cte_Case] rcp
    on rcp.[Id-src] = s.[ParentId]
left join [cte_BusinessHours] rbh
    on rbh.[Id-src] = s.[BusinessHoursId]
left join [cte_LookupName] rlp
    on rlp.[Id-src] = s.[Platform__c]
left join [cte_LookupName] rld
    on rld.[Id-src] = s.[Product__c]
left join [cte_Oppo] ro
    on ro.[Id-src] = s.[Onboarding_Offboarding__c]
left join [cte_Product2] rp2
    on rp2.[Id-src] = s.[ProductId]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
left join [cte_User] rui
    on rui.[Metazoa_External_ID__c] = s.[Internal_Raiser__c]
left join [cte_User] u
    on u.[Metazoa_External_ID__c] = s.[Licensee_Supervisor_Name__c]
left join [cte_User] rur
    on rur.[Metazoa_External_ID__c] = s.[Reviewer__c]
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[AccountId],'') is not null
--and nullif(ram.[id-tgt],'') is not null)
--or nullif(s.[AccountId],'') is null
--)
--and ((nullif(s.[Practice_Name__c],'') is not null
--and nullif(rap.[id-tgt],'') is not null)
--or nullif(s.[Practice_Name__c],'') is null
--)
--and ((nullif(s.[ContactId],'') is not null
--and nullif(rc.[id-tgt],'') is not null)
--or nullif(s.[ContactId],'') is null
--)
--and ((nullif(s.[Escalation_Case__c],'') is not null
--and nullif(rce.[id-tgt],'') is not null)
--or nullif(s.[Escalation_Case__c],'') is null
--)
--and ((nullif(s.[ParentId],'') is not null
--and nullif(rcp.[id-tgt],'') is not null)
--or nullif(s.[ParentId],'') is null
--)
--and ((nullif(s.[BusinessHoursId],'') is not null
--and nullif(rbh.[id-tgt],'') is not null)
--or nullif(s.[BusinessHoursId],'') is null
--)
--and ((nullif(s.[Platform__c],'') is not null
--and nullif(rlp.[id-tgt],'') is not null)
--or nullif(s.[Platform__c],'') is null
--)
--and ((nullif(s.[Product__c],'') is not null
--and nullif(rld.[id-tgt],'') is not null)
--or nullif(s.[Product__c],'') is null
--)
--and ((nullif(s.[Onboarding_Offboarding__c],'') is not null
--and nullif(ro.[id-tgt],'') is not null)
--or nullif(s.[Onboarding_Offboarding__c],'') is null
--)
--and ((nullif(s.[ProductId],'') is not null
--and nullif(rp2.[id-tgt],'') is not null)
--or nullif(s.[ProductId],'') is null
--)
--and ((nullif(s.[RecordTypeId],'') is not null
--and nullif(rrt.[id-tgt],'') is not null)
--or nullif(s.[RecordTypeId],'') is null
--)
--and ((nullif(s.[Internal_Raiser__c],'') is not null
--and nullif(rui.[id],'') is not null)
--or nullif(s.[Internal_Raiser__c],'') is null
--)
--and ((nullif(s.[Licensee_Supervisor_Name__c],'') is not null
--and nullif(u.[id],'') is not null)
--or nullif(s.[Licensee_Supervisor_Name__c],'') is null
--)
--and ((nullif(s.[Reviewer__c],'') is not null
--and nullif(rur.[id],'') is not null)
--or nullif(s.[Reviewer__c],'') is null
--)
go
