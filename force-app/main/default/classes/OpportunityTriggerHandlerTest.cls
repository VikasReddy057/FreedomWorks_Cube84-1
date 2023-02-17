@isTest
public class OpportunityTriggerHandlerTest {
    
    @isTest
    Static void method1(){
      Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110,Produced_By__c='Righters Group');
        insert campaign;
        Account acc = new Account (name='test',OwnerId=[Select Id from user where caseLoad__c=true limit 1].Id);
        insert acc;
                Account acc2 = new Account (name='test');
        insert acc2;
        List<contact> conList = new List<Contact>(); // Add_to_MarketLists__c  ,  Add_To_Prospect_List__c
        Contact contact = new Contact(AccountId=acc.Id, Add_to_MarketLists__c=campaign.Id ,LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        Contact contact2 = new Contact(AccountId=acc2.Id,LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        conList.add(contact );
        conList.add(contact2 );

        Test.StartTest();
  
        
        insert conList;
        Opportunity opp1= new Opportunity(AccountId=acc.Id, amount=500,stageName='Posted',Name='test',
                                          Designated_Organization__c='FreedomWorks Foundation',CampaignId=campaign.Id,
                                         closeDate= System.today());        
        Insert opp1;
        Opportunity opp2= new Opportunity(AccountId=acc2.Id, amount=500,stageName='Posted',Name='test',
                                  Designated_Organization__c='FreedomWorks Foundation',
                                 closeDate= System.today());        
        Insert opp2;
        Opportunity opp3= new Opportunity(AccountId=acc.Id, amount=5000,stageName='Posted',Name='test',
                          Designated_Organization__c='FreedomWorks Foundation',
                         closeDate= System.today());        
        Insert opp3;
        test.stopTest();    
  
    }
 @isTest
    Static void method2(){
        String rectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Foundation').getRecordTypeId();
        Account acc = new Account (name='test',recordTypeId=rectypeId);
        insert acc;
        List<contact> conList = new List<Contact>(); // Add_to_MarketLists__c  ,  Add_To_Prospect_List__c
        Contact contact = new Contact(AccountId=acc.Id,LastName='abc', npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        Contact contact2 = new Contact(AccountId=acc.Id,LastName='abc',npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        conList.add(contact );
        conList.add(contact2 );

        Test.StartTest();
  
        
        insert conList;
        
        List<Opportunity> oppList = new List<Opportunity>();
          
        Opportunity opp1= new Opportunity(AccountId=acc.Id, amount=500,stageName='Posted',Name='test',
                                          Designated_Organization__c='FreedomWorks Foundation',
                                         closeDate= System.today());        
        oppList.add(opp1);
        Opportunity opp2= new Opportunity(AccountId=acc.Id, amount=500,stageName='Posted',Name='test',
                                  Designated_Organization__c='FreedomWorks Foundation', 
                                 closeDate= System.today());        
        oppList.add(opp2);
        Opportunity opp3= new Opportunity(AccountId=acc.Id, amount=5000,stageName='Posted',Name='test',
                          Designated_Organization__c='FreedomWorks Foundation',
                         closeDate= System.today());        
        oppList.add(opp3);
        Insert oppList;
        test.stopTest();    
        
          
    }
 @isTest
    Static void method3(){
        String rectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporation').getRecordTypeId();
        Account acc = new Account (name='test',recordTypeId=rectypeId,OwnerId=[Select Id from user where caseLoad__c=true limit 1].Id);
        insert acc;
        List<contact> conList = new List<Contact>(); // Add_to_MarketLists__c  ,  Add_To_Prospect_List__c
        Contact contact = new Contact(AccountId=acc.Id,LastName='abc', npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        Contact contact2 = new Contact(AccountId=acc.Id,LastName='abc',npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        conList.add(contact );
        conList.add(contact2 );

        Test.StartTest();
  
        
        insert conList;
        
        List<Opportunity> oppList = new List<Opportunity>();
          
        Opportunity opp1= new Opportunity(AccountId=acc.Id, amount=500,stageName='Posted',Name='test',
                                          Designated_Organization__c='FreedomWorks Foundation',
                                         closeDate= System.today());        
        oppList.add(opp1);
        Opportunity opp2= new Opportunity(AccountId=acc.Id, amount=500,stageName='Posted',Name='test',
                                  Designated_Organization__c='FreedomWorks Foundation', 
                                 closeDate= System.today());        
        oppList.add(opp2);
        Opportunity opp3= new Opportunity(AccountId=acc.Id, amount=5000,stageName='Posted',Name='test',
                          Designated_Organization__c='FreedomWorks Foundation',
                         closeDate= System.today());        
        oppList.add(opp3);
        Insert oppList;
        test.stopTest();    
        
          
    }
    @isTest
    Static void method4(){
        String rectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporation').getRecordTypeId();
        Account acc = new Account (name='test',recordTypeId=rectypeId,OwnerId=[Select Id from user where caseLoad__c=true limit 1].Id);
        insert acc;
                Account acc2 = new Account (name='test',recordTypeId=rectypeId);
        insert acc2;
        List<contact> conList = new List<Contact>(); // Add_to_MarketLists__c  ,  Add_To_Prospect_List__c
        Contact contact = new Contact(AccountId=acc.Id,LastName='abc', npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        Contact contact2 = new Contact(AccountId=acc2.Id,LastName='abc',npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        conList.add(contact );
        conList.add(contact2 );

        Test.StartTest();
  
        
        insert conList;
        
        List<Opportunity> oppList = new List<Opportunity>();
          
        Opportunity opp1= new Opportunity(AccountId=acc.Id, amount=500,stageName='Posted',Name='test',
                                          Designated_Organization__c='FreedomWorks Foundation',
                                         closeDate= System.today());        
        oppList.add(opp1);
        Opportunity opp2= new Opportunity(AccountId=acc2.Id, amount=500,stageName='Posted',Name='test',
                                  Designated_Organization__c='FreedomWorks Foundation', 
                                 closeDate= System.today());        
        oppList.add(opp2);
        Opportunity opp3= new Opportunity(AccountId=acc.Id, amount=5000,stageName='Posted',Name='test',
                          Designated_Organization__c='FreedomWorks Foundation',
                         closeDate= System.today());        
        oppList.add(opp3);
        Insert oppList;
        test.stopTest();    
        
          
    }
}