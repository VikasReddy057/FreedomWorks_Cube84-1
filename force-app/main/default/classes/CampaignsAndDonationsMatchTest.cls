@istest
public class CampaignsAndDonationsMatchTest {

    @isTest
    public static void method1(){

        Id CampaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Cager Daily').getRecordTypeId();
        Id DirectMailId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Direct Mail Campaign').getRecordTypeId();

        Account acc= new Account(name='test' );
        insert acc;
        
        Contact con = new Contact(LastName='test',email='test@test.com',AccountId=acc.Id);
        Insert con;
        
        Opportunity opp = new Opportunity(name='test',AccountId=acc.Id, 
                                          npsp__Primary_Contact__c= con.Id,
                                          Designated_Organization__c='FreedomWorks, Inc.',
                                          Donation_Source__c='2',
                                          stageName='Received',
                                          CloseDate= System.today()
                                         );
        insert opp;
        
        Campaign cm1 = new Campaign(name='test1',recordtypeId=DirectMailId ,Source_Code__c='1');
        Insert cm1;
        Campaign cm2 = new Campaign(name='test2',recordtypeId=DirectMailId ,Source_Code__c='2',ParentId=cm1.Id);
        Insert cm2;
        Campaign cm3 = new Campaign(name='test3',recordtypeId=CampaignRecordTypeId ,Source_Code__c='2',ParentId=cm1.Id);
        Insert cm3; 
        
        List<string> cmpList = new List<string>{cm1.Source_Code__c,cm2.Source_Code__c,cm3.Source_Code__c}; 
        Test.StartTest();
        CampaignsAndDonationsMatch sh1 = new CampaignsAndDonationsMatch(cmpList);      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check2', sch, sh1);
        Test.stopTest();
        
    }
}