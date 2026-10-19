Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Paraplanning-ALL]
go

create view [sfrhd].[vw_upsert_Paraplanning-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
--    and [Licensee__c] in ('Bridges', 'Shadforth')
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
        --and r.[Licensee__c] in ('Bridges', 'Shadforth')
    where 1=1
    --and i.[Licensee__c] in ('Bridges', 'Shadforth')
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
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Paraplanning__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Paraplanning__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
    and s.[Licensee__c] in ('Bridges', 'Shadforth')
and t.[Id] is null
)
select -- top 10
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Additional_Hours__c]
    ,s.[Additional_Hours_new__c]
    ,s.[Additional_QDC_Time_Taken__c]
    ,s.[Additional_time_taken__c]
    ,s.[Amount__c]
    ,s.[Answer__c]
    ,[Approval_Sought_from_PDM__c] = iif(s.[Approval_Sought_from_PDM__c] = 1, 'true', 'false')
    ,s.[Areas_for_Improvement__c]
    ,s.[Areas_of_Advice__c]
    ,s.[Assigned_QDC_Date__c]
    ,s.[Assigned_Review_Date__c]
    ,s.[Assigned_Review_Date_aft_2_3_biz_days__c]
    ,s.[Assigned_SOA_due_date__c]
    ,s.[Assigned_SOA_due_date_Adjusted__c]
    ,s.[Client_name__c]
    ,s.[Client_Type__c]
    ,s.[Comment__c]
    ,s.[Comments_Completion_Notes__c]
    ,s.[Completed_Date__c]
    ,s.[Cost_per_extra_hour__c]
    ,s.[CSA_End_Date__c]
    ,s.[Data_Entry_Hours__c]
    ,s.[Data_Entry_Hours_new__c]
    ,s.[Data_Migration_Status__c]
    ,s.[Date_Advice_Request_Received__c]
    ,s.[Date_Outsourced__c]
    ,s.[Date_time_pending_OUT_1__c]
    ,s.[Date_time_pending_OUT_2__c]
    ,s.[Date_time_pending_OUT_3__c]
    ,s.[Date_time_resumed_IN_1__c]
    ,s.[Date_time_resumed_IN_2__c]
    ,s.[Date_time_resumed_IN_3__c]
    ,s.[Days_Pending_1__c]
    ,s.[Days_Pending_2__c]
    ,s.[Days_Pending_3__c]
    ,s.[Defined_Purpose_SOA__c]
    ,s.[Due_Date__c]
    ,s.[Fees_Standard__c]
    ,s.[FUM__c]
    ,s.[Goals_and_objectives__c]
    ,s.[Gross_Turnaround_days__c]
    ,s.[GST_rate__c]
    ,s.[Hold_1_Days_to_Exclude_from_TAT_WFA__c]
    ,s.[Hold_2_Days_to_Exclude_from_TAT_WFA__c]
    ,s.[Hold_3_Days_to_Exclude_from_TAT_WFA__c]
    ,s.[Inwealth_Charge__c]
    ,s.[Key_and_financial_information__c]
    ,s.[Last_ClientID_Xplan__c]
    ,s.[Licenseetext__c]
    ,s.[Meeting_Held_Date__c]
    ,s.[Name]
    ,s.[NBI__c]
    ,s.[Non_Working_Days_to_Exclude_from_TAT_WF__c]
    ,s.[On_Hold_Comments__c]
    ,s.[On_Hold_Email_Send_Date_1__c]
    ,s.[On_Hold_Email_Send_Date_2__c]
    ,s.[On_Hold_Email_Send_Date_3__c]
    ,s.[Ongoing_Fee_Bridges_Only__c]
    ,[OnHold__c] = iif(s.[OnHold__c] = 1, 'true', 'false')
    ,s.[Paraplanner_Assigned_Date__c]
    ,s.[Paraplanner_Quality_Items_Identified__c]
    ,s.[Peer_Review_Completed_Date__c]
    ,s.[Peer_Review_Date__c]
    ,s.[Plan_Type__c]
    ,s.[Planlogic_Charge__c]
    ,s.[Points_Allocation_New__c]
    ,s.[Points_Allocation_QDC__c]
    ,s.[Points_Allocation_SFG__c]
    ,s.[Points_Allocation_WFA__c]
    ,s.[Production__c]
    ,s.[Provide_a_brief_explanation__c]
    ,s.[QDC_Check_Completion_Date__c]
    ,s.[QDC_Check_Outcome__c]
    ,s.[QDC_Check_Time_min__c]
    ,s.[QDC_Checking_Area__c]
    ,s.[Question_1__c]
    ,s.[Question_2__c]
    ,s.[Quoting_Comments_Notes__c]
    ,s.[Reason_for_seeking_advice__c]
    ,s.[Rework__c]
    ,s.[Scoping_section__c]
    ,s.[SOA_Assigned_Date_aft_2_3_Biz_Days__c]
    ,s.[SOA_Document_Type__c]
    ,s.[SOA_Due_Date_Adjusted__c]
    ,[SOA_Ready_for_QDC_Check__c] = iif(s.[SOA_Ready_for_QDC_Check__c] = 1, 'true', 'false')
    ,s.[Status__c]
    ,s.[Strategy_Notes__c]
    ,s.[Submission_quality_items_identified__c]
    ,s.[Team_Location__c]
    ,s.[Time_critical_email_send_date__c]
    ,s.[Total_fee_factor__c]
    ,s.[Triage_End_Date__c]
    ,s.[Triage_Start_Date__c]
    ,s.[Type_of_QDC_Check__c]
    ,s.[Upfront_Fee_Bridges_Only__c]
    ,s.[Urgency__c]
    ,s.[Urgency_Notes__c]
    ,s.[Why_the_Difference__c]
    ,s.[Workflow_Analyst_Check_Date__c]
    ,s.[Workflow_Analyst_Check_Time_min__c]
    ,s.[Workflow_Quality_Items_Identified__c]
    ,s.[X1_On_Hold_Reason__c]
    ,s.[X2_On_Hold_Reason__c]
    ,s.[X3_On_Hold_Reason__c]
    ,[Adviser__c] = coalesce(ra.[Id-tgt],'')
    ,[Associate_Adviser__c] = coalesce(rc.[Id-tgt],'')
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
    ,[Assigned_Outsourcer__c] = coalesce(ruo.[Id],'')
    ,[Assigned_Paraplanner__c] = coalesce(rup.[Id],'')
    ,[Assigned_QDC__c] = coalesce(ruq.[Id],'')
    ,[Assigned_Reviewer__c] = coalesce(rur.[Id],'')
    ,[Assigned_Workflow_Analyst__c] = coalesce(ruw.[Id],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Contact] ra
    on ra.[Id-src] = s.[Adviser__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Associate_Adviser__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = s.[RecordTypeId]
left join [cte_User] ruo
    on ruo.[Metazoa_External_ID__c] = s.[Assigned_Outsourcer__c]
left join [cte_User] rup
    on rup.[Metazoa_External_ID__c] = s.[Assigned_Paraplanner__c]
left join [cte_User] ruq
    on ruq.[Metazoa_External_ID__c] = s.[Assigned_QDC__c]
left join [cte_User] rur
    on rur.[Metazoa_External_ID__c] = s.[Assigned_Reviewer__c]
left join [cte_User] ruw
    on ruw.[Metazoa_External_ID__c] = s.[Assigned_Workflow_Analyst__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Adviser__c],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
and ((nullif(s.[Associate_Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Associate_Adviser__c],'') is null
)
and ((nullif(s.[RecordTypeId],'') is not null
and nullif(rrt.[id-tgt],'') is not null)
or nullif(s.[RecordTypeId],'') is null
)
and ((nullif(s.[Assigned_Outsourcer__c],'') is not null
and nullif(ruo.[id],'') is not null)
or nullif(s.[Assigned_Outsourcer__c],'') is null
)
and ((nullif(s.[Assigned_Paraplanner__c],'') is not null
and nullif(rup.[id],'') is not null)
or nullif(s.[Assigned_Paraplanner__c],'') is null
)
and ((nullif(s.[Assigned_QDC__c],'') is not null
and nullif(ruq.[id],'') is not null)
or nullif(s.[Assigned_QDC__c],'') is null
)
and ((nullif(s.[Assigned_Reviewer__c],'') is not null
and nullif(rur.[id],'') is not null)
or nullif(s.[Assigned_Reviewer__c],'') is null
)
and ((nullif(s.[Assigned_Workflow_Analyst__c],'') is not null
and nullif(ruw.[id],'') is not null)
or nullif(s.[Assigned_Workflow_Analyst__c],'') is null
)
go
