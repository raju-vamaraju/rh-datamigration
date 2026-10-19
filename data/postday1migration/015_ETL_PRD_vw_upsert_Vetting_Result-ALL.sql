Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_Vetting_Result-ALL]
go

create view [sfrhd].[vw_upsert_Vetting_Result-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_Area_of_Advice as (
    select
        [id-src] = i.[Id]
        ,[id-tgt] = r.[Id]
        ,[Name-src] = i.[Name]
        ,[Name-tgt] = r.[Name]
    from [SalesforceMigration].[sf].[Area_of_Advice__c] i (nolock)
    join [SalesforceMigration].[sfrhd].[Area_of_Advice__c] r (nolock)
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
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[Vetting_Result__c] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c
        on c.[Id] = s.[Adviser_Id__c] 
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[Vetting_Result__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,[ARResubmitted__c] = iif(s.[ARResubmitted__c] = 1, 'true', 'false')
    ,s.[EDP_External_Id__c]
    ,s.[File_Number__c]
    ,[MandatoryQuestionsFail__c] = iif(s.[MandatoryQuestionsFail__c] = 1, 'true', 'false')
    ,s.[Name]
    ,s.[Number_of_High_Issues__c]
    ,s.[Number_of_Low_Issues__c]
    ,s.[Number_of_Medium_issues__c]
    ,s.[Phase_Number__c]
    ,s.[Reason_for_Vetting__c]
    ,s.[Total_Number_of_Issues__c]
    ,s.[Vetting_Status_at_Finish__c]
    ,s.[Vetting_Status_at_Start__c]
    ,[Area_of_Advice__c] = coalesce(raa.[Id-tgt],s.[Area_of_Advice__c]+'+')
    ,[Assurance_Review__c] = coalesce(rar.[Id-tgt],s.[Assurance_Review__c]+'+')
,[OwnerId] = coalesce(u1.[Id],s.[OwnerId]+'+')
,[CreatedById] = coalesce(u2.[Id],s.[CreatedById]+'+')
,[LastModifiedById] = coalesce(u3.[Id],s.[LastModifiedById]+'+')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
left join [cte_Area_of_Advice] raa
    on raa.[Id-src] = s.[Area_of_Advice__c]
left join [cte_Assurance_Review] rar
    on rar.[Id-src] = s.[Assurance_Review__c]
left join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
left join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
left join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
where 1=1
--and ((nullif(s.[Area_of_Advice__c],'') is not null
--and nullif(raa.[id-tgt],'') is not null)
--or nullif(s.[Area_of_Advice__c],'') is null
--)
--and ((nullif(s.[Assurance_Review__c],'') is not null
--and nullif(rar.[id-tgt],'') is not null)
--or nullif(s.[Assurance_Review__c],'') is null
--)
go
