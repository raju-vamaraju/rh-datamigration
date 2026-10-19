SELECT TOP (1000) [object_api_name]
      ,[field_api_name]
      ,[field_label]
      ,[description]
      ,[data_type]
      ,[length]
      ,[precision]
      ,[scale]
      ,[nillable]
      ,[unique]
      ,[calculated]
      ,[calculated_formula]
      ,[inline_help_text]
      ,[reference_to]
      ,[picklist_values]
      ,[etl_loadls]
-- delete
FROM [ADVICE_ETL_PRD].[ids].[sf_object_meta]
where 1=1
and [object_api_name] = 'Opportunity'   --'Case'
and [field_api_name] in (
'Description'
,'Probability'
,'DB_Competitor__c'
,'Type'
)
order by [reference_to],[field_api_name]