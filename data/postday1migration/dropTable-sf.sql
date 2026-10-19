Use [SalesforceMigration]
go

SELECT [stmt] = replace(replace(
                    'DROP TABLE IF EXISTS [&sch&].[&tbl&] ;','&sch&',s.name)
                    ,'&tbl&',t.name)
FROM sys.tables AS t
JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
WHERE s.name = 'sf'
and t.[name] not in (
-- this list of objects are empty in source org
-- but they may be referenced by the transformation views
'ANZ_Lookback__c'
,'ASF_CSA_Case__c'
,'CSA_Case__c'
)
GROUP BY
    s.name,
    t.name
ORDER BY
     t.name
;

/*   
DROP TABLE IF EXISTS [sf].[A1_Support_Staff_Registrations__c] ;
DROP TABLE IF EXISTS [sf].[Account] ;
DROP TABLE IF EXISTS [sf].[AccountContactRelation] ;
DROP TABLE IF EXISTS [sf].[Accreditations__c] ;
DROP TABLE IF EXISTS [sf].[Adviser_Academy__c] ;
DROP TABLE IF EXISTS [sf].[Adviser_ASN_Snapshot__c] ;
DROP TABLE IF EXISTS [sf].[AdviserHUB_Wave_Definition__c] ;
DROP TABLE IF EXISTS [sf].[AdviserOne_Event__c] ;
DROP TABLE IF EXISTS [sf].[AdviserOne_Site_Content__c] ;
DROP TABLE IF EXISTS [sf].[Approval__c] ;
DROP TABLE IF EXISTS [sf].[Area_of_Advice__c] ;
--DROP TABLE IF EXISTS [sf].[ASF_CSA_Case__c] ;
DROP TABLE IF EXISTS [sf].[ASF_CSA_Case_dv__c] ;
DROP TABLE IF EXISTS [sf].[ASN_Indicator_History__c] ;
DROP TABLE IF EXISTS [sf].[Assurance_Event__c] ;
DROP TABLE IF EXISTS [sf].[Assurance_Review__c] ;
DROP TABLE IF EXISTS [sf].[Attachment] ;
DROP TABLE IF EXISTS [sf].[BID_Case__c] ;
DROP TABLE IF EXISTS [sf].[BrandTemplate] ;
DROP TABLE IF EXISTS [sf].[Breach_Reporting__c] ;
DROP TABLE IF EXISTS [sf].[BusinessHours] ;
DROP TABLE IF EXISTS [sf].[Calculation__c] ;
DROP TABLE IF EXISTS [sf].[Campaign] ;
DROP TABLE IF EXISTS [sf].[CampaignMember] ;
DROP TABLE IF EXISTS [sf].[Case] ;
DROP TABLE IF EXISTS [sf].[Case_Snapshot__c] ;
DROP TABLE IF EXISTS [sf].[CaseComment] ;
DROP TABLE IF EXISTS [sf].[Client_File__c] ;
DROP TABLE IF EXISTS [sf].[Client_Service_Model_Implementation__c] ;
DROP TABLE IF EXISTS [sf].[CommPay_Supplier__c] ;
DROP TABLE IF EXISTS [sf].[Complained_Advisers__c] ;
DROP TABLE IF EXISTS [sf].[Consequence_Management_Forum_Entry__c] ;
DROP TABLE IF EXISTS [sf].[Contact] ;
--DROP TABLE IF EXISTS [sf].[CSA_Case__c] ;
DROP TABLE IF EXISTS [sf].[CSA_Case_dv__c] ;
DROP TABLE IF EXISTS [sf].[CSA_Fee_Switch_Off_History__c] ;
DROP TABLE IF EXISTS [sf].[CSO__c] ;
DROP TABLE IF EXISTS [sf].[Email_Log__c] ;
DROP TABLE IF EXISTS [sf].[EmailMessage] ;
DROP TABLE IF EXISTS [sf].[EmailTemplate] ;
DROP TABLE IF EXISTS [sf].[EnhancedLetterhead] ;
DROP TABLE IF EXISTS [sf].[Event] ;
DROP TABLE IF EXISTS [sf].[EventRelation] ;
DROP TABLE IF EXISTS [sf].[Folder] ;
DROP TABLE IF EXISTS [sf].[Group] ;
DROP TABLE IF EXISTS [sf].[GroupMember] ;
DROP TABLE IF EXISTS [sf].[Incident_File_Review__c] ;
DROP TABLE IF EXISTS [sf].[InitiativeChecklist__c] ;
DROP TABLE IF EXISTS [sf].[Library_Text__c] ;
DROP TABLE IF EXISTS [sf].[LookupName__c] ;
DROP TABLE IF EXISTS [sf].[Master_Item__c] ;
DROP TABLE IF EXISTS [sf].[Master_module__c] ;
DROP TABLE IF EXISTS [sf].[Master_Questions__c] ;
DROP TABLE IF EXISTS [sf].[Master_Topic__c] ;
DROP TABLE IF EXISTS [sf].[Master_workshop__c] ;
DROP TABLE IF EXISTS [sf].[MasterQuestions_Targetedreviews__c] ;
DROP TABLE IF EXISTS [sf].[Module__c] ;
DROP TABLE IF EXISTS [sf].[NAPW__c] ;
DROP TABLE IF EXISTS [sf].[Opportunity] ;
DROP TABLE IF EXISTS [sf].[Organization] ;
DROP TABLE IF EXISTS [sf].[Paraplanning__c] ;
DROP TABLE IF EXISTS [sf].[PermissionSet] ;
DROP TABLE IF EXISTS [sf].[PermissionSetAssignment] ;
DROP TABLE IF EXISTS [sf].[PermissionSetGroup] ;
DROP TABLE IF EXISTS [sf].[PermissionSetLicense] ;
DROP TABLE IF EXISTS [sf].[Pricebook2] ;
DROP TABLE IF EXISTS [sf].[Product_Questions__c] ;
DROP TABLE IF EXISTS [sf].[Product2] ;
DROP TABLE IF EXISTS [sf].[Profile] ;
DROP TABLE IF EXISTS [sf].[PSA__c] ;
DROP TABLE IF EXISTS [sf].[QA__c] ;
DROP TABLE IF EXISTS [sf].[QA_Assignment_Hisotry__c] ;
DROP TABLE IF EXISTS [sf].[Qualification__c] ;
DROP TABLE IF EXISTS [sf].[Qualification_Type__c] ;
DROP TABLE IF EXISTS [sf].[Question_Group__c] ;
DROP TABLE IF EXISTS [sf].[Question_Responses__c] ;
DROP TABLE IF EXISTS [sf].[RecordType] ;
DROP TABLE IF EXISTS [sf].[Refund_Request__c] ;
DROP TABLE IF EXISTS [sf].[Registered_Training_Organisation__c] ;
DROP TABLE IF EXISTS [sf].[Response_Finding__c] ;
DROP TABLE IF EXISTS [sf].[Reviews_Accounted__c] ;
DROP TABLE IF EXISTS [sf].[SecondaryPracticeAdviserHistory__c] ;
DROP TABLE IF EXISTS [sf].[SelectedQuestions_Targetedreviews__c] ;
DROP TABLE IF EXISTS [sf].[Snapshot_Data__c] ;
DROP TABLE IF EXISTS [sf].[Special_Conditions__c] ;
DROP TABLE IF EXISTS [sf].[Target__c] ;
DROP TABLE IF EXISTS [sf].[Task] ;
DROP TABLE IF EXISTS [sf].[TaskRelation] ;
DROP TABLE IF EXISTS [sf].[Third_Party_Provider__c] ;
DROP TABLE IF EXISTS [sf].[Topic__c] ;
DROP TABLE IF EXISTS [sf].[Tracking__c] ;
DROP TABLE IF EXISTS [sf].[User] ;
DROP TABLE IF EXISTS [sf].[UserLicense] ;
DROP TABLE IF EXISTS [sf].[UserRole] ;
DROP TABLE IF EXISTS [sf].[Vetting_Result__c] ;
DROP TABLE IF EXISTS [sf].[Wealth_Central_Adoption__c] ;
DROP TABLE IF EXISTS [sf].[Workshop__c] ;
DROP TABLE IF EXISTS [sf].[PEP__c] ;
*/

