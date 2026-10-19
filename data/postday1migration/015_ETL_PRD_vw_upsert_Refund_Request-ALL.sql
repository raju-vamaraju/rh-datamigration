Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Refund_Request-ALL]
go

create view [sfrhd].[vw_upsert_Refund_Request-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
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
        ,[Name-src] = i.[CaseNumber]
        ,[Name-tgt] = r.[CaseNumber]
    from [SalesforceMigration].[sf].[Case] i (nolock)
    join [SalesforceMigration].[sfrhd].[Case] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
    where 1=1
)
,cte_IFR as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Incident_File_Review__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Incident_File_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
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
,cte_tgt as (
    select
        [Id] = s.[Id]
        ,[Xplan_ID__c-src] = isnull(s.[Xplan_ID__c],'')
        ,[Adviser_Name__c-src] = isnull(c.[id-src],'')
        ,[Counterfactual__c-src] = isnull(s.[Counterfactual__c],'')
        ,[Final_Refund_Amount__c-src] = isnull(s.[Final_Refund_Amount__c],'')
        ,[Incident_Form__c-src] = isnull(ifr.[id-src],'')
        ,[Licensee__c-src] = isnull(s.[Licensee__c],'')
        ,[Policy_Number__c-src] = isnull(s.[Policy_Number__c],'')
    from [SalesforceMigration].[sfrhd].[Refund_Request__c] s (nolock)
    join [cte_Contact] c (nolock)
        on c.[id-tgt] = s.[Adviser_Name__c]
    left join [cte_IFR] ifr (nolock)
        on ifr.[id-tgt] = s.[Incident_Form__c]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Refund_Request__c] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = s.[Adviser_Name__c]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [cte_tgt] t (nolock)
        on t.[Xplan_ID__c-src] = isnull(s.[Xplan_ID__c],'')
        and t.[Adviser_Name__c-src] = isnull(s.[Adviser_Name__c],'')
        and t.[Counterfactual__c-src] = isnull(s.[Counterfactual__c],'')
        and t.[Final_Refund_Amount__c-src] = isnull(s.[Final_Refund_Amount__c],'')
        and t.[Incident_Form__c-src] = isnull(s.[Incident_Form__c],'')
        and t.[Licensee__c-src] = isnull(s.[Licensee__c],'')
        and t.[Policy_Number__c-src] = isnull(s.[Policy_Number__c],'')
    where 1=1
