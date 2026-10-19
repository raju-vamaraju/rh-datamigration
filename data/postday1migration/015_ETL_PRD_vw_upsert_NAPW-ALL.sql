Use [SalesforceMigration]
go

drop view if exists [sfrhd].[vw_upsert_NAPW-ALL]
go

create view [sfrhd].[vw_upsert_NAPW-ALL] as
with cte_User as (
    select
        [Id]
        ,[Metazoa_External_ID__c]
    from [SalesforceMigration].[sfrhd].[User] (nolock)
    where 1=1
    and [Metazoa_External_ID__c] is not null
)
,cte_src as (
    select s.*
        ,[Id-tgt] = t.[Id]
    from [SalesforceMigration].[sf].[NAPW__c] s (nolock)
    join [SalesforceMigration].[sf].[Contact] c
        on c.[Id] = s.[AdviserSFID__c] 
        and c.[Licensee__c] in ('Bridges', 'Shadforth')
    left join [SalesforceMigration].[sfrhd].[NAPW__c] t (nolock)
        on t.[Metazoa_External_ID__c] = s.[Id]
    where 1=1
and t.[Id] is null
)
select -- top 1
    [Id] = coalesce(s.[Id-tgt],'')
    ,[Metazoa_External_ID__c] = s.[Id]
    ,s.[advice_for__c]
    ,s.[adviser_id__c]
    ,s.[Advisername__c]
    ,s.[AdviserSFID__c]
    ,s.[area_of_advice__c]
    ,s.[ASIC_AR_Number__c]
    ,s.[best_interest__c]
    ,s.[client_adviser__c]
    ,s.[client_entity_name__c]
    ,s.[client_id__c]
    ,s.[distribution_channel__c]
    ,s.[expiry_date__c]
    ,s.[Firstname__c]
    ,s.[fum__c]
    ,s.[individual_or_group_cover__c]
    ,s.[inside_or_outside_super__c]
    ,s.[Lastname__c]
    ,s.[life_sum_insured__c]
    ,s.[Name]
    ,s.[napw_apir_asx_code__c]
    ,s.[napw_external_research__c]
    ,s.[new_or_existing__c]
    ,s.[outcome__c]
    ,s.[outcome_commentary__c]
    ,s.[outcome_date__c]
    ,s.[partner_entity_name__c]
    ,s.[partner_id__c]
    ,s.[primary_group__c]
    ,s.[product_name__c]
    ,s.[salary_continuance_sum_insured__c]
    ,s.[submission_date__c]
    ,s.[tmd_link__c]
    ,s.[tpd_sum_insured__c]
    ,s.[trauma_sum_insured__c]
,[OwnerId] = u1.[Id]    -- coalesce(u1.[Id],'005W20000005SRtIAM')
,[CreatedById] = u2.[Id]    -- coalesce(u2.[Id],'005W20000005SRtIAM')
,[LastModifiedById] = u3.[Id]    -- coalesce(u3.[Id],'005W20000005SRtIAM')
,s.[CreatedDate]
,s.[LastModifiedDate]
from cte_src s
join [cte_User] u1
    on u1.[Metazoa_External_ID__c] = s.[OwnerId]
join [cte_User] u2
    on u2.[Metazoa_External_ID__c] = s.[CreatedById]
join [cte_User] u3
    on u3.[Metazoa_External_ID__c] = s.[LastModifiedById]
go
