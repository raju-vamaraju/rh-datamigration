Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_MasterQuestions_Targetedreviews-ALL]
go

create view [sfrhd].[vw_upsert_MasterQuestions_Targetedreviews-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Question_Group as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Question_Group__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Question_Group__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        --and i.[Licensee__c] like '%Shadforth%'
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[MasterQuestions_Targetedreviews__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[MasterQuestions_Targetedreviews__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Action__c]
    ,s.[Actions_Taken__c]
    ,s.[Active_From__c]
    ,s.[Active_Until__c]
    ,s.[Comment__c]
    ,s.[Default_Issue_Text_for_Vetting__c]
    ,s.[Default_Remedial_Actions_for_Vetting__c]
    ,s.[Description__c]
    ,s.[Display_Text_For_Reports__c]
    ,s.[EDP_External_Id__c]
    ,s.[External_ID__c]
    ,s.[Impact_on_Score__c]
    ,s.[Incident_Remediation_Text__c]
    ,[Is_Bank_Question__c] = iif(s.[Is_Bank_Question__c] = 1, 'true', 'false')
    ,s.[Key_Area__c]
    ,s.[Name]
    ,s.[Points__c]
    ,s.[Priority__c]
    ,s.[Process_Area__c]
    ,s.[Qn_Text_Key__c]
    ,s.[Question_Category__c]
    ,s.[Question_Number__c]
    ,s.[Question_Text__c]
    ,[Reportable__c] = iif(s.[Reportable__c] = 1, 'true', 'false')
    ,[Reportable_For_Reviews__c] = iif(s.[Reportable_For_Reviews__c] = 1, 'true', 'false')
    ,s.[Response_Options__c]
    ,s.[Rootcause_Options__c]
    ,s.[Standard__c]
    ,s.[Vetting_Action__c]
    ,s.[Vetting_Comments__c]
    ,[Vetting_Mandatory_Question__c] = iif(s.[Vetting_Mandatory_Question__c] = 1, 'true', 'false')
    ,s.[Wave_Internal__c]
    ,[Question_Group__c] = coalesce(qg.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Question_Group] qg
    on qg.[id-src] = s.[Question_Group__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Question_Group__c],'') is not null
and nullif(qg.[id-tgt],'') is not null)
or nullif(s.[Question_Group__c],'') is null
)
go
