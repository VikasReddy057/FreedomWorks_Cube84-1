@isTest
public class PostUpContactRecipientSchedulerTest {

    @isTest
    public static void method1(){

        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=123);
        insert campaign;
        Contact contact = new Contact(lastName = 'abc', recipientId__c=320);
        insert contact;
        CampaignMember member = new CampaignMember();
        member.CampaignId = campaign.Id;
        member.ContactId = contact.Id;
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
        PostUpContactRecipientUpdateScheduler sh1 = new PostUpContactRecipientUpdateScheduler();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('PostUpContactRecipientUpdateScheduler', sch, sh1); 
        Test.StopTest();
        
        
        
    }
    @isTest
    public static void method2(){

        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=123);
        insert campaign;
        Contact contact = new Contact(lastName = 'abc', recipientId__c=896423);
        insert contact;
        CampaignMember member = new CampaignMember();
        member.CampaignId = campaign.Id;
        member.ContactId = contact.Id;
  
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
        System.debug([Select id from Postup_Contact_Log__c]);
        PostUpContactRecipientUpdateScheduler sh1 = new PostUpContactRecipientUpdateScheduler();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('PostUpContactRecipientUpdateScheduler', sch, sh1); 
        Test.StopTest();
        
        
        
    }
}