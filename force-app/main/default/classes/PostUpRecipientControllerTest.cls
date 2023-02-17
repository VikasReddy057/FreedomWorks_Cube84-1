@isTest
public class PostUpRecipientControllerTest {
    @isTest static void testCreateRecipientRequest() {
        Contact c = new Contact(LastName = 'abc', Email='abc123@gmail.com');
        insert c;
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        PostUpRecipientController.createRecipientRequest(c.id);
    }
    @isTest static void testCreateOneRecipient() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=123);
        insert campaign;
        Contact contact = new Contact(lastName = 'test', recipientId__c=123);
        insert contact;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.startTest();
        PostUpRecipientController.createOneRecipient(contact.Id, (Integer)campaign.ListId__c, 'NORMAL');
        Test.stopTest();
    }
    @isTest static void testUpdateRecipient() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=123);
        insert campaign;
        Contact contact = new Contact(lastName = 'test', recipientId__c=123);
        insert contact;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp/recipient/'+contact.recipientId__c, 'UpdateRecipient');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.startTest();
        PostUpRecipientController.updateRecipient(contact.Id, (Integer)contact.recipientId__c);
        PostUpRecipientController.updateRecipient2(contact.Id, (Integer)contact.recipientId__c);
        Test.stopTest();
    }
}