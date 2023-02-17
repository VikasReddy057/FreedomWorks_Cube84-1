@isTest
public class UpdateContactsTest {

    @isTest
    Static void Method1(){
        test.startTest();
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=false);
        insert campaign;
        Contact contact = new Contact(lastName = 'abc', recipientId__c=321,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        insert contact;
        CampaignMember member = new CampaignMember(CampaignId =campaign.id ,ContactId = contact.id);
        Insert member;
        
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().addMinutes(2).minute()); //+ 10
        String ss = String.valueOf(Datetime.now().second());
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        System.schedule('test' , nextFireTime, new UpdateContacts() );        
        test.stopTest();
    }
}