and t.[Id] is null
)
select -- top 10
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Alternative_payment_Confirmation_Date__c]
    ,s.[Alternative_payment_Request_Sent_Date__c]
    ,[At_Fault__c] = coalesce(s.[At_Fault__c],'')
    ,[Calculation_required__c] = coalesce(s.[Calculation_required__c],'')
    ,[Client_Category__c] = coalesce(s.[Client_Category__c],'')
    ,s.[Comments__c]
    ,s.[Confirm_payment_with_Trustee__c]
    ,s.[Counterfactual__c]
    ,s.[Date_Refund_Assessed__c]
    ,s.[Date_Refund_Processed__c]
    ,s.[Date_Refund_Submitted__c]
    ,s.[Final_Refund_Amount__c]
    ,s.[Form_Submitted_Date__c]
    ,[Further_Information_provided__c] = iif(s.[Further_Information_provided__c] = 1, 'true', 'false')
    ,[Further_information_received__c] = iif(s.[Further_information_received__c] = 1, 'true', 'false')
    ,[Further_Information_required__c] = iif(s.[Further_Information_required__c] = 1, 'true', 'false')
    ,[Have_you_provided_bank_details__c] = iif(s.[Have_you_provided_bank_details__c] = 1, 'true', 'false')
    ,s.[Interest__c]
    ,s.[LICENSEE_NAME__c]
    ,s.[Name]
    ,s.[Name_of_Client_s__c]
    ,[Payment_confirmation_received__c] = iif(s.[Payment_confirmation_received__c] = 1, 'true', 'false')
    ,s.[Payment_processing_method__c]
    ,[Payment_request_lodged__c] = iif(s.[Payment_request_lodged__c] = 1, 'true', 'false')
    ,s.[Policy_Number__c]
    ,[Policy_Status__c] = coalesce(s.[Policy_Status__c],'')
    ,s.[Product_Platform_s_For_Refund_Payment__c]
    ,s.[Product_Provider__c]
    ,[Reason_for_Refund__c] = coalesce(s.[Reason_for_Refund__c],'')
    ,s.[Refund_In_Scope__c]
    ,s.[Refund_Period_End_Date__c]
    ,s.[Refund_Period_Start_Date__c]
    ,[Refund_Required__c] = coalesce(s.[Refund_Required__c],'')
    ,[Refund_Type__c] = coalesce(s.[Refund_Type__c],'')
    ,s.[Related_Entity__c]
    ,[Remediation_Refund__c] = iif(s.[Remediation_Refund__c] = 1, 'true', 'false')
    ,s.[Request_Sent_Date__c]
    ,s.[Revenue_Confirmation_Date__c]
    ,[Stage__c] = coalesce(s.[Stage__c],'')
    ,[Status__c] = coalesce(s.[Status__c],'')
    ,[Status_Alt_Payment__c] = coalesce(s.[Status_Alt_Payment__c],'')
    ,[Status_Revenue__c] = coalesce(s.[Status_Revenue__c],'')
    ,s.[Trustee_confirmation_of_Payment__c]
    ,s.[Trustee_manager_notification__c]
    ,[Trustee_outcome__c] = coalesce(s.[Trustee_outcome__c],'')
    ,s.[Trustee_Process_Start_Date__c]
    ,[Type_of_Payment__c] = coalesce(s.[Type_of_Payment__c],'')
    ,s.[Xplan_ID__c]
    ,[Case_Number__c] = coalesce(ra.[Id-tgt],s.[Case_Number__c]+'+')
    ,[Adviser_Name__c] = coalesce(rc.[Id-tgt],s.[Adviser_Name__c]+'+')
    ,[Incident_Form__c] = coalesce(rifr.[Id-tgt],s.[Incident_Form__c]+'+')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
    ,[Assigned_To_Ops_Team__c] = coalesce(rua.[Id],s.[Assigned_To_Ops_Team__c]+'+')
    ,[Assigned_to_Trustee_Payment__c] = coalesce(rut.[Id],s.[Assigned_to_Trustee_Payment__c]+'+')
    ,[Responsible__c] = coalesce(rur.[Id],s.[Responsible__c]+'+')
,[OwnerId] = coalesce(u1.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Case] ra
    on ra.[Id-src] = s.[Case_Number__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser_Name__c]
left join [cte_IFR] rifr
    on rifr.[Id-src] = s.[Incident_Form__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
left join [cte_User] rua
    on rua.[Metazoa_External_ID__c] = s.[Assigned_To_Ops_Team__c]
left join [cte_User] rut
    on rut.[Metazoa_External_ID__c] = s.[Assigned_to_Trustee_Payment__c]
left join [cte_User] rur
    on rur.[Metazoa_External_ID__c] = s.[Responsible__c]
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[Case_Number__c],'') is not null
--and nullif(ra.[id-tgt],'') is not null)
--or nullif(s.[Case_Number__c],'') is null
--)
--and ((nullif(s.[Adviser_Name__c],'') is not null
--and nullif(rc.[id-tgt],'') is not null)
--or nullif(s.[Adviser_Name__c],'') is null
--)
--and ((nullif(s.[Incident_Form__c],'') is not null
--and nullif(rifr.[id-tgt],'') is not null)
--or nullif(s.[Incident_Form__c],'') is null
--)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
--and ((nullif(s.[Assigned_To_Ops_Team__c],'') is not null
--and nullif(rua.[Id],'') is not null)
--or nullif(s.[Assigned_To_Ops_Team__c],'') is null
--)
--and ((nullif(s.[Assigned_to_Trustee_Payment__c],'') is not null
--and nullif(rut.[Id],'') is not null)
--or nullif(s.[Assigned_to_Trustee_Payment__c],'') is null
--)
--and ((nullif(s.[Responsible__c],'') is not null
--and nullif(rur.[Id],'') is not null)
--or nullif(s.[Responsible__c],'') is null
--)
go
