@isTest
public class CampaignMemberTriggerTest {

    @isTest static void testInsertCampaignMemberTrigger() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=123);
        insert campaign;
        Contact contact = new Contact(lastName = 'abc', recipientId__c=321,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        insert contact;
        CampaignMember member = new CampaignMember();
        member.CampaignId = campaign.Id;
        member.ContactId = contact.Id;
        member.recipientId__c = 321;
        member.PostUp_Status__c = 'Subscribed';
        
        
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp/recipient/'+contact.recipientId__c, 'UpdateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c, 'GetListSubscription');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
            insert member;
            Campaign_Status__c status = new Campaign_Status__c(CampaignId__c=member.Id,Status__c='Unsubscribed');
            insert status ;
            RecursiveHandler.CampaignMemberFirstRun = false;
            RecursiveHandler.CampaignMemberInsert = false;
            member.PostUp_Status__c = 'Unsubscribed';
            update member;
        Test.StopTest();
    }
    @isTest static void testInsertCampaignMemberTriggerIsActive() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=123, isActive=true);
        insert campaign;
        List<Contact> conList = new List<Contact>();
        
        Contact contact = new Contact(lastName = 'abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        conList.add(contact ); 
        Contact contact2 = new Contact(lastName = 'abc2', recipientId__c=1234,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        conList.add(contact2 ); 
        insert conList;
        List<CampaignMember > memberList = new List<CampaignMember>();
        CampaignMember member = new CampaignMember();
        member.CampaignId = campaign.Id;
        member.ContactId = conList[0].Id;
        member.PostUp_Status__c = 'Subscribed';
        member.recipientId__c = null;
        
        CampaignMember member2 = new CampaignMember();
        member2.CampaignId = campaign.Id;
        member2.ContactId = conList[1].Id;
        member2.PostUp_Status__c = 'Subscribed';
        member2.recipientId__c = null;
        Test.StartTest();
                memberList.add(member); 
        memberList.add(member2);
     insert memberList;
    Campaign_Status__c status = new Campaign_Status__c(CampaignId__c=memberList[0].Id,Status__c='Unsubscribed');
    insert status ;       
 
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp/recipient/'+contact.recipientId__c, 'UpdateRecipient');
          
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
      
 

        database.executeBatch( new PostUpRecipientQueueBatch(null,true),100 );                      
            RecursiveHandler.CampaignMemberFirstRun = false;
            RecursiveHandler.CampaignMemberInsert = false;
            memberList[0].PostUp_Status__c = 'Unsubscribed';
            memberList[0].recipientId__c=123;
            memberList[1].PostUp_Status__c = 'Unsubscribed';
            memberList[1].recipientId__c=123;
            update memberList;
        Test.StopTest();
    }
    @isTest static void testDeleteMemberTrigger() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110, isActive=true);
        insert campaign;
        Contact contact = new Contact(lastName = 'abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        insert contact;
        CampaignMember member = new CampaignMember();
        member.CampaignId = campaign.Id;
        member.ContactId = contact.Id;
        member.recipientId__c = 123;
        member.PostUp_Status__c = 'Subscribed';
         
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/recipient/'+member.recipientId__c, 'UpdateRecipient');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
            insert member;
            Campaign_Status__c status = new Campaign_Status__c(CampaignId__c=member.Id,Status__c='Unsubscribed');
            insert status ;             
            RecursiveHandler.CampaignMemberFirstRun = false;
            RecursiveHandler.CampaignMemberInsert = false;
            member.PostUp_Status__c = 'Unsubscribed';
            update member;
        Test.StopTest();
        delete member;
    }
    
    
}