Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_BID_Case-ALL]
go

create view [sfrhd].[vw_upsert_BID_Case-ALL] as
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
        --and r.[Licensee__c] = 'Shadforth'
    where 1=1
    --and i.[Licensee__c] = 'Shadforth'
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[BID_Case__c] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c
        on c.[Id] = s.[Adviser__c] 
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[BID_Case__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Adviser_ph_call_completed__c]
    ,s.[Area_of_advice__c]
    ,s.[Call_invoiced_to_client__c]
    ,s.[Case_issue__c]
    ,s.[Case_Status__c]
    ,s.[Complexity_of_Advice__c]
    ,s.[Customer_1_First_Name__c]
    ,s.[Customer_1_Surname__c]
    ,s.[Customer_2_First_Name__c]
    ,s.[Customer_2_Surname__c]
    ,s.[Date_BID_review_completed__c]
    ,s.[Date_call_completed__c]
    ,s.[Date_case_due__c]
    ,s.[Date_of_BID_review_received__c]
    ,s.[Date_scheduled_audit__c]
    ,s.[Days_overdue__c]
    ,s.[Initial_triage_outcome__c]
    ,s.[Integration_ID__c]
    ,s.[Invoiced_to_the_client__c]
    ,s.[IsActive__c]
    ,s.[Name]
    ,s.[No_of_new_documents_received_01__c]
    ,s.[No_of_new_documents_received_02__c]
    ,s.[Outcome_of_BID_review__c]
    ,s.[Resub01_date_completed__c]
    ,s.[Resub01_date_received__c]
    ,s.[Resub01_invoiced_to_client__c]
    ,s.[Resub01_Outcome_of_BID_review__c]
    ,s.[Resub02_date_completed__c]
    ,s.[Resub02_date_received__c]
    ,s.[Resub02_invoiced_to_client__c]
    ,s.[Resub02_Outcome_of_Bid_review__c]
    ,s.[Resubmission_01_Case_Status__c]
    ,s.[Resubmission_02_Case_Status__c]
    ,s.[SubmissionNumber__c]
    ,[Adviser__c] = coalesce(rc.[Id-tgt],'')
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Contact] rc
    on rc.[Id-src] = s.[Adviser__c]
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
and ((nullif(s.[Adviser__c],'') is not null
and nullif(rc.[id-tgt],'') is not null)
or nullif(s.[Adviser__c],'') is null
)
go
