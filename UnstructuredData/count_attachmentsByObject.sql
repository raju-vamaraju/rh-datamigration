select [table] = [name]
	--, [sql_stmt] = replace('select [table]=''&tbl&'', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[&tbl&] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = ''Shadforth''', '&tbl&', [name])
	, [sql_stmt] = replace('select [table]=''&tbl&'', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[&tbl&] s (nolock) on s.[Id] = a.[ParentId]', '&tbl&', [name])
from sys.tables
where 1=1
and SCHEMA_NAME([schema_id]) = 'sf'
and [name] not in ('Account', 'Assurance_Review__c', 'Case', 'EmailTemplate', 'EmailTemplate', 'PSA__c', 'RecentlyViewed', 'Task')
order by [name]
/*
Prefix	Total Doc Count		Shadforth Doc Count
001		36					0					-- Account
00T		6162				4142				-- Task
00X		3					3?					-- EmailTemplate
500		9					0					-- Case
a09		10766				4733				-- Assurance_Review__c
a0F		3237				1259				-- EmailTemplate
a0H		26					0					-- PSA__c
a0N		71400				0					-- Question_Responses__c

select [table]='Account', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Account] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = 'Shadforth'
table	AttachmentCount
Account	0

select [table]='Task', [AttachmentCount] = count(*) 
from [sf].[Attachment] a (nolock) 
join [sf].[Task] s (nolock) on s.[Id] = a.[ParentId]
join [sf].[Account] t (nolock) on t.[Id] = s.[AccountId] and t.[Licensee__c] = 'Shadforth'
table	AttachmentCount
Task	4162

select [table]='Case', [AttachmentCount] = count(*) 
from [sf].[Attachment] a (nolock) 
join [sf].[Case] s (nolock) on s.[Id] = a.[ParentId]
join [sf].[Account] t (nolock) on t.[Id] = s.[AccountId] and t.[Licensee__c] = 'Shadforth'
table	AttachmentCount
Case	0

select [table]='Assurance_Review__c', [AttachmentCount] = count(*) 
from [sf].[Attachment] a (nolock) 
join [sf].[Assurance_Review__c] s (nolock) on s.[Id] = a.[ParentId]
join [sf].[Contact] t (nolock) on t.[Id] = s.[Adviser__c] and t.[Licensee__c] = 'Shadforth'
table	AttachmentCount
Assurance_Review__c	4733

select [table]='EmailTemplate', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[EmailTemplate] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = 'Shadforth'
table	AttachmentCount
EmailTemplate	1259

select [table]='PSA__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[PSA__c] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = 'Shadforth'
table	AttachmentCount
PSA__c	0

select [table]='Question_Responses__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Question_Responses__c] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = 'Shadforth'
table	AttachmentCount
Question_Responses__c	0

*/
/*
select [table]='A1_Support_Staff_Registrations__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[A1_Support_Staff_Registrations__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Account', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Account] s (nolock) on s.[Id] = a.[ParentId]
table	AttachmentCount
Account	36

select [table]='AccountContactRelation', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[AccountContactRelation] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Accreditations__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Accreditations__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Adviser_Academy__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Adviser_Academy__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='AdviserHUB_Wave_Definition__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[AdviserHUB_Wave_Definition__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='AdviserOne_Event__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[AdviserOne_Event__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='AdviserOne_Site_Content__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[AdviserOne_Site_Content__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='afl__afl_Article_Feedback__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[afl__afl_Article_Feedback__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='afl__afl_Knowledge_feedback__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[afl__afl_Knowledge_feedback__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Apex_Debug_Log__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Apex_Debug_Log__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ApexPageInfo', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ApexPageInfo] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Application_Comment__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Application_Comment__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='AppMenuItem', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[AppMenuItem] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Approval__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Approval__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Approval__c_hd', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Approval__c_hd] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Approved_Non_standard_Template__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Approved_Non_standard_Template__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Area_of_Advice__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Area_of_Advice__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='articleBody__Article_Body_Setting__mdt', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[articleBody__Article_Body_Setting__mdt] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Assurance_Review__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Assurance_Review__c] s (nolock) on s.[Id] = a.[ParentId]
table	AttachmentCount
Assurance_Review__c	10766

select [table]='Attachment', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Attachment] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Australian_Public_Holiday__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Australian_Public_Holiday__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='AuthSession', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[AuthSession] s (nolock) on s.[Id] = a.[ParentId]
select [table]='bar__Backup_Object__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[bar__Backup_Object__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='bar__Backup_Policy__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[bar__Backup_Policy__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='bar__Log__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[bar__Log__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='BrandingSet', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[BrandingSet] s (nolock) on s.[Id] = a.[ParentId]
select [table]='BrandingSetProperty', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[BrandingSetProperty] s (nolock) on s.[Id] = a.[ParentId]
select [table]='BrandTemplate', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[BrandTemplate] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Breach_Reporting__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Breach_Reporting__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='BusinessHours', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[BusinessHours] s (nolock) on s.[Id] = a.[ParentId]
select [table]='BusinessProcess', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[BusinessProcess] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Campaign', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Campaign] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CampaignInfluenceModel', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CampaignInfluenceModel] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CampaignMember', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CampaignMember] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CampaignMemberStatus', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CampaignMemberStatus] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Case', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Case] s (nolock) on s.[Id] = a.[ParentId]
table	AttachmentCount
Case	9

select [table]='Case_Snapshot__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Case_Snapshot__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CaseComment', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CaseComment] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CaseStatus', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CaseStatus] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Client_File__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Client_File__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Client_Service_Model_Implementation__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Client_Service_Model_Implementation__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ClientBrowser', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ClientBrowser] s (nolock) on s.[Id] = a.[ParentId]
select [table]='cloudx_cms__SS_Carousel__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[cloudx_cms__SS_Carousel__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CommPay_Supplier__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CommPay_Supplier__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Community', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Community] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Complained_Advisers__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Complained_Advisers__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Consequence_Management_Forum_Entry__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Consequence_Management_Forum_Entry__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Contact', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Contact] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContentDistribution', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContentDistribution] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContentDistributionView', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContentDistributionView] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContentDocument', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContentDocument] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContentFolder', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContentFolder] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContentFolderLink', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContentFolderLink] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContentVersion', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContentVersion] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContentWorkspace', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContentWorkspace] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContentWorkspaceDoc', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContentWorkspaceDoc] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContentWorkspaceMember', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContentWorkspaceMember] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContentWorkspacePermission', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContentWorkspacePermission] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ContractStatus', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ContractStatus] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CSA_Fee_Switch_Off_History__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CSA_Fee_Switch_Off_History__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CSO__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CSO__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CSOAdviser__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CSOAdviser__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CustomBrand', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CustomBrand] s (nolock) on s.[Id] = a.[ParentId]
select [table]='CustomBrandAsset', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[CustomBrandAsset] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Dashboard', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Dashboard] s (nolock) on s.[Id] = a.[ParentId]
select [table]='DashboardComponent', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[DashboardComponent] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Document', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Document] s (nolock) on s.[Id] = a.[ParentId]
select [table]='DuplicateRecordItem', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[DuplicateRecordItem] s (nolock) on s.[Id] = a.[ParentId]
select [table]='DuplicateRecordSet', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[DuplicateRecordSet] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Email_Log__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Email_Log__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='EmailTemplate', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[EmailTemplate] s (nolock) on s.[Id] = a.[ParentId]
table	AttachmentCount
EmailTemplate	3

select [table]='EntityDefinition', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[EntityDefinition] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Event', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Event] s (nolock) on s.[Id] = a.[ParentId]
select [table]='EventRelation', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[EventRelation] s (nolock) on s.[Id] = a.[ParentId]
select [table]='EventWhoRelation', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[EventWhoRelation] s (nolock) on s.[Id] = a.[ParentId]
select [table]='FiscalYearSettings', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[FiscalYearSettings] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Folder', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Folder] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Group', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Group] s (nolock) on s.[Id] = a.[ParentId]
select [table]='GroupMember', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[GroupMember] s (nolock) on s.[Id] = a.[ParentId]
select [table]='hmq__Headlines__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[hmq__Headlines__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Holiday', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Holiday] s (nolock) on s.[Id] = a.[ParentId]
select [table]='EmailTemplate', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[EmailTemplate] s (nolock) on s.[Id] = a.[ParentId]
table	AttachmentCount
EmailTemplate	3237

select [table]='InitiativeChecklist__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[InitiativeChecklist__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Item__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Item__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Knowledge__ka', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Knowledge__ka] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Knowledge__kav', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Knowledge__kav] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Knowledge__ViewStat', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Knowledge__ViewStat] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Knowledge__VoteStat', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Knowledge__VoteStat] s (nolock) on s.[Id] = a.[ParentId]
select [table]='KnowledgeArticle', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[KnowledgeArticle] s (nolock) on s.[Id] = a.[ParentId]
select [table]='KnowledgeArticleVersion', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[KnowledgeArticleVersion] s (nolock) on s.[Id] = a.[ParentId]
select [table]='KnowledgeArticleViewStat', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[KnowledgeArticleViewStat] s (nolock) on s.[Id] = a.[ParentId]
select [table]='KnowledgeArticleVoteStat', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[KnowledgeArticleVoteStat] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Lead', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Lead] s (nolock) on s.[Id] = a.[ParentId]
select [table]='LeadStatus', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[LeadStatus] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Library_Text__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Library_Text__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ListView', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ListView] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ListViewChart', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ListViewChart] s (nolock) on s.[Id] = a.[ParentId]
select [table]='LoginIp', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[LoginIp] s (nolock) on s.[Id] = a.[ParentId]
select [table]='LookupName__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[LookupName__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Master_Item__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Master_Item__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Master_module__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Master_module__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Master_Questions__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Master_Questions__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Master_Topic__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Master_Topic__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Master_workshop__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Master_workshop__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='MasterQuestions_Targetedreviews__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[MasterQuestions_Targetedreviews__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Module__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Module__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='NAPW__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[NAPW__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='OauthToken', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[OauthToken] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Opportunity', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Opportunity] s (nolock) on s.[Id] = a.[ParentId]
select [table]='OpportunityStage', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[OpportunityStage] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Paraplanning__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Paraplanning__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='PartnerRole', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[PartnerRole] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Period', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Period] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Pricebook2', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Pricebook2] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ProcessDefinition', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ProcessDefinition] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ProcessInstance', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ProcessInstance] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ProcessInstanceNode', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ProcessInstanceNode] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ProcessInstanceStep', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ProcessInstanceStep] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ProcessInstanceWorkitem', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ProcessInstanceWorkitem] s (nolock) on s.[Id] = a.[ParentId]
select [table]='ProcessNode', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[ProcessNode] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Product_Questions__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Product_Questions__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Product2', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Product2] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Profile', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Profile] s (nolock) on s.[Id] = a.[ParentId]
select [table]='PSA__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[PSA__c] s (nolock) on s.[Id] = a.[ParentId]
table	AttachmentCount
PSA__c	26

select [table]='Publisher', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Publisher] s (nolock) on s.[Id] = a.[ParentId]
select [table]='QA__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[QA__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='QA_Assignment_Hisotry__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[QA_Assignment_Hisotry__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='QDC_Training__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[QDC_Training__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Qualification__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Qualification__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Qualification_Type__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Qualification_Type__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Question_Group__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Question_Group__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Question_Responses__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Question_Responses__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='QueueSobject', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[QueueSobject] s (nolock) on s.[Id] = a.[ParentId]
select [table]='QuickText', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[QuickText] s (nolock) on s.[Id] = a.[ParentId]
select [table]='RecentlyViewed', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[RecentlyViewed] s (nolock) on s.[Id] = a.[ParentId]
table	AttachmentCount
RecentlyViewed	1

select [table]='RecordType', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[RecordType] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Registered_Training_Organisation__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Registered_Training_Organisation__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Report', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Report] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Response_Finding__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Response_Finding__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Reviewer_Accreditation__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Reviewer_Accreditation__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='SearchActivity', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[SearchActivity] s (nolock) on s.[Id] = a.[ParentId]
select [table]='SecondaryPracticeAdviserHistory__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[SecondaryPracticeAdviserHistory__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='SelectedQuestions_Targetedreviews__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[SelectedQuestions_Targetedreviews__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Snapshot_Data__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Snapshot_Data__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='SolutionStatus', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[SolutionStatus] s (nolock) on s.[Id] = a.[ParentId]
select [table]='sortablegrid__SDG__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[sortablegrid__SDG__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='sortablegrid__SDG_Action__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[sortablegrid__SDG_Action__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='sortablegrid__SDG_Field__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[sortablegrid__SDG_Field__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='sortablegrid__sdg_Preferences__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[sortablegrid__sdg_Preferences__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Special_Conditions__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Special_Conditions__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='StaticResource', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[StaticResource] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Target__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Target__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Task', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Task] s (nolock) on s.[Id] = a.[ParentId]
table	AttachmentCount
Task	6162

select [table]='TaskPriority', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[TaskPriority] s (nolock) on s.[Id] = a.[ParentId]
select [table]='TaskRelation', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[TaskRelation] s (nolock) on s.[Id] = a.[ParentId]
select [table]='TaskStatus', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[TaskStatus] s (nolock) on s.[Id] = a.[ParentId]
select [table]='TaskWhoRelation', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[TaskWhoRelation] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Third_Party_Provider__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Third_Party_Provider__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Topic', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Topic] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Topic__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Topic__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Tracking__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Tracking__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='UndecidedEventRelation', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[UndecidedEventRelation] s (nolock) on s.[Id] = a.[ParentId]
select [table]='User', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[User] s (nolock) on s.[Id] = a.[ParentId]
select [table]='UserAppInfo', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[UserAppInfo] s (nolock) on s.[Id] = a.[ParentId]
select [table]='UserLogin', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[UserLogin] s (nolock) on s.[Id] = a.[ParentId]
select [table]='UserPermissionAccess', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[UserPermissionAccess] s (nolock) on s.[Id] = a.[ParentId]
select [table]='UserRole', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[UserRole] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Vetting_Result__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Vetting_Result__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Wealth_Advice_Referral_Program__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Wealth_Advice_Referral_Program__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Wealth_Central_Adoption__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Wealth_Central_Adoption__c] s (nolock) on s.[Id] = a.[ParentId]
select [table]='WorkAccess', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[WorkAccess] s (nolock) on s.[Id] = a.[ParentId]
select [table]='WorkBadgeDefinition', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[WorkBadgeDefinition] s (nolock) on s.[Id] = a.[ParentId]
select [table]='Workshop__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Workshop__c] s (nolock) on s.[Id] = a.[ParentId]
*/
select [prefix]=left([ParentId],3), count(*)
from [sf].[Attachment] a (nolock) 
where 1=1
--and [ParentId] = 'a0F6F00000teLGxUAM'
--and not exists (
--	select 1 from [sf].[EmailTemplate] where [Id] = a.[ParentId]
--)
group by left([ParentId],3)
order by left([ParentId],3)
/*
Prefix	Object
001		Account
003		Contact
006		Opportunity
500		Case
00Q		Lead
00P		Attachment
068		ContentVersion
069		ContentDocument

Total Document Count for all Licensee
prefix	(No column name)
001	36		-- Account
00T	6162	-- Task
00X	3	-- EmailTemplate
500	9	-- Case
a09	10766	-- Assurance_Review__c
a0F	3237	-- EmailTemplate
a0H	26		-- PSA__c
a0N	71400	-- Question_Responses__c
*/
