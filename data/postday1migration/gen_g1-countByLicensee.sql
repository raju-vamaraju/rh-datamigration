Use [ADVICE_ETL_PRD]
go

with cte_tbl as (
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
select replace('select [table]=''&tbl&'',[Licensee__c], [count]=count(*) from [sf].[&tbl&] group by [Licensee__c] order by [Licensee__c] ;', '&tbl&',[table_name]) as sql_stmt
from [cte_tbl]
/*
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

select [table]='Assurance_Review__c',[Licensee__c], [count]=count(*) from [sf].[Assurance_Review__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Assurance_Review__c	/resource/Bridges_Logo	3539
Assurance_Review__c	/resource/Shadforth_Logo	2698
Assurance_Review__c	NOT ASSIGNED	430

select [table]='Contact',[Licensee__c], [count]=count(*) from [sf].[Contact] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Contact	Actuate	2
Contact	Bridges	308
Contact	IOOF Finance Choice	1
Contact	Shadforth	13

select [table]='CommPay_Supplier__c',[Licensee__c], [count]=count(*) from [sf].[CommPay_Supplier__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
CommPay_Supplier__c	NULL	25
CommPay_Supplier__c	Bridges	11
CommPay_Supplier__c	Shadforth	11

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

select [table]='Contact',[Licensee__c], [count]=count(*) from [sf].[Contact] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Contact	Actuate	62
Contact	AET	1
Contact	Bridges	2311
Contact	Consultum	54
Contact	Elders	16
Contact	EWM	4
Contact	FSP	88
Contact	GPG	17
Contact	IIML	1
Contact	IOOF Finance Choice	2
Contact	IOOF Insurance Brokers	1
Contact	Lonsdale	43
Contact	M3	182
Contact	MLC Advice	192
Contact	RI	167
Contact	Shadforth	1527
Contact	TenFifty	24

select [table]='Opportunity',[Licensee__c], [count]=count(*) from [sf].[Opportunity] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Opportunity	Actuate	30
Opportunity	Bridges	403
Opportunity	IOOF Finance Choice	25
Opportunity	MLC Advice	23
Opportunity	Shadforth	141

select [table]='Contact',[Licensee__c], [count]=count(*) from [sf].[Contact] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Contact	Actuate	130
Contact	Bridges	13661
Contact	Shadforth	19453

select [table]='PSA__c',[Licensee__c], [count]=count(*) from [sf].[PSA__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
PSA__c	NULL	57

select [table]='Wealth_Central_Adoption__c',[Licensee__c], [count]=count(*) from [sf].[Wealth_Central_Adoption__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Wealth_Central_Adoption__c	Shadforth	1465

select [table]='Wealth_Central_Adoption__c',[Licensee__c], [count]=count(*) from [sf].[Wealth_Central_Adoption__c] group by [Licensee__c] order by [Licensee__c] ;
table	Licensee__c	count
Wealth_Central_Adoption__c	NULL	1
Wealth_Central_Adoption__c	Actuate	22
Wealth_Central_Adoption__c	Bridges	330
Wealth_Central_Adoption__c	IOOF Finance Choice	14
Wealth_Central_Adoption__c	MLC Advice	1
Wealth_Central_Adoption__c	Shadforth	419
*/
