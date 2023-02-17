@isTest
public class PrimaryChannelBatchTest {

    @isTest
    Static void method1(){
              Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110,Produced_By__c='Righters Group');
        insert campaign;
        Account acc = new Account (name='test');
        insert acc;
        List<contact> conList = new List<Contact>(); // Add_to_MarketLists__c  ,  Add_To_Prospect_List__c
        Contact contact = new Contact(AccountId=acc.Id, Add_to_MarketLists__c=campaign.Id ,LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        Contact contact2 = new Contact(AccountId=acc.Id,LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        conList.add(contact );
        conList.add(contact2 );
      

        Test.startTest();
         insert conList;
        Opportunity opp1= new Opportunity(AccountId=acc.Id, amount=100,stageName='Posted',Name='test',
                                          Designated_Organization__c='FreedomWorks Foundation',CampaignId=campaign.Id,
                                         closeDate= System.today());        
		Insert opp1;       
        Database.executeBatch(new PrimaryChannelBatch(false),1);
        PrimaryChannelBatch.DummyMethod();
        Test.stopTest();
    }
   

}