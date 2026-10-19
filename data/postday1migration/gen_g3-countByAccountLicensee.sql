/* Objects with ContactId */
Use [ADVICE_ETL_PRD]
go

with cte_tbl as (
	select * from (values 
		--('AcceptedEventRelation'),
		--('AccountBrand'),
		--('AccountContactRelation'),
		--('AccountContactRole'),
		--('Case'),
		--('Entitlement'),
		--('MessagingEndUser'),
		--('Asset'),
		--('Event'),
		--('EventRelation'),
		--('EventWhoRelation'),
		--('ServiceContractvContact'),
		--('DeclinedEventRelation'),
		--('Contractv'),
		--('Quote'),
		--('UndecidedEventRelation'),
		--('User'),
		--('Task'),
		('TaskRelation'),
		('TaskWhoRelation'),
		('LookedUpFromActivity'),
		('NetworkSelfRegistration'),
		('OpenActivity'),
		('Opportunity'),
		('Order'),
		('Lead'),
		('ExternalSocialAccount'),
		('MessagingSession'),
		('SocialPost'),
		('UserRole'),
		('LookedUpFromActivity'),
		('OpenActivity'),
		('UserProvisioningRequest'),
		('ExternalSocialAccount')
	) as t(table_name)
)
select replace('select [table]=''&tbl&'',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[&tbl&] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;', '&tbl&',[table_name]) as sql_stmt
from [cte_tbl]



/*
--select [table]='AcceptedEventRelation',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[AcceptedEventRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='AccountBrand',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[AccountBrand] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
select [table]='AccountContactRelation',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[AccountContactRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
AccountContactRelation	Actuate	158
AccountContactRelation	Bridges	768
AccountContactRelation	EWM	1
AccountContactRelation	FSP	2
AccountContactRelation	IOOF Finance Choice	387
AccountContactRelation	Lonsdale	2
AccountContactRelation	MLC Advice	46
AccountContactRelation	Shadforth	648

--select [table]='AccountContactRole',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[AccountContactRole] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
select [table]='Case',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Case] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
Case	Actuate	214
Case	Bridges	6377
Case	FSP	5
Case	IOOF Finance Choice	102
Case	Lonsdale	1
Case	MLC Advice	235
Case	Shadforth	2354

--select [table]='Entitlement',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Entitlement] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='MessagingEndUser',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[MessagingEndUser] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='Asset',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Asset] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
select [table]='Event',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Event] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Event	Bridges	29
Event	Shadforth	1

select [table]='EventRelation',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[EventRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
EventRelation	Bridges	45
EventRelation	Shadforth	1

select [table]='EventWhoRelation',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[EventWhoRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
EventWhoRelation	Bridges	22
EventWhoRelation	Shadforth	1

--select [table]='ServiceContractvContact',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[ServiceContractvContact] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='DeclinedEventRelation',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[DeclinedEventRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='Contractv',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Contractv] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='Quote',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Quote] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
select [table]='UndecidedEventRelation',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[UndecidedEventRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
UndecidedEventRelation	Bridges	22

select [table]='User',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[User] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
User	Actuate	15
User	Bridges	345
User	IOOF Finance Choice	356
User	Shadforth	406

select [table]='Task',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Task] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Task	Actuate	1279
Task	Bridges	15755
Task	IOOF Finance Choice	393
Task	MLC Advice	165
Task	Shadforth	18258

select [table]='TaskRelation',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[TaskRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
TaskRelation	Actuate	1307
TaskRelation	Bridges	17935
TaskRelation	IOOF Finance Choice	402
TaskRelation	MLC Advice	182
TaskRelation	Shadforth	19273

select [table]='TaskWhoRelation',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[TaskWhoRelation] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
TaskWhoRelation	Actuate	1303
TaskWhoRelation	Bridges	16918
TaskWhoRelation	IOOF Finance Choice	400
TaskWhoRelation	MLC Advice	172
TaskWhoRelation	Shadforth	18589

--select [table]='LookedUpFromActivity',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[LookedUpFromActivity] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='NetworkSelfRegistration',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[NetworkSelfRegistration] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='OpenActivity',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[OpenActivity] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
select [table]='Opportunity',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Opportunity] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
Opportunity	Actuate	30
Opportunity	Bridges	403
Opportunity	IOOF Finance Choice	25
Opportunity	MLC Advice	23
Opportunity	Shadforth	141

--select [table]='Order',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Order] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='Lead',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[Lead] t join [sf].[Contact] c on c.[Id] = t.[ConvertedContactId] group by c.[Licensee__c] order by c.[Licensee__c] ;
-- select [table]='ExternalSocialAccount',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[ExternalSocialAccount] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='MessagingSession',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[MessagingSession] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='SocialPost',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[SocialPost] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
select [table]='UserRole',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[UserRole] t join [sf].[Account] c on c.[Id] = t.[PortalAccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
table	Licensee__c	count
UserRole	NULL	25
UserRole	Actuate	2
UserRole	Bridges	51
UserRole	IOOF Finance Choice	3
UserRole	Shadforth	8

--select [table]='LookedUpFromActivity',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[LookedUpFromActivity] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='OpenActivity',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[OpenActivity] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
--select [table]='UserProvisioningRequest',c.[Licensee__c], [count]=count(t.[Id]) from [sf].[UserProvisioningRequest] t join [sf].[Account] c on c.[Id] = t.[AccountId] group by c.[Licensee__c] order by c.[Licensee__c] ;
*/
