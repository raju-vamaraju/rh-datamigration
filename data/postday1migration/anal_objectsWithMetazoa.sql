with cte_meta as (
	select distinct [object_api_name]
	from [ADVICE_ETL_PRD].[ids].[sf_object_meta_ra]
	where 1=1
	and [field_api_name] = 'Metazoa_External_Id__c'
)
SELECT distinct t.[object_api_name]
FROM [ADVICE_ETL_PRD].[ids].[sf_object_meta_ra] t
left join [cte_meta] c on t.[object_api_name] = c.[object_api_name]
where 1=1
and c.[object_api_name] is null
order by t.[object_api_name]