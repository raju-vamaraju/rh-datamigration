Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Client_File-ALL]
go

create view [sfrhd].[vw_upsert_Client_File-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
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
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Client_File__c] s (nolock)
    join [SalesforceMigration].[sf].[Assurance_Review__c] c (nolock)
        on c.[Id] = s.[Review__c]
    join [SalesforceMigration].[sf].[Account] a (nolock)
        on a.[Id] = c.[Practice__c]
        and a.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Client_File__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Advice_Document_Type__c]
    ,s.[Advice_Type__c]
    ,s.[Application_Date__c]
    ,s.[Chosen_for_Review__c]
    ,s.[Client_Contact_Type__c]
    ,s.[Client_File_Questionnaire_Status__c]
    ,s.[ClientID_Xplan__c]
    ,s.[Date_of_Advice__c]
    ,s.[Date_Time_of_Phone_Call__c]
    ,s.[EDP_External_Id__c]
    ,s.[Fact_Find_Date_Signed__c]
    ,s.[File_Selection_Date__c]
    ,s.[General_Advice_Score_Impact__c]
    ,s.[Name]
    ,s.[Number_of_General_Advice_Complaince__c]
    ,s.[Number_of_High_Issues__c]
    ,s.[Number_of_Low_Issues__c]
    ,s.[Number_of_Medium_Issues__c]
    ,s.[Number_of_Regulatory_Complaince__c]
    ,s.[Preferred_Name__c]
    ,s.[Products_Recommended__c]
    ,s.[Products_recommended_Other__c]
    ,s.[Products_Recommended_review__c]
    ,s.[Reason__c]
    ,s.[Reason_for_Choosing__c]
    ,s.[Regulatory_Compliance_Score_Impact__c]
    ,s.[Source_of_file__c]
    ,s.[Total_Number_of_Issues__c]
    ,[Review__c] = coalesce(ra.[Id-tgt],s.[Review__c]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Assurance_Review] ra
    on ra.[Id-src] = s.[Review__c]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[Review__c],'') is not null
--and nullif(ra.[id-tgt],'') is not null)
--or nullif(s.[Review__c],'') is null
--)
go
