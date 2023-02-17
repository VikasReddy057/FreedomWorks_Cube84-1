@isTest
public class LeadTriggerTest {

    @isTest
    Static void method1(){
    
        Lead ld = new Lead(LastName='test',Email='test@test.com',Company='test',Add_To_Prospect__c=true);
            Insert ld;
        ld.Add_To_Prospect__c = true;
            update ld;
            
        
    }
}