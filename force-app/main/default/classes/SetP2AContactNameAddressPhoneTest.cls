@isTest
private class SetP2AContactNameAddressPhoneTest {
@testSetUp
static void setup() {
    	List<Contact> conList = new List<Contact>();
        	Contact conOne = new Contact (
            	LastName = 'Last1320A', Phone2Action_Prefix__c = 'A', Phone2Action_First_Name__c= 'First', Phone2Action_Middle_Name__c= NULL,
                Phone2Action_Last_Name__c= NULL, Phone2Action_Suffix__c= 'Jr', Phone2Action_Mailing_Address1__c= 'TestA', 
           		Phone2Action_City__c= 'TestA', Phone2Action_Mailing_State__c= 'VA', Phone2Action_Zip5__c = '12345',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.1, Phone2Action_Phone__c = '1234567890',
                Phone2Action_Phone_Bad__c = TRUE, Phone2Action_Phone_Optin__c = TRUE, Phone2Action_Phone_Type__c = 'Mobile',
                Phone2Action_Phone2__c = '1234567892', Phone2Action_Phone2_Bad__c = TRUE, Phone2Action_Phone2_Optin__c = TRUE,
                Phone2Action_Phone2_Type__c = 'Landline', Phone2Action_Phone3__c = '1234567893', Phone2Action_Phone3_Bad__c = TRUE,
                Phone2Action_Phone3_Optin__c = TRUE, Phone2Action_Phone3_Type__c = 'Voip', Phone2Action_Phone4__c = '1234567894',
                Phone2Action_Phone4_Bad__c = TRUE, Phone2Action_Phone4_Optin__c = TRUE, Phone2Action_Phone4_Type__c = 'Mobile');
        	conList.add(conOne);
    
    		Contact conTwo = new Contact (
            	LastName = 'Last1320B', Phone2Action_Prefix__c = 'B', Phone2Action_First_Name__c= 'First', Phone2Action_Middle_Name__c= NULL,
                Phone2Action_Last_Name__c= NULL, Phone2Action_Suffix__c= 'Jr', Phone2Action_Mailing_Address1__c= 'TestB', 
           		Phone2Action_City__c= 'TestB', Phone2Action_Mailing_State__c= 'VA', Phone2Action_Zip5__c = '12345',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.2, Phone2Action_Phone__c = '1234567890',
                Phone2Action_Phone_Bad__c = FALSE, Phone2Action_Phone_Optin__c = FALSE, Phone2Action_Phone_Type__c = 'Mobile',
                Phone2Action_Phone2__c = '1234567892', Phone2Action_Phone2_Bad__c = FALSE, Phone2Action_Phone2_Optin__c = FALSE,
                Phone2Action_Phone2_Type__c = 'Landline', Phone2Action_Phone3__c = '1234567893', Phone2Action_Phone3_Bad__c = FALSE,
                Phone2Action_Phone3_Optin__c = FALSE, Phone2Action_Phone3_Type__c = 'Voip', Phone2Action_Phone4__c = '1234567894',
                Phone2Action_Phone4_Bad__c = FALSE, Phone2Action_Phone4_Optin__c = FALSE, Phone2Action_Phone4_Type__c = 'Mobile');
        	conList.add(conTwo);

    		Contact conThree = new Contact (
            	LastName = 'Last1320C', Phone2Action_Prefix__c = 'C', Phone2Action_First_Name__c= 'First', Phone2Action_Middle_Name__c= NULL,
                Phone2Action_Last_Name__c= NULL, Phone2Action_Suffix__c= 'Jr', Phone2Action_Mailing_Address1__c= 'TestC', 
           		Phone2Action_City__c= 'TestC', Phone2Action_Mailing_State__c= 'VA', Phone2Action_Zip5__c = '12345',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.3, Phone2Action_Phone__c = '1234567890',
                Phone2Action_Phone_Bad__c = FALSE, Phone2Action_Phone_Optin__c = TRUE, Phone2Action_Phone_Type__c = 'Mobile',
                Phone2Action_Phone2__c = '1234567892', Phone2Action_Phone2_Bad__c = FALSE, Phone2Action_Phone2_Optin__c = TRUE,
                Phone2Action_Phone2_Type__c = 'Landline', Phone2Action_Phone3__c = '1234567893', Phone2Action_Phone3_Bad__c = FALSE,
                Phone2Action_Phone3_Optin__c = TRUE, Phone2Action_Phone3_Type__c = 'Voip', Phone2Action_Phone4__c = '1234567894',
                Phone2Action_Phone4_Bad__c = FALSE, Phone2Action_Phone4_Optin__c = TRUE, Phone2Action_Phone4_Type__c = 'Mobile');
        	conList.add(conThree);

    		Contact conFour = new Contact (
            	LastName = 'Last1320D', Phone2Action_Prefix__c = 'D', Phone2Action_First_Name__c= 'First', Phone2Action_Middle_Name__c= NULL,
                Phone2Action_Last_Name__c= NULL, Phone2Action_Suffix__c= 'Jr', Phone2Action_Mailing_Address1__c= 'TestD', 
           		Phone2Action_City__c= 'TestD', Phone2Action_Mailing_State__c= 'VA', Phone2Action_Zip5__c = '12345',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.4, Phone2Action_Phone__c = '1234567890',
                Phone2Action_Phone_Bad__c = TRUE, Phone2Action_Phone_Optin__c = FALSE, Phone2Action_Phone_Type__c = 'Mobile',
                Phone2Action_Phone2__c = '1234567892', Phone2Action_Phone2_Bad__c = TRUE, Phone2Action_Phone2_Optin__c = FALSE,
                Phone2Action_Phone2_Type__c = 'Landline', Phone2Action_Phone3__c = '1234567893', Phone2Action_Phone3_Bad__c = TRUE,
                Phone2Action_Phone3_Optin__c = FALSE, Phone2Action_Phone3_Type__c = 'Voip', Phone2Action_Phone4__c = '1234567894',
                Phone2Action_Phone4_Bad__c = TRUE, Phone2Action_Phone4_Optin__c = FALSE, Phone2Action_Phone4_Type__c = 'Mobile');
        	conList.add(conFour);

    		Contact conFive = new Contact (
            	LastName = 'Last1320E', Phone2Action_Prefix__c = 'E', Phone2Action_First_Name__c= 'First', Phone2Action_Middle_Name__c= NULL,
                Phone2Action_Last_Name__c= NULL, Phone2Action_Suffix__c= 'Jr', Phone2Action_Mailing_Address1__c= 'TestE', 
           		Phone2Action_City__c= 'TestE', Phone2Action_Mailing_State__c= 'VA', Phone2Action_Zip5__c = '12345',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.5, Phone2Action_Phone__c = '1234567890',
                Phone2Action_Phone_Bad__c = TRUE, Phone2Action_Phone_Optin__c = TRUE, Phone2Action_Phone_Type__c = 'Mobile',
                Phone2Action_Phone2__c = '1234567892', Phone2Action_Phone2_Bad__c = TRUE, Phone2Action_Phone2_Optin__c = TRUE,
                Phone2Action_Phone2_Type__c = 'Landline', Phone2Action_Phone3__c = '1234567893', Phone2Action_Phone3_Bad__c = FALSE,
                Phone2Action_Phone3_Optin__c = FALSE, Phone2Action_Phone3_Type__c = 'Voip', Phone2Action_Phone4__c = '1234567894',
                Phone2Action_Phone4_Bad__c = FALSE, Phone2Action_Phone4_Optin__c = FALSE, Phone2Action_Phone4_Type__c = 'Mobile');
        	conList.add(conFive);

    		Contact conSix = new Contact (
            	LastName = 'Last1320F', Phone2Action_Prefix__c = 'F', Phone2Action_First_Name__c= 'First', Phone2Action_Middle_Name__c= NULL,
                Phone2Action_Last_Name__c= NULL, Phone2Action_Suffix__c= 'Jr', Phone2Action_Mailing_Address1__c= 'TestF', 
           		Phone2Action_City__c= 'TestF', Phone2Action_Mailing_State__c= 'VA', Phone2Action_Zip5__c = '12345',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.6, Phone2Action_Phone__c = '1234567890',
                Phone2Action_Phone_Bad__c = FALSE, Phone2Action_Phone_Optin__c = FALSE, Phone2Action_Phone_Type__c = 'Mobile',
                Phone2Action_Phone2__c = '1234567892', Phone2Action_Phone2_Bad__c = FALSE, Phone2Action_Phone2_Optin__c = FALSE,
                Phone2Action_Phone2_Type__c = 'Landline', Phone2Action_Phone3__c = '1234567893', Phone2Action_Phone3_Bad__c = TRUE,
                Phone2Action_Phone3_Optin__c = TRUE, Phone2Action_Phone3_Type__c = 'Voip', Phone2Action_Phone4__c = '1234567894',
                Phone2Action_Phone4_Bad__c = TRUE, Phone2Action_Phone4_Optin__c = TRUE, Phone2Action_Phone4_Type__c = 'Mobile');
        	conList.add(conSix);
    
    insert conList;
    
		}

static testmethod void test() {
        Test.startTest();
        SetP2AContactNameAddressPhone spcn = new SetP2AContactNameAddressPhone();
        Id batchId = Database.executeBatch(spcn);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(6, [select count()from contact where FirstName ='First']);
}   
}