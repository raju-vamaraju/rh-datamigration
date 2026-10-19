SELECT [object_api_name]
      ,[field_api_name]
      ,[field_label]
      ,[reference_to]
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
      ,[picklist_values]
      ,[etl_loadls]
FROM [SalesforceMigration].[ids].[sf_object_meta_ra] (nolock)
where 1=1
--and [data_type] = 'picklist'
--and [field_api_name] not in ('CreatedById', 'LastModifiedById', 'OwnerId','LastModifiedDate', 'IsDeleted', 'SystemModstamp', 'LastAttachmentDate', 'LastViewedDate', 'CreatedDate', 'LastReferencedDate')
and [object_api_name] = 'Attachment'   --'AttachmentAssignment'
--and ([reference_to] is not null
--or [calculated] = 1
--)
order by [reference_to],[field_api_name]
;
/* gen field list to be used in python script sf_target_fields.py */
SELECT [object_api_name]
      ,[field_python] = concat(',''',[field_api_name],'''')
      ,[field_sql] = iif([reference_to] is null
                            , iif([data_type]='boolean'
                                    , concat(',[',[field_api_name],'] = iif(s.[',[field_api_name],'] = 1, ''true'', ''false'')')
                                    , concat(',s.[',[field_api_name],']')
                                )
                            , concat(',[',[field_api_name],'] = coalesce(x.[Id-tgt],'''')')
                        )
-- select *
FROM [SalesforceMigration].[ids].[sf_object_meta_ra] (nolock)
where 1=1
--and [field_api_name] not in ('Id','CreatedById', 'LastModifiedById', 'OwnerId','LastModifiedDate', 'IsDeleted', 'SystemModstamp', 'LastAttachmentDate', 'LastViewedDate', 'CreatedDate', 'LastReferencedDate')
and [object_api_name] = 'Attachment'   --'AttachmentAssignment'
and [calculated] = 0
order by [reference_to],[field_api_name]
;
/*
select distinct [object_api_name], [reference_to]
FROM [SalesforceMigration].[ids].[sf_object_meta_ra] (nolock)
where 1=1
and [reference_to] like '%"Attachment"%'
order by 1, 2
*/
/*
-- truncate table [ADVICE_ETL_PRD].[sfrhd].[CommPay_Supplier]
;
select *
from [ADVICE_ETL_PRD].[sfrhd].[CommPay_Supplier]
where 1=1
and [Licensee__c] = 'Shadforth'
;
select *
from [ADVICE_ETL_PRD].[sfrhd].[vw_upsert_Question_Responses-Shadforth]
;
*/
/*

select [object_api_name]
FROM [SalesforceMigration].[ids].[sf_object_meta_ra] (nolock)
where 1=1
and [reference_to] like '%Attachment%'
order by [object_api_name]

*/
