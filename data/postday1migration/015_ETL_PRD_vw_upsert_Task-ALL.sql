USE [SalesforceMigration]
GO

/****** Object:  View [sfrhd].[vw_upsert_Task-ALL]    Script Date: 9/2/2026 2:16:01 PM ******/
DROP VIEW if exists [sfrhd].[vw_upsert_Task-ALL]
GO

/****** Object:  View [sfrhd].[vw_upsert_Task-ALL]    Script Date: 9/2/2026 2:16:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [sfrhd].[vw_upsert_Task-ALL] as
/*
select [task_pref] = left(s.[WhatId],3), [count] = count(*)
from [sf].[Task] s
join [SalesforceMigration].[sf].[Account] c
    on c.[Id] = s.[AccountId] 
    and c.[Licensee__c] in ('Bridges', 'Shadforth')
group by left(s.[WhatId],3)
order by left(s.[WhatId],3)

task_pref	count
NULL	1364
001	1557	-- Account
0XB	177	-- ListEmail
500	36	-- Case
a09	23045	-- Assurance_Review__c
a0D	1	-- Consequence_Management_Forum_Entry__c
a0F	2101	-- Incident_File_Review__c
a0N	6	-- InitiativeChecklist__c
a12	1149	-- ASF_CSA_Case__c
a1M	5358	-- ASIC_Breach__c
a1q	45	-- Control_Review__c
a1t	87	-- PEP__c
a26	232	-- ASF_CSA_Case_dv__c
a29	2	-- Calculation__c
a2A	671	-- Refund_Request__c
*/
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
,cte_ASF_CSA_Case as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[ASF_CSA_Case__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[ASF_CSA_Case__c] r (nolock)
        on r.[Integration_Id__c] = i.[Integration_Id__c]
)
,cte_ASF_CSA_Case_dv as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[ASF_CSA_Case_dv__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[ASF_CSA_Case_dv__c] r (nolock)
        on r.[Integration_Id__c] = i.[Integration_Id__c]
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
)
,cte_Consequence_Management_Forum_Entry as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Consequence_Management_Forum_Entry__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Consequence_Management_Forum_Entry__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
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
)
,cte_InitiativeChecklist as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[InitiativeChecklist__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[InitiativeChecklist__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_Calculation as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Calculation__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Calculation__c] r (nolock)
	    on r.[Refund_Reference__c] = i.[Refund_Reference__c]
	    and r.[Calculation_Type__c] = i.[Calculation_Type__c]
	    and r.[Product__c] = i.[Product__c]
	    and isnull(r.[Final_Refund_Amount__c],'') = isnull(i.[Final_Refund_Amount__c],'')
)
,cte_Refund_Request as (
    select
        [Id-src] = s.[Id]
        ,[Id-tgt] = t.[Id]
        ,[Name-src] = s.[Name]
        ,[Name-tgt] = t.[Name]
    from [SalesforceMigration].[sf].[Refund_Request__c] s (nolock)
    left join [SalesforceMigration].[sfrhd].[Contact] tc (nolock)
        on tc.[Metazoa_External_ID__c] = s.[Adviser_Name__c]
    left join [SalesforceMigration].[sfrhd].[Incident_File_Review__c] tif (nolock)
        on tif.[Metazoa_External_ID__c] = s.[Incident_Form__c]
    join [SalesforceMigration].[sfrhd].[Refund_Request__c] t (nolock)
        on isnull(t.[Xplan_ID__c],'') = isnull(s.[Xplan_ID__c],'')
        and isnull(t.[Adviser_Name__c],'') = isnull(tc.[Id],'')
        and isnull(t.[Counterfactual__c],'') = isnull(s.[Counterfactual__c],'')
        and isnull(t.[Final_Refund_Amount__c],'') = isnull(s.[Final_Refund_Amount__c],'')
        and isnull(t.[Incident_Form__c],'') = isnull(tif.[Id],'')
        and isnull(t.[Licensee__c],'') = isnull(s.[Licensee__c],'')
        and isnull(t.[Policy_Number__c],'') = isnull(s.[Policy_Number__c],'')
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
,cte_ASN_Indicator_History as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[ASN_Indicator_History__c] i (nolock)
    join [SalesforceMigration].[sf].[Contact] c (nolock)
        on c.[Id] = i.[Adviser__c]
    join [SalesforceMigration].[sfrhd].[ASN_Indicator_History__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id]
)
,cte_Question_Responses as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Question_Responses__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Question_Responses__c] r (nolock)
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
union
    select
        [id-src] = ''
        ,[id-tgt] = [Id]
        ,[Name-src] = [DeveloperName]
        ,[Name-tgt] = [DeveloperName]
    from [SalesforceMigration].[sfrhd].[RecordType] (nolock)
    where [DeveloperName] = 'Task_DM'
    and [SobjectType] = 'Task'
)
,cte_Response_Finding as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
        ,r.[Name]
    from [SalesforceMigration].[sf].[Response_Finding__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Response_Finding__c] r (nolock)
        on r.[Metazoa_External_ID__c] = i.[Id] 
)
,cte_Task as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Task_Number__c]
        ,[Name-tgt] = r.[Task_Number__c]
        ,r.[Task_Number__c]
    from [SalesforceMigration].[sf].[Task] i (nolock)
    join [SalesforceMigration].[sfrhd].[Task] r
        on r.[Metazoa_External_ID__c] = i.[Id] 
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Task] s (nolock)
    join [SalesforceMigration].[sf].[Account] c
        on c.[Id] = s.[AccountId] 
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Task] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
--and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[ActivityDate]
    ,s.[AdviceAssuranceTeamComments__c]
    ,s.[ASN_Decision__c]
    ,s.[CallDisposition]
    ,s.[CallDurationInSeconds]
    ,s.[CallObject]
    ,s.[CallType]
    ,s.[Changed_By__c]
    ,s.[Comments__c]
    ,s.[Communication_Channel__c]
    ,s.[Completed_Date__c]
    ,s.[CompletedDateTime]
    ,s.[Contact_Date__c]
    ,s.[Continue_to_Next_Phase__c]
    ,[Created_from_Std_QA_batch__c] = iif(s.[Created_from_Std_QA_batch__c] = 1, 'true', 'false')
    ,s.[Date_registered_booked_sent__c]
    ,s.[Description]
    ,s.[EDP_External_Id__c]
    ,s.[Future_time_period_Month_Year__c]
    ,[IsArchived] = iif(s.[IsArchived] = 1, 'true', 'false')
    ,[IsClosed] = iif(s.[IsClosed] = 1, 'true', 'false')
    ,[IsHighPriority] = iif(s.[IsHighPriority] = 1, 'true', 'false')
    ,[IsRecurrence] = iif(s.[IsRecurrence] = 1, 'true', 'false')
    ,[IsReminderSet] = iif(s.[IsReminderSet] = 1, 'true', 'false')
    ,[IsVisibleInSelfService] = iif(s.[IsVisibleInSelfService] = 1, 'true', 'false')
    ,s.[Legal_Privileged_Confidential__c]
    ,s.[Licensee_Supervisor_Comments__c]
    ,s.[Preferred_Name__c]
    ,s.[Priority]
    ,s.[Reason_Why__c]
    ,s.[Received_completed_attended_Date__c]
    ,s.[RecurrenceDayOfMonth]
    ,s.[RecurrenceDayOfWeekMask]
    ,s.[RecurrenceEndDateOnly]
    ,s.[RecurrenceInstance]
    ,s.[RecurrenceInterval]
    ,s.[RecurrenceMonthOfYear]
    ,s.[RecurrenceRegeneratedType]
    ,s.[RecurrenceStartDateOnly]
    ,s.[RecurrenceTimeZoneSidKey]
    ,s.[RecurrenceType]
    ,s.[ReminderDateTime]
    ,s.[Resource_Hours__c]
    ,s.[Section__c]
    ,s.[Source_Document__c]
    ,s.[Status]
    ,s.[Sub_Task__c]
    ,s.[Subject]
    ,s.[Support_Staff_Comments__c]
    ,s.[Task_Number__c]
    ,s.[Task_Owner__c]
    ,s.[TaskSubtype]
    ,s.[Technical_Proficiency_Rating__c]
    ,s.[Type]
    ,s.[WhatCount]
    ,s.[WhoCount]
    ,[WhatId] = coalesce(w001.[Id-tgt]
                        ,w500.[Id-tgt]
                        ,wa09.[Id-tgt]
                        ,wa0D.[Id-tgt]
                        ,wa0F.[Id-tgt]
                        ,wa0N.[Id-tgt]
                        ,wa12.[Id-tgt]
                        ,wa26.[Id-tgt]
                        ,wa29.[Id-tgt]
                        ,wa2A.[Id-tgt]
                        ,s.[WhatId]+'+'
                        ,'')
