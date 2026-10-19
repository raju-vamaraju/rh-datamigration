Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Contact-UPSERT]
go

create view [sfrhd].[vw_upsert_Contact-UPSERT] as
with cte_User as (
    select
        u.[Id]
        ,u.[Metazoa_External_ID__c]
        ,u.[Username]
    from [SalesforceMigration].[sfrhd].[User] u (nolock)
    where 1=1
    and u.[Metazoa_External_ID__c] is not null
union
    select 
        [id] = '005W200000HHVs2IAH'
        ,[Metazoa_External_ID__c] = '005Mq00000Ev88rIAB'
        ,[Username] = 'rakesh.kumar@rhombusadvisory.com.au.flow2sb'
)
,cte_Account as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Account] i (nolock)
    left join [SalesforceMigration].[sfrhd].[Account] r (nolock)
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
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Contact] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Contact] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
-- fox UPSERT
--and t.[AccountId] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,[LeadSource]
    ,[Licensee__c]
    ,[Licensee_Consultant__c] --= ruc.[id]
    ,[Licensee_Consultant_Email__c]
    ,[Licensee_Supervisor__c] --= rus.[id]
    ,[Licensee_Supervisor_Email__c]
    ,[Location__c]
    ,[MailingAddress]
    ,[MailingCity]
    ,[MailingCountry]
    ,[MailingGeocodeAccuracy]
    ,[MailingLatitude]
    ,[MailingLongitude]
    ,[MailingPostalCode]
    ,[MailingState]
    ,[MailingStreet]
    ,[MasterRecordId] = rcmr.[id-tgt]
    ,[Membership_Type__c]
    ,[MobilePhone]
    ,s.[Name]
    ,[Name_of_Previous_Licensee__c]
    ,[New_Entrant_Registration_Number_NERN__c]
    ,[Office_Structure__c]
    ,[Onboarded_On__c]
    ,[Other_Professional_Memberships__c]
    ,[OtherAddress]
    ,[OtherCity]
    ,[OtherCountry]
    ,[OtherGeocodeAccuracy]
    ,[OtherLatitude]
    ,[OtherLongitude]
    ,[OtherPhone]
    ,[OtherPostalCode]
    ,[OtherState]
    ,[OtherStreet]
    ,[Partner_AFSL__c]
    ,[Pathway_Assessment_Complete__c]
    ,[Phone]
    ,[PhotoUrl]
    ,[Place_of_Birth__c]
    ,[Portal_User_ID__c] = rupu.[id]
    ,[Practice_Compliance_Contact__c] = rucc.[id]
    ,[Practicing_Certificate_Cancellation_Date__c]
    ,[Practicing_Certificate_Issue_Date__c]
    ,[Preferred_Name__c]
    ,[Previous_Licensee_End_Date__c]
    ,[Previous_Licensee_Start_Date__c]
    ,[Professional_Memberships__c]
    ,[PY_Supervising_Adviser__c] = rca.[id-tgt]
    ,[PY_Supervising_Adviser_Secondary__c] = rcas.[id-tgt]
    ,[PY_Supervising_Adviser_Tertiary__c] = rcat.[id-tgt]
    ,[QTRP_Status__c] = replace([QTRP_Status__c], 'QTRP not met - Not providing advice', '')
    ,[RecordTypeId] = rrt.[id-tgt]
    ,[Recovery_Charge_Rate__c]
    ,[ReportsToId] = rcrt.[id-tgt]
    ,[Responsibility__c]
    ,[Role__c]
    ,[Salutation]
    ,[Scheduling_Frequency__c]
    --,[Specialist_Accreditation__c]
    ,[State__c]
    ,[Status__c]
    ,[Sub_Status__c]
    ,[SystemModstamp]
    ,[Tenure_With_Licensee__c]
    ,[Title]
    ,[Total_days_since_Last_Submission__c]
    ,[TPB_Expiry_Date__c]
    ,[TPB_Membership_Number__c]
    ,[TPB_Registration_Types__c]
    ,[TPB_Start_Date__c]
    ,[Type__c]
    ,[Vetting_Status__c]
    ,[Wholesale_Client_Adviser__c] = iif(s.[Wholesale_Client_Adviser__c] = 1, 'true', 'false')
    ,[X2022_Education_Exemption__c] = iif(s.[X2022_Education_Exemption__c] = 1, 'true', 'false')
    ,[XPLAN_ID__c]
    ,[XPLAN_Site_Adviser_Transitioned_To__c]
    ,[XPLAN_Site_To_Use_For_SSO__c]
    ,[Year_Started__c]
    ,[Access_Enabled_For_AdviserONE__c]
    ,[AccountId] = ram.[id-tgt]
    ,[Activity_Achieved__c]
    ,[Activity_Exceed__c]
    ,[Activity_Partial_achieved__c]
    ,[Advice_2_0_Transition_in_XPLAN__c]
    ,[Advice_Assurance_Panel_Lead__c] = rupl.[Id]
    ,[Advice_Assurance_Panel_Name__c]
    ,[Advice_Restriction__c]
    ,[Adviser_Client_Data_Retention_Method__c]
    ,[Adviser_Client_Release_Required__c] = iif(s.[Adviser_Client_Release_Required__c] = 1, 'true', 'false')
    ,[Adviser_Code__c]
    ,[Adviser_Recognition_Program__c] = iif(s.[Adviser_Recognition_Program__c] = 1, 'true', 'false')
    ,[Adviser_Record_Type_Name__c]
    ,[Adviser_Type__c]
    --,[AdviserID_18x__c]
    ,[AdviserONE_Support_Staff_Role__c]
    ,[Advisory_Board_Member__c] = iif(s.[Advisory_Board_Member__c] = 1, 'true', 'false')
    ,[AFA_Membership_Number__c]
    ,[AFP_Check__c]
    ,[AFP_Check_Date__c]
    ,[AFSL_of_Previous_Licensee__c]
    ,[AFSL_s_for_Cross_Endorsement__c]
    ,[Age__c]
    ,[ANZ_Employment_Start_Date__c]
    ,[ASIC_ACL__c]
    ,[ASIC_Ceased_Date__c]
    ,[ASIC_Number__c]
    ,[ASIC_Start_Date__c]
    ,[ASN_Source__c]
    ,[ASN_Start_Date__c]
    ,[AssistantName]
    ,[AssistantPhone]
    ,[Associated_Business__c]
    ,[Assurance_Review_Method__c]
    ,[ATTESTATION_Received__c]
    ,[ATTESTATION_Request_Sent__c]
    ,[ATTESTATION_Response_from_Adviser__c]
    ,[Birthdate]
    ,[Classifications__c]
    --,[ContactSource]
    ,[Country_of_Birth__c]
    ,[Cross_Endorsement__c]
    ,[Date_when_Attestation_was_Received__c]
    ,[Departed__c] = iif(s.[Departed__c] = 1, 'true', 'false')
    ,[Department]
    ,[Description]
    ,[Designation__c]
    ,[DoNotCall] = iif(s.[DoNotCall] = 1, 'true', 'false')
    ,[EDP_External_Id__c]
    ,[Email]
    ,[EmailBouncedDate]
    ,[EmailBouncedReason]
    ,[Expected_Leave_Start_Date__c]
    ,[Expected_Return_Date__c]
    ,[Experience_In_Yrs__c]
    ,[External_Paraplanning_Company__c]
    ,[Fax]
    ,[FirstName]
    ,[FPA_Membership_Number__c]
    ,[FTE__c]
    ,[Gender__c]
    ,[HasOptedOutOfEmail] = iif(s.[HasOptedOutOfEmail] = 1, 'true', 'false')
    ,[HasOptedOutOfFax] = iif(s.[HasOptedOutOfFax] = 1, 'true', 'false')
    ,[Higher_Education_Status__c]
    ,[Highest_Education_Level__c]
    ,[HomePhone]
    ,[Induction_Complete__c]
    ,[Industry_Exam_Pass_Date__c]
    ,[Industry_Exam_Status__c]
    ,[IsDeleted] = iif(s.[IsDeleted] = 1, 'true', 'false')
    ,[IsEmailBounced] = iif(s.[IsEmailBounced] = 1, 'true', 'false')
    ,[Jigsaw]
    ,[JigsawContactId]
    ,[Last_AQR_Date__c]
    ,[Last_AQR_Score__c]
    ,[Last_AQR_ScoreAE__c]
    ,[Last_Assurance_Review_Date__c]
    ,[Last_Assurance_Review_Score__c]
    ,[Last_Assurance_Reviewed_By__c] = ruar.[Id]
    ,[Last_ClientID_Xplan__c]
    ,[Last_Debrief_Date__c]
    ,[Last_Document_Received_Date__c]
    ,[Last_General_Advice_Review_Date__c]
    ,[Last_General_Advice_Reviewed_By__c] = ruga.[Id]
    ,[Last_General_Advice_Score__c]
    ,[Last_Regulatory_Compliance_Score__c]
    ,[LastActivityDate]
    ,[LastCURequestDate]
    ,[LastCUUpdateDate]
    ,[LastName]
    ,[LastReferencedDate]
    ,[LastViewedDate]
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ram
    on ram.[id-src] = s.[AccountId]
