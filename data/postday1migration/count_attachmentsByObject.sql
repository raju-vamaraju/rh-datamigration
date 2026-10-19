select [table] = [name], [sql_stmt] = replace('select [table]=''&tbl&'', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[&tbl&] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = ''Shadforth''', '&tbl&', [name])
from sys.tables
where 1=1
and SCHEMA_NAME([schema_id]) = 'sf'
and [name] in ('Account', 'Contact', 'Lead', 'Opportunity', 'Case')
/*
select [table]='Account', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Account] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = 'Shadforth'
table	AttachmentCount
Account	0

select [table]='User', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[User] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = 'Shadforth'

select [table]='Contact', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Contact] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = 'Shadforth'
table	AttachmentCount
Contact	0

select [table]='Incident_File_Review__c', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Incident_File_Review__c] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = 'Shadforth'
table	AttachmentCount
Incident_File_Review__c	1259

select [table]='Opportunity', [AttachmentCount] = count(*) from [sf].[Attachment] a (nolock) join [sf].[Opportunity] s (nolock) on s.[Id] = a.[ParentId] and s.[Licensee__c] = 'Shadforth'
table	AttachmentCount
Opportunity	0

*/
