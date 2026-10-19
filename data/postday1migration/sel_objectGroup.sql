Use [ADVICE_ETL_PRD]
go

with [cte_tbl-g1] as (
	select * from (values 
		('A1_Support_Staff_Registrations__c')
		,('Account')
		,('AccountContactRelation')
		,('Assurance_Review__c')
		,('Contact')
		,('CommPay_Supplier__c')
		,('Consequence_Management_Forum_Entry__c')
		,('Contact')
		,('Contact')
		,('Opportunity')
		,('Contact')
		,('PSA__c')
		,('Wealth_Central_Adoption__c')
		,('Wealth_Central_Adoption__c')
	) as t(table_name)
)
,cte_g1 as (
select 
	[object_api_name] = [table_name]
	,[object_category] = 'g1'
	,[sql_stmt] = replace('select [table]=''&tbl&'',[Licensee__c], [count]=count(*) from [sf].[&tbl&] group by [Licensee__c] order by [Licensee__c] ;', '&tbl&',[table_name])
from [cte_tbl-g1]
)
,[cte_tbl-g2] as (
	select distinct * from (values 
		--('AccountContactRelation')
		--('AccountContactRole')
		('CSA_Fee_Switch_Off_History__c')
		--,('Case')
		--,('ContractContactRole')
		--,('MessagingEndUser')
		,('User')
		--,('Asset')
		--,('EntitlementContact')
		--,('CaseContactRole')
		--,('ServiceContract')
		--,('Quote')
		--,('OpportunityContactRole')
		--,('Opportunity')
		--,('Lead')
		--,('MessagingSession')
		--,('Lead')
	) as t(table_name)
)
,cte_g2 as (
select [object_api_name] = [table_name]
	,[object_category] = 'g2'
	,[sql_stmt] = replace('select [table]=''&tbl&'',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[&tbl&] t join [sf].[Contact] c on c.[Id] = t.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;', '&tbl&',[table_name])
from [cte_tbl-g2]
)
,cte_allg as (
select * from [cte_g1]
union all
select * from [cte_g2]
)
,cte_src as (
--select distinct [object_api_name]
--from [ADVICE_ETL_PRD].[ids].[sf_object_meta_ra] m (nolock)
--where 1=1
--and [object_api_name] not like '%bridges%'
SELECT
    [SchemaName] = s.name,
    [object_api_name] = t.name,
    [RowCount] = SUM(ps.row_count)
FROM sys.tables AS t
JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
JOIN sys.dm_db_partition_stats AS ps
    ON ps.object_id = t.object_id
WHERE s.name = 'sf'
  AND ps.index_id IN (0, 1)   -- heap (0) or clustered index (1)
GROUP BY
    s.name,
    t.name
)
select m.[object_api_name]
	, g.[object_category]
	,[sql_stmt] = coalesce(g.[sql_stmt],replace('select [table]=''&tbl&'',* from [sf].[&tbl&] (nolock) order by [Id] ;', '&tbl&',m.[object_api_name]))
