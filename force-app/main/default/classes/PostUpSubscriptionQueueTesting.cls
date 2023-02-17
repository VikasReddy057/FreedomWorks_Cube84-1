@isTest
public class PostUpSubscriptionQueueTesting {
    public static TestMethod void test() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        Contact contact = new Contact(LastName='abc');
        CampaignMember member = new CampaignMember(campaignId=campaign.id, contactId=contact.id);
        CampaignMember[] memberList = new List<CampaignMember>();
        memberList.add(member);
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c+'&limit=50', 'EmptyList');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.startTest();
        System.enqueueJob(new PostUpSubscriptionQueue());
        Test.stopTest();
    }
}