left join [cte_Contact] rcmr
    on rcmr.[id-src] = s.[MasterRecordId]
left join [cte_Contact] rca (nolock)
    on rca.[id-src] = s.[PY_Supervising_Adviser__c]
left join [cte_Contact] rcas (nolock)
    on rcas.[id-src] = s.[PY_Supervising_Adviser_Secondary__c]
left join [cte_Contact] rcat (nolock)
    on rcat.[id-src] = s.[PY_Supervising_Adviser_Tertiary__c]
left join [cte_Contact] rcrt (nolock)
    on rcrt.[id-src] = s.[ReportsToId]
left join [cte_RecordType] rrt
    on rrt.[id-src] = s.[RecordTypeId]
left join [cte_User] rupl (nolock)
    on rupl.[Metazoa_External_ID__c] = s.[Advice_Assurance_Panel_Lead__c]
left join [cte_User] ruar (nolock)
    on ruar.[Metazoa_External_ID__c] = s.[Last_Assurance_Reviewed_By__c]
left join [cte_User] ruga (nolock)
    on ruga.[Metazoa_External_ID__c] = s.[Last_General_Advice_Reviewed_By__c]
left join [cte_User] rucc (nolock)
    on rucc.[Metazoa_External_ID__c] = s.[Practice_Compliance_Contact__c]
left join [cte_User] rupu (nolock)
    on rupu.[Metazoa_External_ID__c] = s.[Portal_User_ID__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and s.[Id-tgt] is not null    -- only needed to resolve record logging issues
--and ram.[id-tgt] is not null
go
