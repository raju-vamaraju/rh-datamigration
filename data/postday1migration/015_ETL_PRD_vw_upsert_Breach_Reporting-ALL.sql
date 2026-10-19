Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Breach_Reporting-ALL]
go

create view [sfrhd].[vw_upsert_Breach_Reporting-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
)
,cte_Incident_File_Review as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Incident_File_Review__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Incident_File_Review__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
        and r.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
)
,cte_tgt as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sfrhd].[Breach_Reporting__c] s (nolock)
    join [SalesforceMigration].[sfrhd].[Incident_File_Review__c] t (nolock)
        on t.[Id] = s.[Incident_File_Review__c]
--        and t.[Licensee__c] = 'Shadforth'
    where 1=1
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Breach_Reporting__c] s (nolock)
    join [SalesforceMigration].[sf].[Incident_File_Review__c] c (nolock)
        on c.[Id] = s.[Incident_File_Review__c]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [cte_tgt] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[A10__c]
    ,s.[A2__c]
    ,s.[A3__c]
    ,s.[A4__c]
    ,s.[A5__c]
    ,s.[A6__c]
    ,s.[A8__c]
    ,s.[ASIC_Breach_Reference__c]
    ,s.[ASIC_Lodgement_status__c]
    ,s.[ASIC_Update_Date__c]
    ,s.[BRC_Date__c]
    ,s.[BRC_For_Noting_Date__c]
    ,s.[Breach_Details__c]
    ,s.[Breach_Report_date__c]
    ,s.[Breach_Status__c]
    ,s.[Client_Loss_Investigation_Complete_Date__c]
    ,s.[Client_Loss_Investigation_Start_date__c]
    ,s.[Client_Loss_Remediation_Completed_Date__c]
    ,s.[Client_Notice_Period_start_date__c]
    ,s.[Client_Notification_sent_date__c]
    ,s.[Date_Of_The_First_Instance_Of_The_Breach__c]
    ,s.[Date_Of_The_Last_Instance_Of_The_Breach__c]
    ,s.[DNU_Breach_report_required_date__c]
    ,s.[Estimated_Completion_Of_Investigation__c]
    ,s.[External_AFSL__c]
    ,s.[Incomplete_Investigation_Status__c]
    ,s.[Investigation_Comments__c]
    ,s.[Investigation_Start_Date__c]
    ,s.[Is_the_Event_Reportable__c]
    ,s.[Name]
    ,s.[Name_of_subject_of_reportable_situation__c]
    ,s.[Notice_of_Client_Loss_Investigation_outc__c]
    ,s.[Number_Of_Clients_Impacted__c]
    ,s.[Number_Of_Instances_Of_The_Breach__c]
    ,s.[Number_Of_Related_Reportable_Situations__c]
    ,s.[Q1__c]
    ,s.[Q10__c]
    ,s.[Q2__c]
    ,s.[Q3__c]
    ,s.[Q4__c]
    ,s.[Q5__c]
    ,s.[Q6__c]
    ,s.[Q7__c]
    ,s.[Q8__c]
    ,s.[Q9__c]
    ,s.[Reason_For_Breach__c]
    ,s.[Remediation_Rectification_Date__c]
    ,s.[Reportable_event_confirmation_date__c]
    ,s.[Section_of_Legislation_Breached__c]
    ,s.[Sub_REF_Date__c]
    ,s.[Subject_of_reportable_situation__c]
    ,s.[Summary_BREA_Details__c]
    ,s.[Total_Financial_Loss_in_terms__c]
    ,s.[Type_Of_Breach__c]
    ,[Incident_File_Review__c] = coalesce(rc.[Id-tgt],'')
    ,[Assigned_To__c] = coalesce(rp.[Id],'')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastActivityDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Incident_File_Review] rc
    on rc.[Id-src] = s.[Incident_File_Review__c]
left join [cte_User] rp
    on rp.[Metazoa_External_ID__c] = s.[Assigned_To__c]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
-- filters during datasb load
and ((nullif(s.[Incident_File_Review__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Incident_File_Review__c],'') is null
)
and ((nullif(s.[Assigned_To__c],'') is not null
and nullif(rp.[id],'') is not null)
or nullif(s.[Assigned_To__c],'') is null
)
go
