Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Question_Responses-ALL]
go

create view [sfrhd].[vw_upsert_Question_Responses-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Group as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Type-src] = i.[Type]
        ,[DeveloperName-src] = i.[DeveloperName]
        ,[Name-tgt] = r.[Name]
        ,[Type-tgt] = r.[Type]
        ,[DeveloperName-tgt] = r.[DeveloperName]
    from [SalesforceMigration].[sf].[Group] i (nolock)
    join [SalesforceMigration].[sfrhd].[Group] r (nolock)
        on r.[Type] = i.[Type]
        and r.[DeveloperName] = i.[DeveloperName]
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
,cte_Client_File as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Client_File__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Client_File__c] r (nolock)
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
,cte_Master_Questions as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Master_Questions__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Master_Questions__c] r (nolock)
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
,cte_Vetting_Result as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Vetting_Result__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Vetting_Result__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Question_Responses__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Question_Responses__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
    and isnull(s.[Licensee__c],'') in ('Bridges', 'Shadforth', '')
--and s.[Id] = 'a0NMq0000008kX7MAI'
and t.[Id] is null
)
select -- top 10
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Actions_Taken__c]
    ,s.[Actual_Loss_in_terms__c]
    ,s.[Advice_Type__c]
    ,s.[Comment__c]
    ,s.[Comment_Yes__c]
    ,s.[Comments__c]
    ,s.[Date_Paid__c]
    ,s.[Document_Name__c]
    ,s.[EDP_External_Id__c]
    ,s.[External_ID__c]
    ,s.[Feedback__c]
    ,[Has_Action__c] = iif(s.[Has_Action__c] = 1, 'true', 'false')
    ,s.[Incident_Close_Date__c]
    ,s.[Incident_Status__c]
    ,s.[Key_Area__c]
    ,s.[Licensee__c]
    ,[Mark_as_Confidential__c] = iif(s.[Mark_as_Confidential__c] = 1, 'true', 'false')
    ,s.[Name]
    ,s.[Partner_AFSL__c]
    ,s.[Pre_Review_and_Overview_Response__c]
    ,s.[Prior_Owner__c]
    ,s.[QA_Rationale__c]
    ,s.[QA_Response__c]
    ,s.[Question_Number__c]
    ,s.[Question_Text__c]
    ,s.[Rationale__c]
    ,[Report_Breach__c] = iif(s.[Report_Breach__c] = 1, 'true', 'false')
    ,s.[Requires_Action__c]
    ,s.[Response__c]
    ,s.[Responsibility__c]
    ,s.[Root_Cause__c]
    ,[Practice__c] = coalesce(ra.[Id-tgt],s.[Practice__c]+'+')
    ,[Assurance_Review__c] = coalesce(rar.[Id-tgt],'')
    ,[Client_File__c] = coalesce(rcf.[Id-tgt],s.[Client_File__c]+'+')
    ,[Adviser__c] = coalesce(rc.[Id-tgt],s.[Adviser__c]+'+')
    ,[Incident_File_Review__c] = coalesce(rifr.[Id-tgt],s.[Incident_File_Review__c]+'+')
    ,[Question__c] = coalesce(rmq.[Id-tgt],'')
    ,s.[QuestionTr__c] -- = coalesce(rmqtr.[Id-tgt],'')
    ,s.[PSA__c] -- = ''  --coalesce(x.[Id-tgt],'')
    ,s.[Quality_Assurance__c] --= coalesce(rqa.[Id-tgt],'')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
    ,[Vetting_Result__c] = coalesce(rvr.[Id-tgt],'')
,[OwnerId] = coalesce(u1.[Id],g.[Id-tgt],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ra
    on ra.[Id-src] = s.[Practice__c]
left join [cte_Assurance_Review] rar
    on rar.[Id-src] = s.[Assurance_Review__c]
left join [cte_Client_File] rcf
    on rcf.[Id-src] = s.[Client_File__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
left join [cte_IFR] rifr
    on rifr.[Id-src] = s.[Incident_File_Review__c]
left join [cte_Master_Questions] rmq
    on rmq.[Id-src] = s.[Question__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
left join [cte_Vetting_Result] rvr
    on rvr.[Id-src] = s.[Vetting_Result__c]
left join [cte_Group] g
    on g.[id-src] = s.[OwnerId]
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Practice__c],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[Practice__c],'') is null
)
and ((nullif(s.[Assurance_Review__c],'') is not null
and nullif(rar.[id-tgt],'') is not null)
or nullif(s.[Assurance_Review__c],'') is null
)
and ((nullif(s.[Client_File__c],'') is not null
and nullif(rcf.[id-tgt],'') is not null)
or nullif(s.[Client_File__c],'') is null
)
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
and ((nullif(s.[Incident_File_Review__c],'') is not null
and nullif(rifr.[id-tgt],'') is not null)
or nullif(s.[Incident_File_Review__c],'') is null
)
and ((nullif(s.[Question__c],'') is not null
and nullif(rmq.[id-tgt],'') is not null)
or nullif(s.[Question__c],'') is null
)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
and ((nullif(s.[Vetting_Result__c],'') is not null
and nullif(rvr.[id-tgt],'') is not null)
or nullif(s.[Vetting_Result__c],'') is null
)
go
