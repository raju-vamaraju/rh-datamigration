Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Event-ALL]
go

create view [sfrhd].[vw_upsert_Event-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
    --and [Licensee__c] = 'Shadforth'
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
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
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
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
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
        --and r.[Licensee__c] like '%Shadforth%'
    where 1=1
    --and i.[Licensee__c] like '%Shadforth%'
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
        --and i.[Licensee__c] like '%Shadforth%'
    where 1=1
    --and i.[licensee__c] like '%Shadforth%'
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Event] s (nolock)
    join [SalesforceMigration].[sf].[Account] c (nolock)
        on c.[Id] = s.[AccountId]
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Event] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[ActivityDate]
    ,s.[ActivityDateTime]
    ,s.[AdviceAssuranceTeamComments__c]
    ,s.[ASN_Decision__c]
    ,s.[Changed_By__c]
    ,s.[Comments__c]
    ,s.[Communication_Channel__c]
    ,s.[Completed_Date__c]
    ,s.[Contact_Date__c]
    ,s.[Continue_to_Next_Phase__c]
    ,[Created_from_Std_QA_batch__c] = ''    --iif(s.[Created_from_Std_QA_batch__c] = 1, 'true', 'false')
    ,s.[Date_registered_booked_sent__c]
    ,s.[Description]
    ,s.[DurationInMinutes]
    ,s.[EDP_External_Id__c]
    ,s.[EndDate]
    ,s.[EndDateTime]
    ,s.[EventSubtype]
    ,s.[Future_time_period_Month_Year__c]
    ,s.[GroupEventType]
    ,[IsAllDayEvent] = iif(s.[IsAllDayEvent] = 1, 'true', 'false')
    ,[IsArchived] = iif(s.[IsArchived] = 1, 'true', 'false')
    ,[IsChild] = iif(s.[IsChild] = 1, 'true', 'false')
    ,[IsGroupEvent] = iif(s.[IsGroupEvent] = 1, 'true', 'false')
    ,[IsPrivate] = iif(s.[IsPrivate] = 1, 'true', 'false')
    ,[IsRecurrence] = iif(s.[IsRecurrence] = 1, 'true', 'false')
    ,[IsRecurrence2] = iif(s.[IsRecurrence2] = 1, 'true', 'false')
    ,[IsRecurrence2Exception] = iif(s.[IsRecurrence2Exception] = 1, 'true', 'false')
    ,[IsRecurrence2Exclusion] = iif(s.[IsRecurrence2Exclusion] = 1, 'true', 'false')
    ,[IsReminderSet] = iif(s.[IsReminderSet] = 1, 'true', 'false')
    ,[IsVisibleInSelfService] = iif(s.[IsVisibleInSelfService] = 1, 'true', 'false')
    ,s.[Legal_Privileged_Confidential__c]
    ,s.[Licensee_Supervisor_Comments__c]
    ,s.[Location]
    ,s.[Preferred_Name__c]
    ,s.[Reason_Why__c]
    ,s.[Received_completed_attended_Date__c]
    ,s.[Recurrence2PatternStartDate]
    ,s.[Recurrence2PatternText]
    ,s.[Recurrence2PatternTimeZone]
    ,s.[Recurrence2PatternVersion]
    ,s.[RecurrenceDayOfMonth]
    ,s.[RecurrenceDayOfWeekMask]
    ,s.[RecurrenceEndDateOnly]
    ,s.[RecurrenceInstance]
    ,s.[RecurrenceInterval]
    ,s.[RecurrenceMonthOfYear]
    ,s.[RecurrenceStartDateTime]
    ,s.[RecurrenceTimeZoneSidKey]
    ,s.[RecurrenceType]
    ,s.[ReminderDateTime]
    ,s.[Resource_Hours__c]
    ,s.[Section__c]
    ,s.[ShowAs]
    ,[Source_Document__c] = ''
    ,s.[StartDateTime]
    ,s.[Sub_Task__c]
    ,s.[Subject]
    ,s.[Support_Staff_Comments__c]
    ,s.[Task_Number__c]
    ,s.[Task_Owner__c]
    ,s.[Technical_Proficiency_Rating__c]
    ,s.[Type]
    ,s.[WhatCount]
    ,s.[WhoCount]
    ,[WhatId] = ''  --coalesce(x.[Id-tgt],'')
    ,[AccountId] = coalesce(ra.[Id-tgt],'')
    ,[ASN_Indicator_History__c] = ''    --coalesce(x.[Id-tgt],'')
    ,[Assurance_Review__c] = coalesce(rar.[Id-tgt],'')
    ,[WhoId] = coalesce(rc.[Id-tgt],'')
    ,[RecurrenceActivityId] = ''    --coalesce(re.[Id-tgt],'')
    ,[Question_Response__c] = coalesce(rqr.[Id-tgt],'')
    ,[Response_Finding__c] = '' -- coalesce(rrf.[Id-tgt],'')
    ,[Colleague__c] = coalesce(ruo.[Id],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Account] ra
    on ra.[Id-src] = s.[AccountId]
left join [cte_Assurance_Review] rar
    on rar.[Id-src] = s.[Assurance_Review__c]
left join [cte_Contact] rc
    on rc.[Id-src] = s.[WhoId]
--left join [cte_Event] re
--    on re.[Id-src] = s.[RecurrenceActivityId]
left join [cte_Question_Responses] rqr
    on rqr.[Id-src] = s.[Question_Response__c]
--left join [cte_Response_Findings] rrf
--    on rrf.[Id-src] = s.[Response_Finding__c]
left join [cte_User] ruo
    on ruo.[Metazoa_External_ID__c] = s.[Colleague__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[AccountId],'') is not null
and nullif(ra.[id-tgt],'') is not null)
or nullif(s.[AccountId],'') is null
)
and ((nullif(s.[Assurance_Review__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Assurance_Review__c],'') is null
)
and ((nullif(s.[WhoId],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[WhoId],'') is null
)
and ((nullif(s.[Question_Response__c],'') is not null
and nullif(rqr.[id-tgt],'') is not null)
or nullif(s.[Question_Response__c],'') is null
)
and ((nullif(s.[Colleague__c],'') is not null
and nullif(ruo.[id],'') is not null)
or nullif(s.[Colleague__c],'') is null
)
go