/*
RUN THIS AFTER RUNNING B. Script
;
CREATE CLUSTERED COLUMNSTORE INDEX [css_Snapshot_Data] ON [sf].[Snapshot_Data__c] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
;
create table [sf].[ANZ_Lookback__c] (
[Clients_to_proceed_to_remediation_pipeli__c] [varchar](max)
,[CreatedById] [varchar](max)
,[CreatedDate] [varchar](max)
,[Fail_Periods__c] [varchar](max)
,[Id] [varchar](max)
,[IsDeleted] [varchar](max)
,[LastActivityDate] [varchar](max)
,[LastModifiedById] [varchar](max)
,[LastModifiedDate] [varchar](max)
,[LastReferencedDate] [varchar](max)
,[LastViewedDate] [varchar](max)
,[Name] [varchar](max)
,[OwnerId] [varchar](max)
,[Pass_Periods__c] [varchar](max)
,[Periods_in_Sample__c] [varchar](max)
,[Periods_Not_Tested__c] [varchar](max)
,[Periods_Tested__c] [varchar](max)
,[Periods_to_proceed_to_remediation_pipeli__c] [varchar](max)
,[Practice__c] [varchar](max)
,[RecordTypeId] [varchar](max)
,[Review_Status__c] [varchar](max)
,[Segment_Description__c] [varchar](max)
,[Segment_Number__c] [varchar](max)
,[Segment_Outcome__c] [varchar](max)
,[SystemModstamp] [varchar](max)
,[Total_Periods__c] [varchar](max)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

*/
