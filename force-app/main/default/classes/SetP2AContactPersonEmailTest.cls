@isTest
private class SetP2AContactPersonEmailTest {
@testSetUp
static void setup() {
    	List<Contact> conList = new List<Contact>();
        	Contact conOne = new Contact (
            	LastName = 'Last1320A', Phone2Action_Last_Name__c= NULL, Phone2Action_First_Name__c= 'FirstEMAIL',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.1, Phone2Action_Email__c = 'emailA1@gmail.com',
                Phone2Action_Email_Bad__c = TRUE, P2A__Phone2Action_Email_Optin__c = TRUE, Phone2Action_Email2__c = 'emailA2@gmail.com',
                Phone2Action_Email2_Bad__c = TRUE, Phone2Action_Email2_Optin__c = TRUE, Phone2Action_Email3__c = NULL,
                Phone2Action_Email3_Bad__c = TRUE, Phone2Action_Email3_Optin__c = TRUE, Phone2Action_Email4__c = 'emailA4@gmail.com',
                Phone2Action_Email4_Bad__c = TRUE, Phone2Action_Email4_Optin__c = TRUE);
        	conList.add(conOne);
    
    		Contact conTwo = new Contact (
            	LastName = 'Last1320B', Phone2Action_Last_Name__c= NULL, Phone2Action_First_Name__c= 'FirstEMAIL',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.2, Phone2Action_Email__c = 'emailB1@gmail.com',
                Phone2Action_Email_Bad__c = FALSE, P2A__Phone2Action_Email_Optin__c = FALSE, Phone2Action_Email2__c = 'emailB2@gmail.com',
                Phone2Action_Email2_Bad__c = FALSE, Phone2Action_Email2_Optin__c = FALSE, Phone2Action_Email3__c = NULL,
                Phone2Action_Email3_Bad__c = FALSE, Phone2Action_Email3_Optin__c = FALSE, Phone2Action_Email4__c = 'emailB4@gmail.com',
                Phone2Action_Email4_Bad__c = FALSE, Phone2Action_Email4_Optin__c = FALSE);
        	conList.add(conTwo);

    		Contact conThree = new Contact (
            	LastName = 'Last1320C', Phone2Action_Last_Name__c= NULL, Phone2Action_First_Name__c= 'FirstEMAIL',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.3, Phone2Action_Email__c = 'emailC1@gmail.com',
                Phone2Action_Email_Bad__c = TRUE, P2A__Phone2Action_Email_Optin__c = FALSE, Phone2Action_Email2__c = 'emailC2@gmail.com',
                Phone2Action_Email2_Bad__c = TRUE, Phone2Action_Email2_Optin__c = FALSE, Phone2Action_Email3__c = NULL,
                Phone2Action_Email3_Bad__c = TRUE, Phone2Action_Email3_Optin__c = FALSE, Phone2Action_Email4__c = 'emailC4@gmail.com',
                Phone2Action_Email4_Bad__c = TRUE, Phone2Action_Email4_Optin__c = FALSE);
        	conList.add(conThree);

    		Contact conFour = new Contact (
            	LastName = 'Last1320D', Phone2Action_Last_Name__c= NULL, Phone2Action_First_Name__c= 'FirstEMAIL',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.4, Phone2Action_Email__c = 'emailD1@gmail.com',
                Phone2Action_Email_Bad__c = FALSE, P2A__Phone2Action_Email_Optin__c = TRUE, Phone2Action_Email2__c = 'emailD2@gmail.com',
                Phone2Action_Email2_Bad__c = FALSE, Phone2Action_Email2_Optin__c = TRUE, Phone2Action_Email3__c = NULL,
                Phone2Action_Email3_Bad__c = FALSE, Phone2Action_Email3_Optin__c = TRUE, Phone2Action_Email4__c = 'emailD4@gmail.com',
                Phone2Action_Email4_Bad__c = FALSE, Phone2Action_Email4_Optin__c = TRUE);
        	conList.add(conFour);

    		Contact conFive = new Contact (
            	LastName = 'Last1320E', Phone2Action_Last_Name__c= NULL, Phone2Action_First_Name__c= 'FirstEMAIL',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.5, Phone2Action_Email__c = 'emailE1@gmail.com',
                Phone2Action_Email_Bad__c = TRUE, P2A__Phone2Action_Email_Optin__c = TRUE, Phone2Action_Email2__c = 'emailE2@gmail.com',
                Phone2Action_Email2_Bad__c = TRUE, Phone2Action_Email2_Optin__c = TRUE, Phone2Action_Email3__c = NULL,
                Phone2Action_Email3_Bad__c = FALSE, Phone2Action_Email3_Optin__c = FALSE, Phone2Action_Email4__c = 'emailE4@gmail.com',
                Phone2Action_Email4_Bad__c = FALSE, Phone2Action_Email4_Optin__c = FALSE);
        	conList.add(conFive);

    		Contact conSix = new Contact (
            	LastName = 'Last1320F', Phone2Action_Last_Name__c= NULL, Phone2Action_First_Name__c= 'FirstEMAIL',
            	OwnerID = '0050b0000060Uys', P2A__Advocate_ID__c = 1234567898.6, Phone2Action_Email__c = 'emailF1@gmail.com',
                Phone2Action_Email_Bad__c = FALSE, P2A__Phone2Action_Email_Optin__c = FALSE, Phone2Action_Email2__c = 'emailF2@gmail.com',
                Phone2Action_Email2_Bad__c = FALSE, Phone2Action_Email2_Optin__c = FALSE, Phone2Action_Email3__c = NULL,
                Phone2Action_Email3_Bad__c = TRUE, Phone2Action_Email3_Optin__c = TRUE, Phone2Action_Email4__c = 'emailF4@gmail.com',
                Phone2Action_Email4_Bad__c = TRUE, Phone2Action_Email4_Optin__c = TRUE);
        	conList.add(conSix);
    
    insert conList;
    
		}

static testmethod void test() {
        Test.startTest();
        SetP2AContactPersonEmail spcn = new SetP2AContactPersonEmail();
        Id batchId = Database.executeBatch(spcn);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(6, [select count()from contact where Phone2Action_First_Name__c ='FirstEMAIL']);
}   
}