,[AccountId] = coalesce(ra.[Id-tgt],s.[AccountId]+'+')
,[ASN_Indicator_History__c] = coalesce(raih.[Id-tgt],s.[ASN_Indicator_History__c]+'+')
,[Assurance_Review__c] = coalesce(rar.[Id-tgt],s.[Assurance_Review__c]+'+')
,[WhoId] = coalesce(rc.[Id-tgt],s.[WhoId]+'+')
,[Question_Response__c] = coalesce(rqr.[Id-tgt],s.[Question_Response__c]+'+')
,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
,[Response_Finding__c] = coalesce(rrf.[Id-tgt],s.[Response_Finding__c]+'+')
,[RecurrenceActivityId] = coalesce(rt.[Id-tgt],s.[RecurrenceActivityId]+'+')
,[Colleague__c] = coalesce(ru.[Id],s.[Colleague__c]+'+')
,[OwnerId] = coalesce(u1.[Id],g.[Id-tgt], ad.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id], ad.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id], ad.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
,[WhatId-src] = s.[WhatId]
from cte_src s
left join [cte_Account] w001
    on w001.[Id-src] = s.[WhatId]
left join [cte_Case] w500
    on w500.[Id-src] = s.[WhatId]
left join [cte_Assurance_Review] wa09
    on wa09.[Id-src] = s.[WhatId]
