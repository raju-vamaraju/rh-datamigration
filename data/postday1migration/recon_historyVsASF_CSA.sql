Use [ADVICE_ETL_PRD]
go

/*
Reconccile between CSA_Fee_Switch_Off_History__c and ASF_CSA_Case_dv__c / CSA_Case_dv__c for Shadforth
*/
SELECT a.[Is_Active__c],
count(*)
FROM [ADVICE_ETL_PRD].[sf].[CSA_Fee_Switch_Off_History__c] h
join [ADVICE_ETL_PRD].[sf].[ASF_CSA_Case_dv__c] a
	on a.[Id] = h.[asf_csa_case_dv__c]
where 1=1
and h.[Licensee__c] = 'Shadforth'
group by a.[Is_Active__c]
order by a.[Is_Active__c] desc
;
SELECT a.[Is_Active__c],
count(*)
FROM [ADVICE_ETL_PRD].[sf].[CSA_Fee_Switch_Off_History__c] h
join [ADVICE_ETL_PRD].[sf].[CSA_Case_dv__c] a
	on a.[Id] = h.[csa_case_dv__c]
where 1=1
and h.[Licensee__c] = 'Shadforth'
group by a.[Is_Active__c]
order by a.[Is_Active__c] desc
;
SELECT h.*
FROM [ADVICE_ETL_PRD].[sf].[CSA_Fee_Switch_Off_History__c] h
left join [ADVICE_ETL_PRD].[sf].[ASF_CSA_Case_dv__c] a
	on a.[Id] = h.[asf_csa_case_dv__c]
left join [ADVICE_ETL_PRD].[sf].[CSA_Case_dv__c] c
	on c.[Id] = h.[csa_case_dv__c]
where 1=1
and (h.[asf_csa_case_dv__c] is not null
and a.[Id] is null
and h.[Licensee__c] = 'Shadforth'
)
or (h.[csa_case_dv__c] is not null
and c.[Id] is null
and h.[Licensee__c] = 'Shadforth'
)
;