from [cte_src] m
left join [cte_allg] g on g.[object_api_name] = m.[object_api_name]
where 1=1
order by m.[object_api_name]
/*
select [table]='A1_Support_Staff_Registrations__c',[Licensee__c], [count]=count(*) from [sf].[A1_Support_Staff_Registrations__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
A1_Support_Staff_Registrations__c	Bridges	4
A1_Support_Staff_Registrations__c	Shadforth	1

select [table]='A1_Support_Staff_Registrations__c',[Licensee__c], [count]=count(*) from [sf].[A1_Support_Staff_Registrations__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
A1_Support_Staff_Registrations__c	Bridges	4
A1_Support_Staff_Registrations__c	Shadforth	1

select [table]='Account',[Licensee__c], [count]=count(*) from [sf].[Account] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Account	NULL	46
Account	Actuate	5
Account	Bridges	127
Account	EWM	1
Account	FSP	3
Account	IOOF Finance Choice	3
Account	Lonsdale	2
Account	MLC Advice	14
Account	Shadforth	14

select [table]='AccountContactRelation',[Licensee__c], [count]=count(*) from [sf].[AccountContactRelation] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
AccountContactRelation	Actuate	158
AccountContactRelation	Bridges	768
AccountContactRelation	EWM	1
AccountContactRelation	FSP	2
AccountContactRelation	IOOF Finance Choice	387
AccountContactRelation	Lonsdale	2
AccountContactRelation	MLC Advice	46
AccountContactRelation	Shadforth	648

select [table]='Accreditations__c',c.[Licensee__c], [count]=count(*) from [sf].[Accreditations__c] t left join [sf].[Contact] c on c.[Id] = t.[Adviser__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Accreditations__c	Actuate	45
Accreditations__c	Bridges	1890
Accreditations__c	Shadforth	1301

select [table]='Adviser_Academy__c',c.[Licensee__c], [count]=count(*) from [sf].[Adviser_Academy__c] t join [sf].[Account] c on c.[Id] = t.[Practice__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Adviser_Academy__c	Bridges	4

select [table]='AdviserHUB_Wave_Definition__c',* from [sf].[AdviserHUB_Wave_Definition__c] (nolock) order by [Id] ;
Reference table

select [table]='AdviserOne_Event__c',[Licensees__c], [count]=count(*) from [sf].[AdviserOne_Event__c] (nolock) group by [Licensees__c] order by [Licensees__c] ;
-- No Metazoa_External_ID__c field
table	Licensees__c	count
AdviserOne_Event__c	Bridges	3
AdviserOne_Event__c	Bridges;Consultum;Lonsdale;RI;Milennium3;GPG;TenFifty	1
AdviserOne_Event__c	Bridges;Consultum;Lonsdale;RI;Shadforth;Milennium3	11
AdviserOne_Event__c	Bridges;Consultum;Lonsdale;RI;Shadforth;Milennium3;GPG;TenFifty	31
AdviserOne_Event__c	Bridges;Consultum;Lonsdale;RI;Shadforth;TenFifty	5
AdviserOne_Event__c	Bridges;Consultum;RI;Shadforth;TenFifty	1
AdviserOne_Event__c	Consultum	4
AdviserOne_Event__c	Consultum;Lonsdale;RI;Milennium3	3
AdviserOne_Event__c	Consultum;Lonsdale;RI;TenFifty	3
AdviserOne_Event__c	Consultum;RI;TenFifty	1
AdviserOne_Event__c	GPG	1
AdviserOne_Event__c	GPG;TenFifty	1
AdviserOne_Event__c	Lonsdale	3
AdviserOne_Event__c	Milennium3	4
AdviserOne_Event__c	RI	4
AdviserOne_Event__c	Shadforth	25
AdviserOne_Event__c	TenFifty	2

select [table]='AdviserOne_Site_Content__c',c.[Licensees__c], [count]=count(*) from [sf].[AdviserOne_Site_Content__c] t join [sf].[AdviserOne_Event__c] c on c.[Detail_Page_Link__c] = t.[Detail_Page_Link__c] group by c.[Licensees__c] order by c.[Licensees__c] ;
??

select [table]='afl__afl_Article_Feedback__c',* from [sf].[afl__afl_Article_Feedback__c] (nolock) order by [Id] ;
Can't determine

select [table]='afl__afl_Knowledge_feedback__c',* from [sf].[afl__afl_Knowledge_feedback__c] (nolock) order by [Id] ;
Not needed

select [table]='Apex_Debug_Log__c',* from [sf].[Apex_Debug_Log__c] (nolock) order by [Id] ;
Not needed

select [table]='ApexPageInfo',* from [sf].[ApexPageInfo] (nolock) order by [Id] ;
Not needed

select [table]='Application_Comment__c',* from [sf].[Application_Comment__c] (nolock) order by [Id] ;
Can't determine

select [table]='AppMenuItem',* from [sf].[AppMenuItem] (nolock) order by [Id] ;
Not needed

select [table]='Approval__c',c.[Licensee__c], [count]=count(*) from [sf].[Approval__c] t join [sf].[User] u on u.[Id] = t.[Approver__c] left join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Approval__c	NULL	484
Approval__c	Shadforth	1

select [table]='Approval__c_hd',c.[Licensee__c], [count]=count(*) from [sf].[Approval__c_hd] a join [sf].[Approval__c] t on a.[ParentId] = t.[Id] join [sf].[User] u on u.[Id] = t.[Approver__c] left join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Approval__c_hd	NULL	488
Approval__c_hd	Shadforth	1

select [table]='Approved_Non_standard_Template__c',c.[Licensee__c], [count]=count(*) from [sf].[Approved_Non_standard_Template__c] t join [sf].[Account] c on c.[Id] = t.[Practice__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Approved_Non_standard_Template__c	NULL	23

select [table]='Area_of_Advice__c',c.[Licensee__c], [count]=count(*) from [sf].[Area_of_Advice__c] t left join [sf].[Contact] c on c.[Id] = t.[Adviser__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Area_of_Advice__c	Actuate	13
Area_of_Advice__c	Bridges	581
Area_of_Advice__c	Shadforth	244

select [table]='articleBody__Article_Body_Setting__mdt',* from [sf].[articleBody__Article_Body_Setting__mdt] (nolock) order by [Id] ;
Not needed

select [table]='Assurance_Review__c',[Licensee__c], [count]=count(*) from [sf].[Assurance_Review__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Assurance_Review__c	/resource/Bridges_Logo	3539
Assurance_Review__c	/resource/Shadforth_Logo	2698
Assurance_Review__c	NOT ASSIGNED	430

select [table]='Attachment',c.[Licensee__c], [count]=count(*) from [sf].[Attachment] a join [sf].[Task] t on t.[Id] = a.[ParentId] join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Attachment	Actuate	127
Attachment	Bridges	1873
Attachment	Shadforth	4162

select [table]='Attachment',c.[Licensee__c], [count]=count(*) from [sf].[Attachment] t join [sf].[Assurance_Review__c] c on c.[Id] = t.[ParentId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Attachment	/resource/Bridges_Logo	5416
Attachment	/resource/Shadforth_Logo	4733
Attachment	NOT ASSIGNED	617

select [table]='Attachment',c.[Licensee__c], [count]=count(*) from [sf].[Attachment] t join [sf].[Incident_File_Review__c] c on c.[Id] = t.[ParentId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Attachment	Actuate	37
Attachment	Bridges	1298
Attachment	Consultum	35
Attachment	Elders	16
Attachment	EWM	3
Attachment	FSP	81
Attachment	GPG	8
Attachment	IOOF Finance Choice	1
Attachment	Lonsdale	27
Attachment	M3	163
Attachment	MLC Advice	167
Attachment	RI	135
Attachment	Shadforth	1259
Attachment	TenFifty	7

select [table]='Australian_Public_Holiday__c',* from [sf].[Australian_Public_Holiday__c] (nolock) order by [Id] ;
Reference table

select [table]='AuthSession',* from [sf].[AuthSession] (nolock) order by [Id] ;
Not needed

select [table]='bar__Backup_Object__c',* from [sf].[bar__Backup_Object__c] (nolock) order by [Id] ;
Can't determine

select [table]='bar__Backup_Policy__c',* from [sf].[bar__Backup_Policy__c] (nolock) order by [Id] ;
Reference table

select [table]='bar__Log__c',* from [sf].[bar__Log__c] (nolock) order by [Id] ;
Not needed

select [table]='BrandingSet',* from [sf].[BrandingSet] (nolock) order by [Id] ;
Reference table

select [table]='BrandingSetProperty',* from [sf].[BrandingSetProperty] (nolock) order by [Id] ;
Reference table

select [table]='BrandTemplate',* from [sf].[BrandTemplate] (nolock) order by [Id] ;
Reference table

select [table]='Breach_Reporting__c',c.[Licensee__c], [count]=count(*) from [sf].[Breach_Reporting__c] t join [sf].[Incident_File_Review__c] c on c.[Id] = t.[Incident_File_Review__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Breach_Reporting__c	Actuate	9
Breach_Reporting__c	Bridges	440
Breach_Reporting__c	MLC Advice	52
Breach_Reporting__c	Shadforth	273

select [table]='BusinessHours',* from [sf].[BusinessHours] (nolock) order by [Id] ;
Not needed

select [table]='BusinessProcess',* from [sf].[BusinessProcess] (nolock) order by [Id] ;
Not needed

select [table]='Campaign',* from [sf].[Campaign] (nolock) order by [Id] ;
Can't determine

select [table]='CampaignInfluenceModel',* from [sf].[CampaignInfluenceModel] (nolock) order by [Id] ;
Not needed

select [table]='CSA_Fee_Switch_Off_History__c',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[CSA_Fee_Switch_Off_History__c] t join [sf].[Contact] c on c.[Id] = t.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
CSA_Fee_Switch_Off_History__c	Bridges	88
CSA_Fee_Switch_Off_History__c	Shadforth	5

select [table]='CSA_Fee_Switch_Off_History__cStatus',* from [sf].[CSA_Fee_Switch_Off_History__cStatus] (nolock) order by [Id] ;
Can't determine

select [table]='Case',[Licensee_Name__c], [count]=count([Id]) from [sf].[Case] (nolock) group by [Licensee_Name__c] order by [Licensee_Name__c] ;
table	Licensee_Name__c	count
Case	NULL	3254
Case	Actuate	214
Case	Bridges	6377
Case	FSP	5
Case	IOOF Finance Choice	102
Case	Lonsdale	1
Case	MLC Advice	235
Case	Shadforth	2354

select [table]='Case_Snapshot__c',c.[Licensee_Name__c], [count]=count(t.[Id]) from [sf].[Case_Snapshot__c] t join [sf].[Case] c on c.[Id] = t.[Case__c] group by c.[Licensee_Name__c] order by c.[Licensee_Name__c] ;
table	Licensee_Name__c	count

select [table]='CaseComment',c.[Licensee_Name__c], [count]=count(t.[Id]) from [sf].[CaseComment] t join [sf].[Case] c on c.[Id] = t.[ParentId] group by c.[Licensee_Name__c] order by c.[Licensee_Name__c] ;
No Metazoa_External_ID__c field
table	Licensee_Name__c	count
CaseComment	NULL	162
CaseComment	Bridges	43
CaseComment	IOOF Finance Choice	1
CaseComment	MLC Advice	1
CaseComment	Shadforth	34

select [table]='CaseStatus',* from [sf].[CaseStatus] (nolock) order by [Id] ;
Reference table

select [table]='Client_File__c',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Client_File__c] t join [sf].[Assurance_Review__c] c on c.[Id] = t.[Review__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Client_File__c	/resource/Bridges_Logo	4387
Client_File__c	/resource/Shadforth_Logo	4010
Client_File__c	NOT ASSIGNED	519

select [table]='Client_Service_Model_Implementation__c',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Client_Service_Model_Implementation__c] t join [sf].[Account] c on c.[Id] = t.[Practice__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Client_Service_Model_Implementation__c	Actuate	2
Client_Service_Model_Implementation__c	Bridges	308
Client_Service_Model_Implementation__c	IOOF Finance Choice	1
Client_Service_Model_Implementation__c	Shadforth	13

select [table]='ClientBrowser',* from [sf].[ClientBrowser] (nolock) order by [Id] ;
Reference table

select [table]='cloudx_cms__SS_Carousel__c',* from [sf].[cloudx_cms__SS_Carousel__c] (nolock) order by [Id] ;
Not needed

select [table]='CommPay_Supplier__c',[Licensee__c], [count]=count(*) from [sf].[CommPay_Supplier__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
CommPay_Supplier__c	NULL	25
CommPay_Supplier__c	Bridges	11
CommPay_Supplier__c	Shadforth	11

select [table]='Community',* from [sf].[Community] (nolock) order by [Id] ;
Not needed

select [table]='Complained_Advisers__c',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Complained_Advisers__c] t left join [sf].[Contact] c on c.[Id] = t.[Adviser__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Complained_Advisers__c	Actuate	175
Complained_Advisers__c	Bridges	5837
Complained_Advisers__c	FSP	4
Complained_Advisers__c	IOOF Finance Choice	97
Complained_Advisers__c	Lonsdale	1
Complained_Advisers__c	MLC Advice	112
Complained_Advisers__c	Shadforth	1970

select [table]='Consequence_Management_Forum_Entry__c',[Licensee__c], [count]=count(*) from [sf].[Consequence_Management_Forum_Entry__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Consequence_Management_Forum_Entry__c	NULL	748
Consequence_Management_Forum_Entry__c	Actuate	3
Consequence_Management_Forum_Entry__c	Bridges	74
Consequence_Management_Forum_Entry__c	FSP	7
Consequence_Management_Forum_Entry__c	IOOF Finance Choice	1
Consequence_Management_Forum_Entry__c	Shadforth	27

select [table]='Contact',[Licensee__c], [count]=count(*) from [sf].[Contact] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Contact	NULL	1
Contact	Actuate	119
Contact	Bridges	679
Contact	EWM	1
Contact	FSP	2
Contact	IOOF Finance Choice	387
Contact	Lonsdale	2
Contact	MLC Advice	45
Contact	Shadforth	634

select [table]='ContentDistribution',* from [sf].[ContentDistribution] (nolock) order by [Id] ;
ContentDistribution -> ContentVersion

select [table]='ContentDistributionView',* from [sf].[ContentDistributionView] (nolock) order by [Id] ;
ContentDistributionView -> ContentDistribution

select [table]='ContentDocument',[prefix]=left([ParentId],3),[count]=count(*) from [sf].[ContentDocument] (nolock) group by left([ParentId],3) order by left([ParentId],3) ;

select [table]='ContentFolder',* from [sf].[ContentFolder] (nolock) order by [Id] ;

select [table]='ContentFolderLink',* from [sf].[ContentFolderLink] (nolock) order by [Id] ;

select [table]='ContentVersion',* from [sf].[ContentVersion] (nolock) order by [Id] ;
select [table]='ContentWorkspace',* from [sf].[ContentWorkspace] (nolock) order by [Id] ;
select [table]='ContentWorkspaceDoc',* from [sf].[ContentWorkspaceDoc] (nolock) order by [Id] ;
select [table]='ContentWorkspaceMember',* from [sf].[ContentWorkspaceMember] (nolock) order by [Id] ;
select [table]='ContentWorkspacePermission',* from [sf].[ContentWorkspacePermission] (nolock) order by [Id] ;
select [table]='ContractStatus',* from [sf].[ContractStatus] (nolock) order by [Id] ;
Reference table

select [table]='CSA_Fee_Switch_Off_History__c',* from [sfrhd].[CSA_Fee_Switch_Off_History__c] (nolock) order by [Licensee__c] ;
select [table]='CSA_Fee_Switch_Off_History__c',[Licensee__c], [count]=count(*) from [sf].[CSA_Fee_Switch_Off_History__c] (nolock) group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
CSA_Fee_Switch_Off_History__c	Bridges	3131
CSA_Fee_Switch_Off_History__c	Shadforth	2170

select [table]='CSO__c',* from [sf].[CSO__c] (nolock) where [Email__c] like '%sfg%' order by [Id] ;
Not needed

select [table]='CSOAdviser__c',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[CSOAdviser__c] t left join [sf].[Contact] c on c.[Id] = t.[Adviser__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
CSOAdviser__c	Bridges	1246

select [table]='CustomBrand',* from [sf].[CustomBrand] (nolock) order by [Id] ;
Can't determine

select [table]='CustomBrandAsset',* from [sf].[CustomBrandAsset] (nolock) order by [Id] ;
CustomBrandAsset -> CustomBrand
Can't determine

select [table]='Dashboard',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Dashboard] t join [sf].[User] u on u.[Id] = t.[RunningUserId] left join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
Dashboard	NULL	18

select [table]='DashboardComponent',* from [sf].[DashboardComponent] (nolock) order by [Id] ;
DashboardComponent -> Dashboard

select [table]='Document',* from [sf].[Document] (nolock) order by [Id] ;
Not needed

select [table]='DuplicateRecordItem',* from [sf].[DuplicateRecordItem] (nolock) order by [Id] ;
Not needed

select [table]='DuplicateRecordSet',* from [sf].[DuplicateRecordSet] (nolock) order by [Id] ;
Not needed

select [table]='Email_Log__c',* from [sf].[Email_Log__c] (nolock) order by [Id] ;
Can't determine

select [table]='EmailTemplate',* from [sf].[EmailTemplate] (nolock) order by [Id] ;
Can't determine

select [table]='EntityDefinition',* from [sf].[EntityDefinition] (nolock) order by [Id] ;
Reference table

select [table]='Event',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Event] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Event	Bridges	29
Event	Shadforth	1

select [table]='EventRelation',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[EventRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
No Metazoa_External_ID__c field
table	Licensee__c	count
EventRelation	Bridges	45
EventRelation	Shadforth	1

select [table]='EventWhoRelation',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[EventWhoRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
No Metazoa_External_ID__c field
table	Licensee__c	count
EventWhoRelation	Bridges	22
EventWhoRelation	Shadforth	1

select [table]='FiscalYearSettings',* from [sf].[FiscalYearSettings] (nolock) order by [Id] ;
Reference table

select [table]='Folder',* from [sf].[Folder] (nolock) order by [Id] ;
Reference table

select [table]='Group',* from [sf].[Group] (nolock) order by [Id] ;
Not needed

select [table]='GroupMember',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[GroupMember] t join [sf].[User] u on u.[Id] = t.[UserOrGroupId] left join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
GroupMember	NULL	4557
GroupMember	Bridges	346
GroupMember	Shadforth	407

select [table]='hmq__Headlines__c',* from [sf].[hmq__Headlines__c] (nolock) order by [Id] ;
Can't determine

select [table]='Holiday',* from [sf].[Holiday] (nolock) order by [Id] ;
Reference table

select [table]='Incident_File_Review__c',[Licensee__c] from [sf].[Incident_File_Review__c] (nolock) group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c
Incident_File_Review__c	Actuate
Incident_File_Review__c	AET
Incident_File_Review__c	Bridges
Incident_File_Review__c	Consultum
Incident_File_Review__c	Elders
Incident_File_Review__c	EWM
Incident_File_Review__c	FSP
Incident_File_Review__c	GPG
Incident_File_Review__c	IIML
Incident_File_Review__c	IOOF Finance Choice
Incident_File_Review__c	IOOF Insurance Brokers
Incident_File_Review__c	Lonsdale
Incident_File_Review__c	M3
Incident_File_Review__c	MLC Advice
Incident_File_Review__c	RI
Incident_File_Review__c	Shadforth
Incident_File_Review__c	TenFifty

select [table]='InitiativeChecklist__c',* from [sf].[InitiativeChecklist__c] (nolock) order by [Id] ;

select [table]='Item__c',* from [sf].[Item__c] (nolock) order by [Id] ;
Not needed

select [table]='Knowledge__ka',* from [sf].[Knowledge__ka] (nolock) order by [Id] ;
Can't determine

select [table]='Knowledge__kav',* from [sf].[Knowledge__kav] (nolock) order by [Id] ;
select [table]='Knowledge__ViewStat',* from [sf].[Knowledge__ViewStat] (nolock) order by [Id] ;
select [table]='Knowledge__VoteStat',* from [sf].[Knowledge__VoteStat] (nolock) order by [Id] ;
select [table]='KnowledgeArticle',* from [sf].[KnowledgeArticle] (nolock) order by [Id] ;
select [table]='KnowledgeArticleVersion',* from [sf].[KnowledgeArticleVersion] (nolock) order by [Id] ;
select [table]='KnowledgeArticleViewStat',* from [sf].[KnowledgeArticleViewStat] (nolock) order by [Id] ;
select [table]='KnowledgeArticleVoteStat',* from [sf].[KnowledgeArticleVoteStat] (nolock) order by [Id] ;
Can't determine

select [table]='Lead',* from [sf].[Lead] (nolock) order by [Id] ;
Not needed

select [table]='LeadStatus',* from [sf].[LeadStatus] (nolock) order by [Id] ;
Reference table

select [table]='Library_Text__c',* from [sf].[Library_Text__c] (nolock) order by [Id] ;
Reference table

select [table]='ListView',* from [sf].[ListView] (nolock) order by [Id] ;
Can't determine

select [table]='ListViewChart',* from [sf].[ListViewChart] (nolock) order by [Id] ;
Can't determine

select [table]='LoginIp',* from [sf].[LoginIp] (nolock) order by [Id] ;
Can't determine

select [table]='LookupName__c',* from [sf].[LookupName__c] (nolock) order by [Id] ;
Reference table

select [table]='Master_Item__c',* from [sf].[Master_Item__c] (nolock) order by [Id] ;
Reference table

select [table]='Master_module__c',* from [sf].[Master_module__c] (nolock) order by [Id] ;
Reference table

select [table]='Master_Questions__c',* from [sf].[Master_Questions__c] (nolock) order by [Id] ;
Master_Questions__c -> Question_Group__c
Reference table

select [table]='Master_Topic__c',* from [sf].[Master_Topic__c] (nolock) order by [Id] ;
Reference table

select [table]='Master_workshop__c',* from [sf].[Master_workshop__c] (nolock) order by [Id] ;
Reference table

select [table]='MasterQuestions_Targetedreviews__c',* from [sf].[MasterQuestions_Targetedreviews__c] (nolock) order by [Id] ;
Can't determine

select [table]='Module__c',* from [sf].[Module__c] (nolock) order by [Id] ;
For Bridges only

select [table]='NAPW__c',c.[Licensee__c], [count]=count(*) from [sf].[NAPW__c] t left join [sf].[Contact] c on c.[Id] = t.[AdviserSFID__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
NAPW__c	Bridges	94
NAPW__c	Shadforth	125

select [table]='OauthToken',* from [sf].[OauthToken] (nolock) order by [Id] ;
Not needed

select [table]='Opportunity',[Licensee__c], [count]=count(*) from [sf].[Opportunity] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Opportunity	Actuate	30
Opportunity	Bridges	403
Opportunity	IOOF Finance Choice	25
Opportunity	MLC Advice	23
Opportunity	Shadforth	141

select [table]='OpportunityStage',* from [sf].[OpportunityStage] (nolock) order by [Id] ;
Reference table

select [table]='Paraplanning__c',[Licensee__c], [count]=count(*) from [sf].[Paraplanning__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Paraplanning__c	Actuate	130
Paraplanning__c	Bridges	13661
Paraplanning__c	Shadforth	19453

select [table]='PartnerRole',* from [sf].[PartnerRole] (nolock) order by [Id] ;
Reference table

select [table]='Period',* from [sf].[Period] (nolock) order by [Id] ;
Reference table

select [table]='Pricebook2',* from [sf].[Pricebook2] (nolock) order by [Id] ;
Reference table

select [table]='ProcessDefinition',* from [sf].[ProcessDefinition] (nolock) order by [Id] ;
Reference table

select [table]='ProcessInstance',* from [sf].[ProcessInstance] (nolock) order by [Id] ;
Can't determine

select [table]='ProcessInstanceNode',* from [sf].[ProcessInstanceNode] (nolock) order by [Id] ;
Can't determine

select [table]='ProcessInstanceStep',* from [sf].[ProcessInstanceStep] (nolock) order by [Id] ;
Can't determine

select [table]='ProcessInstanceWorkitem',* from [sf].[ProcessInstanceWorkitem] (nolock) order by [Id] ;
Can't determine

select [table]='ProcessNode',* from [sf].[ProcessNode] (nolock) order by [Id] ;
Reference table

select [table]='Product_Questions__c',* from [sf].[Product_Questions__c] (nolock) order by [Id] ;
Product_Questions__c -> Master_Questions__c
Reference table

select [table]='Product2',* from [sf].[Product2] (nolock) order by [Id] ;
Reference table

select [table]='Profile',* from [sf].[Profile] (nolock) order by [Id] ;
Reference table

select [table]='PSA__c',[Licensee__c], [count]=count(*) from [sf].[PSA__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
PSA__c	NULL	57

select [table]='Publisher',* from [sf].[Publisher] (nolock) order by [Id] ;
Reference table

select [table]='QA__c',* from [sf].[QA__c] (nolock) order by [Id] ;
Reference table

select [table]='QA_Assignment_Hisotry__c',* from [sf].[QA_Assignment_Hisotry__c] t left join [sf].[Assurance_Review__c] c on c.[Id] = t.[Name] group by c.[Licensee__c] order by c.[Licensee__c] ;
Missing Assurance_Review__c field

select [table]='QDC_Training__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[QDC_Training__c] t join [sf].[User] u on u.[Id] = t.[Paraplanner_User__c] left join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
QDC_Training__c	NULL	396

select [table]='Qualification__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[Qualification__c] t left join [sf].[Contact] c on c.[Id] = t.[Adviser__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Qualification__c	Actuate	197
Qualification__c	Bridges	2135
Qualification__c	IOOF Finance Choice	20
Qualification__c	Shadforth	1173

select [table]='Qualification_Type__c',t.* from [sf].[Qualification_Type__c] t order by [Name] ;
select [table]='Qualification_Type__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[Qualification_Type__c] t left join [sf].[PSA__c] c on c.[Id] = t.[EDP_External_Id__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
Qualification_Type__c	NULL	95

select [table]='Question_Group__c',* from [sf].[Question_Group__c] (nolock) order by [Id] ;
Reference table

select [table]='Question_Responses__c',[Licensee__c] , [count]=count([Id]) from [sf].[Question_Responses__c] (nolock) group by [Licensee__c] order by [Licensee__c] ;
Question_Responses__c	Shadforth	1465

select [table]='QueueSobject',* from [sf].[QueueSobject] (nolock) order by [Id] ;
Reference table

select [table]='QuickText',* from [sf].[QuickText] (nolock) order by [Id] ;
Not needed

select [table]='RecentlyViewed',* from [sf].[RecentlyViewed] (nolock) order by [Id] ;
Can't determine

select [table]='RecordType',* from [sf].[RecordType] (nolock) order by [Id] ;
Reference table

select [table]='Registered_Training_Organisation__c',t.* from [sf].[Registered_Training_Organisation__c] t order by [Name] ;
select [table]='Registered_Training_Organisation__c',* from [sf].[Registered_Training_Organisation__c] (nolock) order by [Id] ;
Can't determine

select [table]='Report',* from [sf].[Report] (nolock) order by [Id] ;
Can't determine

select [table]='Response_Finding__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[Response_Finding__c] t left join [sf].[Question_Responses__c] c on c.[Id] = t.[Incident__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Response_Finding__c	NULL	10352
Response_Finding__c	Shadforth	4

select [table]='Reviewer_Accreditation__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[Reviewer_Accreditation__c] t join [sf].[User] u on u.[Id] = t.[Assurance_Reviewer__c] left join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
Can't determine

select [table]='SearchActivity',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[SearchActivity] t join [sf].[Knowledge__kav] k on k.[Id] = t.[ClickedRecordId] left join [sf].[User] u on u.[Id] = k.[AssignedToId] left join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
SearchActivity	NULL	1

select [table]='SecondaryPracticeAdviserHistory__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[SecondaryPracticeAdviserHistory__c] t join [sf].[Account] c on c.[Id] = t.[Practice__c] group by c.[Licensee__c] order by c.[Licensee__c] ;table	Licensee__c	count
SecondaryPracticeAdviserHistory__c	Actuate	2
SecondaryPracticeAdviserHistory__c	Bridges	246
SecondaryPracticeAdviserHistory__c	MLC Advice	86
SecondaryPracticeAdviserHistory__c	Shadforth	12

select [table]='SelectedQuestions_Targetedreviews__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[SelectedQuestions_Targetedreviews__c] t left join [sf].[Assurance_Review__c] c on c.[Id] = t.[Assurance_Review__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
SelectedQuestions_Targetedreviews__c	/resource/Bridges_Logo	122
SelectedQuestions_Targetedreviews__c	/resource/Shadforth_Logo	44
SelectedQuestions_Targetedreviews__c	NOT ASSIGNED	1323

select [table]='Snapshot_Data__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[Snapshot_Data__c] t left join [sf].[Question_Responses__c] c on c.[Id] = t.[Incident__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
Snapshot_Data__c -> Question_Responses__c
table	Licensee__c	count
Snapshot_Data__c	NULL	215652
Snapshot_Data__c	Shadforth	3788

select [table]='SolutionStatus',* from [sf].[SolutionStatus] (nolock) order by [Id] ;
Reference table

select [table]='sortablegrid__SDG__c',* from [sf].[sortablegrid__SDG__c] (nolock) order by [Id] ;
select [table]='sortablegrid__SDG_Action__c',* from [sf].[sortablegrid__SDG_Action__c] (nolock) order by [Id] ;
select [table]='sortablegrid__SDG_Field__c',* from [sf].[sortablegrid__SDG_Field__c] (nolock) order by [Id] ;
select [table]='sortablegrid__sdg_Preferences__c',* from [sf].[sortablegrid__sdg_Preferences__c] (nolock) order by [Id] ;

select [table]='Special_Conditions__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[Special_Conditions__c] t left join [sf].[Contact] c on c.[Id] = t.[Adviser__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Special_Conditions__c	Actuate	1
Special_Conditions__c	Bridges	42

select [table]='StaticResource',* from [sf].[StaticResource] (nolock) order by [Id] ;
binary content to download, similar to Attachment

select [table]='Target__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[Target__c] t join [sf].[User] u on u.[Id] = t.[User__c] left join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Target__c	NULL	2943
Target__c	Bridges	2
Target__c	IOOF Finance Choice	11

select [table]='Task',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[Task] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Task	Actuate	1279
Task	Bridges	15755
Task	IOOF Finance Choice	393
Task	MLC Advice	165
Task	Shadforth	18258

select [table]='TaskPriority',* from [sf].[TaskPriority] (nolock) order by [Id] ;
Reference table

select [table]='TaskRelation',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[TaskRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
TaskRelation -> Account
TaskRelation -> Lead
TaskRelation -> Task
table	Licensee__c	count
TaskRelation	Actuate	1307
TaskRelation	Bridges	17935
TaskRelation	IOOF Finance Choice	402
TaskRelation	MLC Advice	182
TaskRelation	Shadforth	19273

select [table]='TaskStatus',* from [sf].[TaskStatus] (nolock) order by [Id] ;
Reference table

select [table]='TaskWhoRelation',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[TaskWhoRelation] t left join [sf].[Contact] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
TaskWhoRelation	NULL	37393

select [table]='Third_Party_Provider__c',* from [sf].[Third_Party_Provider__c] (nolock) order by [Id] ;
Reference Table

select [table]='Topic',* from [sf].[Topic] (nolock) order by [Id] ;
Not needed

select [table]='Topic__c',* from [sf].[Topic__c] (nolock) order by [Id] ;
Reference Table

select [table]='Tracking__c',* from [sf].[Tracking__c] (nolock) order by [Id] ;
Tracking__c -> Target__c
Not needed.

select [table]='UndecidedEventRelation',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[UndecidedEventRelation] t join [sf].[User] u on u.[Id] = t.[RelationId] left join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
UndecidedEventRelation	NULL	6
select [table]='UndecidedEventRelation',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[UndecidedEventRelation] t join [sf].[Contact] c on c.[Id] = t.[RelationId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
UndecidedEventRelation	Bridges	22

select [table]='User',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[User] t join [sf].[Contact] c on c.[Id] = t.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
User	Actuate	15
User	Bridges	345
User	IOOF Finance Choice	356
User	Shadforth	406

select [table]='UserAppInfo',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[UserAppInfo]  t join [sf].[User] u on u.[Id] = t.[UserId] left join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
UserAppInfo	NULL	878

select [table]='UserLogin',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[UserLogin] t join [sf].[User] u on u.[Id] = t.[UserId] join [sf].[Contact] c on c.[Id] = u.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
UserLogin	Actuate	15
UserLogin	Bridges	345
UserLogin	IOOF Finance Choice	356
UserLogin	Shadforth	406

select [table]='UserPermissionAccess',* from [sf].[UserPermissionAccess] (nolock) order by [Id] ;
Not needed

select [table]='UserRole',* from [sf].[UserRole] (nolock) order by [Id] ;
Reference Table

select [table]='Vetting_Result__c',c.[Licensee__c] , [count]=count(t.[Id]) from [sf].[Vetting_Result__c]  t join [sf].[Contact] c on c.[Id] = t.[Adviser_Id__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Vetting_Result__c	Actuate	32
Vetting_Result__c	Bridges	1292
Vetting_Result__c	Shadforth	136

select [table]='Wealth_Advice_Referral_Program__c',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Wealth_Advice_Referral_Program__c] t join [sf].[Contact] c on c.[Id] = t.[Adviser__c] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count

select [table]='Wealth_Central_Adoption__c',[Licensee__c], [count]=count(*) from [sf].[Wealth_Central_Adoption__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Wealth_Central_Adoption__c	NULL	1
Wealth_Central_Adoption__c	Actuate	22
Wealth_Central_Adoption__c	Bridges	330
Wealth_Central_Adoption__c	IOOF Finance Choice	14
Wealth_Central_Adoption__c	MLC Advice	1
Wealth_Central_Adoption__c	Shadforth	419

select [table]='WorkAccess',* from [sf].[WorkAccess] (nolock) order by [Id] ;
ParentId -> WorkBadgeDefinition
Not needed.

select [table]='WorkBadgeDefinition',* from [sf].[WorkBadgeDefinition] (nolock) order by [Id] ;
All graphics. Not needed.

select [table]='Workshop__c',a.[Licensee__c],s.* 
from [sf].[Workshop__c] s (nolock)
left join [sf].[Adviser_Academy__c] aa (nolock)
	on aa.[Id] = s.[Adviser_Academy__c]
left join [sf].[Account] a (nolock)
	on a.[Id] = aa.[Practice__c]
--	and a.[Licensee__c] = 'Shadforth'
order by s.[Name]
-- Bridges
*/
