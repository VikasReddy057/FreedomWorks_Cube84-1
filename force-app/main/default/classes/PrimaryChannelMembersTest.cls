@isTest
public class PrimaryChannelMembersTest {

    @isTest
    private static void metthod1(){
        Account acc= new Account(name='One');
        Insert acc;
        
        Contact contact2 = new Contact(AccountId=acc.Id,LastName='cde',npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        insert contact2;        
        Primary_Channels__c pc = new Primary_Channels__c(Account__c=contact2.AccountId,ExternalId__c=contact2.AccountId);
        insert pc;
        Primary_Channel_Members__c pcm = new Primary_Channel_Members__c(Account__c=contact2.AccountId,External_Member_Id__c= String.valueOf(contact2.AccountId)+'3',
                                                                       PC_Order__c='3',count__c=3,dummy_Count__c=1,
                                                                       PrimaryChannelId__c=pc.Id);
        insert pcm;
        
        
    }
}