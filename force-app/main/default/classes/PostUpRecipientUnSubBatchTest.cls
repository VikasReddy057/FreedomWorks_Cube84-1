@isTest
public class PostUpRecipientUnSubBatchTest {
    public static TestMethod void test() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        Contact contact = new Contact(LastName='abc', recipientId__c=123);
        insert contact;
        CampaignMember member = new CampaignMember(campaignId=campaign.Id, contactId=contact.id);
        insert member; 
        CampaignMember[] memberList = new List<CampaignMember>();
        memberList.add(member);
        Set<Id> ids = new Set<Id>();
        ids.add(member.id);
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c, 'GetListSubscription');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.startTest();
        Database.executeBatch(new PostUpRecipientUnSubBatch('Unsubscribed', ids,  memberList), 20);
        Test.stopTest();
    }
}