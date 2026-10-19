Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Account-ALL]
go

create view [sfrhd].[vw_upsert_Account-ALL] as
with cte_Admin as (
    select top 1
        [Id]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Name] = 'Admin User'
    and [IsActive] = 1
)
,cte_User as (
    select
        u.[Id]
        ,u.[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] u (nolock)
    where 1=1
    and u.[Metazoa_External_ID__c] is not null
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
    from [SalesforceMigration].[sf].[Account] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Account] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 1
    [Id] = s.[Id-tgt]
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[ABN__c]
    ,s.[AccountNumber]
    ,s.[AccountSource]
    ,s.[ACN__c]
    ,s.[ACR_Go_Live_Date__c]
    ,s.[Activity_Achieved__c]
    ,s.[Activity_Exceed__c]
    ,s.[Activity_Partial_Achieved__c]
    ,s.[Advice_Model__c]
    ,s.[AFSL_of_Previous_Licensee__c]
    ,s.[Agreement_Date__c]
    ,s.[Amendment_Date_to_the_Agreement__c]
    ,s.[AnnualRevenue]
    ,s.[ANZ_Lookback_No_of_Fail_Outcomes__c]
    ,s.[ANZ_Lookback_No_of_Pass_Outcomes__c]
    ,s.[ANZ_Lookback_Outcome__c]
    ,s.[ASIC_Ceased_Date__c]
    ,s.[ASIC_Start_Date__c]
    ,s.[ATTESTATION_Received__c]
    ,s.[ATTESTATION_Request_Sent__c]
    ,s.[ATTESTATION_Response_from_Practice__c]
    ,s.[Authorized_Postcodes__c]
    ,s.[Average_AQR_Score__c]
    ,s.[BillingAddress]
    ,s.[BillingCity]
    ,s.[BillingCountry]
    ,s.[BillingGeocodeAccuracy]
    ,s.[BillingLatitude]
    ,s.[BillingLongitude]
    ,s.[BillingPostalCode]
    ,s.[BillingState]
    ,s.[BillingStreet]
    ,s.[Branding_Option__c]
    ,s.[CAR_Number__c]
    ,s.[Current_Resigned__c]
    ,s.[Date_when_Attestation_Response_Received__c]
    ,s.[Description]
    ,s.[Fax]
    ,s.[Industry]
    ,[IsCustomerPortal] = iif(s.[IsCustomerPortal] = 1, 'true', 'false')
    ,s.[IsDeleted]
    ,s.[Jigsaw]
    ,s.[JigsawCompanyId]
    ,s.[Last_Closed_PSA_Review_Date__c]
    ,s.[Last_Open_PSA_Review_Date__c]
    ,s.[Last_PSA_Review_Date__c]
    ,s.[Last_PSA_Score__c]
    ,s.[Legal_Entity_Name__c]
    ,s.[Licensee__c]
    ,[Licensee_Consultant__c] = ruc.[Id]
    ,[Licensee_Supervisor__c] = rus.[Id]
    ,[MasterRecordId] = ram.[id-tgt]
    ,[MLC__c] = iif(s.[MLC__c] = 1, 'true', 'false')
    ,s.[Name]
    ,s.[Name_of_Previous_Licensee__c]
    ,s.[Next_PSA_Due_Date__c]
    ,s.[Next_Scheduled_PSA_Review_Date__c]
    ,s.[Number_of_Adviser__c]
    ,s.[NumberOfEmployees]
    ,s.[Office_Type__c]
    ,s.[Onboarded_On__c]
    ,s.[Ownership]
    ,s.[Partner_AFSL__c]
    ,s.[Phone]
    ,s.[PhotoUrl]
    ,s.[Practice_Adoption_Program_Stage__c]
    ,s.[Practice_Client_Data_Retention_Method__c]
    ,[Practice_Client_Release_Required__c] = iif(s.[Practice_Client_Release_Required__c] = 1, 'true', 'false')
    ,s.[Practice_Code__c]
    ,s.[Practice_Email__c]
    ,s.[Practice_Grouping__c]
    ,s.[Practicing_Certificate_Cancellation_Date__c]
    ,s.[Previous_Licensee_End_Date__c]
    ,s.[Previous_Licensee_Start_Date__c]
    ,s.[Primary_Contact__c]
    ,s.[Primary_Contact_Email__c]
    ,s.[Primary_Contact_Phone__c]
    ,s.[Primary_Contact_Title__c]
    ,s.[Primary_Engagement__c]
    ,[Providing_Entity_Discussion__c] = iif(s.[Providing_Entity_Discussion__c] = 1, 'true', 'false')
    ,s.[Rating]
    ,[RecordTypeId] = rrt.[id-tgt]
    ,s.[Remuneration_Terms__c]
    ,s.[Services_Offshored__c]
    ,s.[ShippingAddress]
    ,s.[ShippingCity]
    ,s.[ShippingCountry]
    ,s.[ShippingGeocodeAccuracy]
    ,s.[ShippingLatitude]
    ,s.[ShippingLongitude]
    ,s.[ShippingPostalCode]
    ,s.[ShippingState]
    ,s.[ShippingStreet]
    ,s.[Sic]
    ,s.[SicDesc]
    ,s.[Site]
    ,s.[Status__c]
    ,s.[Sub_Status__c]
    ,s.[SystemModstamp]
    ,s.[TickerSymbol]
    ,s.[TPB_Membership_Number__c]
    ,s.[TPB_Reg_Expiry_Date__c]
    ,s.[TPB_Reg_Start_Date__c]
    ,s.[TPB_Reg_Type__c]
    ,s.[Type]
    ,s.[Wave_Internal__c]
    ,s.[Website]
    ,s.[Practicing_Certificate_Issue_Date__c]
,[OwnerId] = u1.[Id]
,[CreatedById] = u2.[Id]
,[LastModifiedById] = u3.[Id]
,s.[CreatedDate]
,s.[LastActivityDate]
,s.[LastModifiedDate]
,s.[LastReferencedDate]
,s.[LastViewedDate]
,s.[SourceSystemIdentifier]
from cte_src s
left join [cte_Account] ram
    on ram.[id-src] = s.[MasterRecordId]
left join [cte_RecordType] rrt
    on rrt.[id-src] = s.[RecordTypeId]
left join [cte_User] rus
    on rus.[Metazoa_External_ID__c] = s.[Licensee_Supervisor__c]
left join [cte_User] ruc
    on ruc.[Metazoa_External_ID__c] = s.[Licensee_Consultant__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
go
