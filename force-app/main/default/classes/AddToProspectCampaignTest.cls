@isTest
public class AddToProspectCampaignTest {

    @isTest
    Static void method1(){
        List<Add_To_Prospect_List__c> li = new List<Add_To_Prospect_List__c>();
        for(Integer i=0;i<1;i++){
            Id recordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Email Campaign').getRecordTypeId();
            Campaign cam = new Campaign(name='test',recordTypeId=recordTypeId);
            insert cam;
            Contact con1 = new Contact(LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
            Insert con1;
            Contact con2 = new Contact(LastName='abc', recipientId__c=111,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
            Insert con2;
            List<CampaignMember> cmList = new List<CampaignMember>();
            
            CampaignMember m = new Campaignmember(contactId=con1.Id,CampaignId=cam.Id,Status='Sent');  
            cmList.add(m);
            CampaignMember m2 = new Campaignmember(contactId=con2.Id,CampaignId=cam.Id,Status='Sent');  
            cmList.add(m2);
            li.add(new Add_To_Prospect_List__c(Members__c = JSON.serialize(cmList)));
            insert li;
            Database.executeBatch(new AddToProspectCampaign(),1);
        }
            
        
    }
}