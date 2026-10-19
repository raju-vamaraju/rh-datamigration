USE [SalesforceMigration]
GO
select *
from [ADVICE_DATAVAULT_PRD].[dv].[vw_exp_xport_asf_csa_case_upsert]
where 1=1
and [AdviserSFID] in (
'0036F00003rFs3fQAC'
,'0036F00003bKWI8QAO'
,'0036F000037TfBpQAK'
,'0036F00003bKWI8QAO'
,'0036F00003vUbZLQA0'
,'0036F000037TfBBQA0'
,'0036F000037Tf2mQAC'
,'0036F000037TfBBQA0'
,'0036F00003rFs3jQAC'
,'0036F000037TfBmQAK'
)
;
-- checking Adviser mapping
select distinct c.[Name], rc.[Name], c.[Id], rc.[Id]
from [SalesforceMigration].[sf].[Contact] c
left join [SalesforceMigration].[sfrhd].[Contact] rc
	on rc.[Metazoa_External_ID__c] = c.[Id]
where 1=1
and c.[ID] in (
'0036F00003rFs3fQAC'
,'0036F00003bKWI8QAO'
,'0036F000037TfBpQAK'
,'0036F00003bKWI8QAO'
,'0036F00003vUbZLQA0'
,'0036F000037TfBBQA0'
,'0036F000037Tf2mQAC'
,'0036F000037TfBBQA0'
,'0036F00003rFs3jQAC'
,'0036F000037TfBmQAK'
)
;
-- ASF
with cte_prod as (
select [IntegrationID], [count] = count(*)
from [ADVICE_DATAVAULT_PRD].[dv].[vw_exp_xport_asf_csa_case_upsert]
where 1=1
group by [IntegrationID]
)
select s.[IntegrationID], sum(s.[Count]), count(*)
from [cte_prod] s
right join [SalesforceMigration].[sfrhd].[ASF_CSA_Case_dv__c] ta
	on ta.[Integration_Id__c]  COLLATE SQL_Latin1_General_CP1_CI_AS
	= s.[IntegrationID]  COLLATE SQL_Latin1_General_CP1_CI_AS
group by s.[IntegrationID]
order by s.[IntegrationID]
/*
IntegrationID	(No column name)	(No column name)
NULL								NULL	14348
144467E4FD8DD62A7C2CE9DEA3BE0005	1	1
15D5432223A20C7E491B00AB64B0EDE9	1	1
24135C51A702C8C0F1592CCB793BB379	1	1
35A8D042DCE5FAF219A231922BE46F48	1	1
360B798EC1B9F903762DDF695AFB95BA	1	1
37C26F443B3A02CB9A13479AD2941B40	1	1
3F0EB92588A65CD46EDA4078A5854F84	1	1
4F687D7464E16F0892B67DD638D589D8	1	1
65C3F8992B0D1A406C59070E62AD04E2	1	1
69D3BA200353FE5E4A4AE3FF840DE504	1	1
796674E700056F3CA5DFACFFD1F3CDCD	1	1
802D2B47988021CB8DACC0A57ADC2022	1	1
866148E8695842752320916A230D2446	1	1
8F420F07B84FDEADE516356C0C494C05	1	1
9139D742500722A5F687D84032D45223	1	1
9D918820F5309928078CD1E7DAFFC189	1	1
A97F1CB8FB925A4C5D8AF4CE01EBCDA7	1	1
F8BDE336BC652BEBE2129ECE087C48B1	1	1
*/
;
-- CSA
with cte_prod as (
select [IntegrationID], [count] = count(*)
from [ADVICE_DATAVAULT_PRD].[dv].[vw_exp_xport_csa_case_upsert]
where 1=1
group by [IntegrationID]
)
select s.[IntegrationID], sum(s.[Count]), count(*)
from [cte_prod] s
right join [SalesforceMigration].[sfrhd].[CSA_Case_dv__c] ta
	on ta.[Integration_Id__c]  COLLATE SQL_Latin1_General_CP1_CI_AS
	= s.[IntegrationID]  COLLATE SQL_Latin1_General_CP1_CI_AS
group by s.[IntegrationID]
order by s.[IntegrationID]
/*
IntegrationID	(No column name)	(No column name)
NULL	NULL	3497
123F18E6E4A0F0FD8EB723B8802BF75C	1	1
1B3DBF3B67338D17AA60A0E661921C5F	1	1
*/
;
