@isTest
private class HouseHoldAccountSchedulerTest {
	@isTest
    public static void method1(){
        String  householdTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId();        
        Date dt = system.today();
        dt = dt.addMonths(-60);
        Account acc = new Account(name = 'test',Is_LastGift_5_years_old__c= false,npo02__LastCloseDate__c = dt,
                                 recordtypeId=householdTypeId);
        Insert acc;
        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new HouseHoldAccountScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }
}