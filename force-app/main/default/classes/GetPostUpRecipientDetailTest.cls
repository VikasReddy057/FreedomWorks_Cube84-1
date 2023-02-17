@isTest
public class GetPostUpRecipientDetailTest {
    @isTest static void testExecute() {
        PostUpFieldMap__c addressField = new PostUpFieldMap__c(SfField__c='Email', SalesforceField__c='Email', FieldName__c='address');
        insert addressField;
        PostUpFieldMap__c postUpCron = new PostUpFieldMap__c(PostUp_Cron_Time__c = 1, name ='Cron Time');
        insert postUpCron;
        PostUpFieldMap__c postUpCronhr = new PostUpFieldMap__c(PostUp_Cron_Time__c = 1, name ='Cron Time Hr');
        insert postUpCronhr;
		Test.startTest();
        GetPostUpRecipientDetail getPostUpRecipientDetail = new GetPostUpRecipientDetail();
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, getPostUpRecipientDetail);
        Test.StopTest();        
    }
}