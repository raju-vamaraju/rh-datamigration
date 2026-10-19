Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Calculation-ALL]
go

create view [sfrhd].[vw_upsert_Calculation-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
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
,cte_tgt as (
    select
        [Id] = s.[Id]
	    ,[Refund_Reference__c-src] = isnull(s.[Refund_Reference__c],'')
	    ,[Calculation_Type__c-src] = isnull(s.[Calculation_Type__c],'')
	    ,[Product__c-src] = isnull(s.[Product__c],'')
	    ,[Final_Refund_Amount__c-src] = isnull(s.[Final_Refund_Amount__c],'')
    from [SalesforceMigration].[sfrhd].[Calculation__c] s (nolock)
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Calculation__c] s (nolock)
    left join [cte_tgt] t (nolock)
	    on t.[Refund_Reference__c-src] = isnull(s.[Refund_Reference__c],'')
	    and t.[Calculation_Type__c-src] = isnull(s.[Calculation_Type__c],'')
	    and t.[Product__c-src] = isnull(s.[Product__c],'')
	    and t.[Final_Refund_Amount__c-src] = isnull(s.[Final_Refund_Amount__c],'')
    where 1=1
	and s.[Product__c] <> 'Test'  -- this causes duplication
    and s.[Licensee__c] in ('Bridges','Shadforth')
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[Actual_Reference_portfolio__c]
    ,s.[Additional_Comments__c]
    ,[Basic__c] = iif(s.[Basic__c] = 1, 'true', 'false')
    ,s.[Cancellation_reason__c]
    ,[Client_Detriment__c] = iif(s.[Client_Detriment__c] = 1, 'true', 'false')
    ,[Complex__c] = iif(s.[Complex__c] = 1, 'true', 'false')
    ,s.[Counterfactual__c]
    ,s.[Final_Refund_Amount__c]
    ,s.[Interest__c]
    ,s.[Interest_earnings_end_date__c]
    ,[IsDeleted] = iif(s.[IsDeleted] = 1, 'true', 'false')
    ,s.[LastActivityDate]
    ,s.[LastReferencedDate]
    ,s.[LastViewedDate]
    ,s.[Location_supporting_documents__c]
    ,s.[Name]
    ,s.[Product__c]
    ,s.[QA_Completed_Date__c]
    ,s.[QA_Output__c]
    ,s.[QA_required__c]
    ,[Re_Calculation_required__c] = iif(s.[Re_Calculation_required__c] = 1, 'true', 'false')
    ,s.[Refund_In_Scope__c]
    ,s.[Risk_profile_specify_G_D_split__c]
    ,s.[Stage__c]
    ,s.[Supporting_comments__c]
    ,s.[SystemModstamp]
    ,[RecordTypeId] = coalesce(rrt.[Id-tgt],'')
    ,[Refund_Reference__c] = coalesce(rr.[Id-tgt],s.[Refund_Reference__c]+'+')
    ,[Assigned_To__c] = coalesce(ast.[Id],s.[Assigned_To__c]+'+')
    ,[QA_Assigned_To__c] = coalesce(qat.[Id],s.[QA_Assigned_To__c]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_RecordType] rrt
    on rrt.[id-src] = s.[RecordTypeId]
left join [cte_Refund_Request] rr
    on rr.[Id-src] = s.[Refund_Reference__c]
left join [cte_User] ast
    on ast.[Metazoa_External_ID__c] = s.[Assigned_To__c]
left join [cte_User] qat
    on qat.[Metazoa_External_ID__c] = s.[QA_Assigned_To__c]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
go
