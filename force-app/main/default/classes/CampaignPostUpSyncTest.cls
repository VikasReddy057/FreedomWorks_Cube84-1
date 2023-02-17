@isTest
public class CampaignPostUpSyncTest {
    @isTest static void testCampaignPostUpSyncDeleteTrigger() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=123, isActive=true);
        insert campaign;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        delete campaign;
        Test.StopTest();
    }
    @isTest static void testCampaignPostUpSyncActiveTrigger() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=123, isActive=true);
        insert campaign;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        	update campaign;
        Test.StopTest();
    }
    @isTest static void testCampaignPostUpSyncTrigger() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=false);
        insert campaign;
        campaign.ListId__c = 123;
        update campaign;
    }
    @isTest static void testCampaignPostUpSyncTriggerSync() {
        Campaign campaign = new Campaign(name='test');
        insert campaign;
        campaign.sync_with_postup__c = true;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        	update campaign;
        Test.StopTest();
    }
}