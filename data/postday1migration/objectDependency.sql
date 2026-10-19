-- identify reference objects by object
SELECT [object_api_name], [reference_to]
FROM [SalesforceMigration].[ids].[sf_object_meta_ra]
where 1=1
and [object_api_name] like 'Refund_Request__c'
and [reference_to] is not null
order by [object_api_name], [reference_to]
;
-- identify dependent objects by reference object
SELECT [object_api_name], [field_api_name]
FROM [SalesforceMigration].[ids].[sf_object_meta_ra]
where 1=1
and [reference_to] like '%"Refund_Request__c"%'
order by [object_api_name]
;

