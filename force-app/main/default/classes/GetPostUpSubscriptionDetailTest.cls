@isTest
public class GetPostUpSubscriptionDetailTest {
    @isTest static void testExecute() {
        PostUpFieldMap__c postUpCron = new PostUpFieldMap__c(PostUp_Cron_Time__c = 1, name ='Cron Time');
        insert postUpCron;
		Test.startTest();
        GetPostUpSubscriptionDetail getPostUpSubscriptionDetail = new GetPostUpSubscriptionDetail();
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, getPostUpSubscriptionDetail);
        Test.StopTest();        
    }
}