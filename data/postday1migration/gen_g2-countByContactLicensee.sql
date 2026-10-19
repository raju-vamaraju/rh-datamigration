/* Objects with ContactId */
Use [ADVICE_ETL_PRD]
go

with cte_tbl as (
	select distinct * from (values 
		--('AccountContactRelation')
		--('AccountContactRole')
		('CampaignMember')
		--,('Case')
		--,('ContractContactRole')
		--,('MessagingEndUser')
		--,('User')
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
select replace('select [table]=''&tbl&'',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[&tbl&] t join [sf].[Contact] c on c.[Id] = t.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;', '&tbl&',[table_name]) as sql_stmt
from [cte_tbl]
/*
select [table]='CampaignMember',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[CampaignMember] t join [sf].[Contact] c on c.[Id] = t.[ContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;;
table	Licensee__c	count
CampaignMember	Bridges	88
CampaignMember	Shadforth	5
*/