left join [cte_Consequence_Management_Forum_Entry] wa0D
    on wa0D.[Id-src] = s.[WhatId]
left join [cte_Incident_File_Review] wa0F
    on wa0F.[Id-src] = s.[WhatId]
left join [cte_InitiativeChecklist] wa0N
    on wa0N.[Id-src] = s.[WhatId]
left join [cte_ASF_CSA_Case] wa12
    on wa12.[Id-src] = s.[WhatId]
left join [cte_ASF_CSA_Case_dv] wa26
    on wa26.[Id-src] = s.[WhatId]
left join [cte_Calculation] wa29
    on wa29.[Id-src] = s.[WhatId]
left join [cte_Refund_Request] wa2A
    on wa2A.[Id-src] = s.[WhatId]
left join [cte_Account] ra
    on ra.[Id-src] = s.[AccountId]
left join [cte_ASN_Indicator_History] raih
    on raih.[Id-src] = s.[ASN_Indicator_History__c]
left join [cte_Assurance_Review] rar
    on rar.[Id-src] = s.[Assurance_Review__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[WhoId]
left join [cte_Question_Responses] rqr
    on rqr.[Id-src] = s.[Question_Response__c]
left join [cte_RecordType] rrt
    on rrt.[Id-src] = isnull(s.[RecordTypeId],'')
left join [cte_Response_Finding] rrf
    on rrf.[Id-src] = s.[Response_Finding__c]
left join [cte_Task] rt
    on rt.[Id-src] = s.[RecurrenceActivityId]
left join [cte_User] ru
    on ru.[Metazoa_External_ID__c] = s.[Colleague__c]
left join [cte_Group] g
    on g.[id-src] = s.[OwnerId]
cross join [cte_Admin] ad
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[AccountId],'') is not null
--and nullif(ra.[id-tgt],'') is not null)
--or nullif(s.[AccountId],'') is null
--)
--and ((nullif(s.[ASN_Indicator_History__c],'') is not null
--and nullif(raih.[id-tgt],'') is not null)
--or nullif(s.[ASN_Indicator_History__c],'') is null
--)
--and ((nullif(s.[Assurance_Review__c],'') is not null
--and nullif(rar.[id-tgt],'') is not null)
--or nullif(s.[Assurance_Review__c],'') is null
--)
--and ((nullif(s.[WhoId],'') is not null
--and nullif(rc.[id-tgt],'') is not null)
--or nullif(s.[WhoId],'') is null
--)
--and ((nullif(s.[Question_Response__c],'') is not null
--and nullif(rqr.[id-tgt],'') is not null)
--or nullif(s.[Question_Response__c],'') is null
--)
--and ((nullif(s.[RecordTypeId],'') is not null
--and nullif(rrt.[id-tgt],'') is not null)
--or nullif(s.[RecordTypeId],'') is null
--)
--and ((nullif(s.[Response_Finding__c],'') is not null
--and nullif(rrf.[id-tgt],'') is not null)
--or nullif(s.[Response_Finding__c],'') is null
--)
--and ((nullif(s.[RecurrenceActivityId],'') is not null
--and nullif(rt.[id-tgt],'') is not null)
--or nullif(s.[RecurrenceActivityId],'') is null
--)
--and ((nullif(s.[Colleague__c],'') is not null
--and nullif(ru.[id],'') is not null)
--or nullif(s.[Colleague__c],'') is null
--)
GO
