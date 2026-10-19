Use [SalesforceMigration]
go

SELECT [stmt] = replace(replace(
                    'TRUNCATE TABLE [&sch&].[&tbl&] ;','&sch&',s.name)
                    ,'&tbl&',t.name)
FROM sys.tables AS t
JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
WHERE s.name = 'sfrhd'
GROUP BY
    s.name,
    t.name
ORDER BY
     t.name
;

/*   
TRUNCATE TABLE [sfrhd].[A1_Support_Staff_Registrations__c] ;
TRUNCATE TABLE [sfrhd].[Account] ;
TRUNCATE TABLE [sfrhd].[AccountContactRelation] ;
TRUNCATE TABLE [sfrhd].[Accreditations__c] ;
TRUNCATE TABLE [sfrhd].[Adviser_Academy__c] ;
TRUNCATE TABLE [sfrhd].[Adviser_ASN_Snapshot__c] ;
TRUNCATE TABLE [sfrhd].[AdviserOne_Event__c] ;
TRUNCATE TABLE [sfrhd].[Approval__c] ;
TRUNCATE TABLE [sfrhd].[Area_of_Advice__c] ;
TRUNCATE TABLE [sfrhd].[ASF_CSA_Case__c] ;
TRUNCATE TABLE [sfrhd].[ASF_CSA_Case_dv__c] ;
TRUNCATE TABLE [sfrhd].[ASN_Indicator_History__c] ;
TRUNCATE TABLE [sfrhd].[Assurance_Event__c] ;
TRUNCATE TABLE [sfrhd].[Assurance_Review__c] ;
TRUNCATE TABLE [sfrhd].[BID_Case__c] ;
TRUNCATE TABLE [sfrhd].[BrandTemplate] ;
TRUNCATE TABLE [sfrhd].[Breach_Reporting__c] ;
TRUNCATE TABLE [sfrhd].[BusinessHours] ;
TRUNCATE TABLE [sfrhd].[Calculation__c] ;
TRUNCATE TABLE [sfrhd].[Campaign] ;
TRUNCATE TABLE [sfrhd].[CampaignMember] ;
TRUNCATE TABLE [sfrhd].[Case] ;
TRUNCATE TABLE [sfrhd].[Case_Snapshot__c] ;
TRUNCATE TABLE [sfrhd].[CaseComment] ;
TRUNCATE TABLE [sfrhd].[Client_File__c] ;
TRUNCATE TABLE [sfrhd].[Client_Service_Model_Implementation__c] ;
TRUNCATE TABLE [sfrhd].[CommPay_Supplier__c] ;
TRUNCATE TABLE [sfrhd].[Complained_Advisers__c] ;
TRUNCATE TABLE [sfrhd].[Consequence_Management_Forum_Entry__c] ;
TRUNCATE TABLE [sfrhd].[Contact] ;
TRUNCATE TABLE [sfrhd].[CSA_Case__c] ;
TRUNCATE TABLE [sfrhd].[CSA_Case_dv__c] ;
TRUNCATE TABLE [sfrhd].[CSA_Fee_Switch_Off_History__c] ;
TRUNCATE TABLE [sfrhd].[CSO__c] ;
TRUNCATE TABLE [sfrhd].[Email_Log__c] ;
TRUNCATE TABLE [sfrhd].[EmailMessage] ;
TRUNCATE TABLE [sfrhd].[EmailTemplate] ;
TRUNCATE TABLE [sfrhd].[EnhancedLetterhead] ;
TRUNCATE TABLE [sfrhd].[Event] ;
TRUNCATE TABLE [sfrhd].[EventRelation] ;
TRUNCATE TABLE [sfrhd].[Folder] ;
TRUNCATE TABLE [sfrhd].[Group] ;
TRUNCATE TABLE [sfrhd].[Incident_File_Review__c] ;
TRUNCATE TABLE [sfrhd].[InitiativeChecklist__c] ;
TRUNCATE TABLE [sfrhd].[Library_Text__c] ;
TRUNCATE TABLE [sfrhd].[LookupName__c] ;
TRUNCATE TABLE [sfrhd].[Master_Item__c] ;
TRUNCATE TABLE [sfrhd].[Master_Module__c] ;
TRUNCATE TABLE [sfrhd].[Master_Questions__c] ;
TRUNCATE TABLE [sfrhd].[Master_Topic__c] ;
TRUNCATE TABLE [sfrhd].[Master_workshop__c] ;
TRUNCATE TABLE [sfrhd].[MasterQuestions_Targetedreviews__c] ;
TRUNCATE TABLE [sfrhd].[Module__c] ;
TRUNCATE TABLE [sfrhd].[NAPW__c] ;
TRUNCATE TABLE [sfrhd].[Opportunity] ;
TRUNCATE TABLE [sfrhd].[Organization] ;
TRUNCATE TABLE [sfrhd].[PermissionSet] ;
TRUNCATE TABLE [sfrhd].[PermissionSetAssignment] ;
TRUNCATE TABLE [sfrhd].[PermissionSetGroup] ;
TRUNCATE TABLE [sfrhd].[PermissionSetLicense] ;
TRUNCATE TABLE [sfrhd].[Pricebook2] ;
TRUNCATE TABLE [sfrhd].[Product_Questions__c] ;
TRUNCATE TABLE [sfrhd].[Product2] ;
TRUNCATE TABLE [sfrhd].[Profile] ;
TRUNCATE TABLE [sfrhd].[PSA__c] ;
TRUNCATE TABLE [sfrhd].[QA__c] ;
TRUNCATE TABLE [sfrhd].[QA_Assignment_Hisotry__c] ;
TRUNCATE TABLE [sfrhd].[Qualification__c] ;
TRUNCATE TABLE [sfrhd].[Qualification_Type__c] ;
TRUNCATE TABLE [sfrhd].[Question_Group__c] ;
TRUNCATE TABLE [sfrhd].[Question_Responses__c] ;
TRUNCATE TABLE [sfrhd].[RecordType] ;
TRUNCATE TABLE [sfrhd].[Refund_Request__c] ;
TRUNCATE TABLE [sfrhd].[Registered_Training_Organisation__c] ;
TRUNCATE TABLE [sfrhd].[Response_Finding__c] ;
TRUNCATE TABLE [sfrhd].[Reviews_Accounted__c] ;
TRUNCATE TABLE [sfrhd].[SecondaryPracticeAdviserHistory__c] ;
TRUNCATE TABLE [sfrhd].[SelectedQuestions_Targetedreviews__c] ;
TRUNCATE TABLE [sfrhd].[Snapshot_Data__c] ;
TRUNCATE TABLE [sfrhd].[Special_Conditions__c] ;
TRUNCATE TABLE [sfrhd].[Target__c] ;
TRUNCATE TABLE [sfrhd].[Task] ;
TRUNCATE TABLE [sfrhd].[TaskRelation] ;
TRUNCATE TABLE [sfrhd].[Third_Party_Provider__c] ;
TRUNCATE TABLE [sfrhd].[Topic__c] ;
TRUNCATE TABLE [sfrhd].[Tracking__c] ;
TRUNCATE TABLE [sfrhd].[User] ;
TRUNCATE TABLE [sfrhd].[UserLicense] ;
TRUNCATE TABLE [sfrhd].[UserRole] ;
TRUNCATE TABLE [sfrhd].[Vetting_Result__c] ;
TRUNCATE TABLE [sfrhd].[Wealth_Central_Adoption__c] ;
TRUNCATE TABLE [sfrhd].[Workshop__c] ;
TRUNCATE TABLE [sfrhd].[PSA__c] ;
GO
*/





