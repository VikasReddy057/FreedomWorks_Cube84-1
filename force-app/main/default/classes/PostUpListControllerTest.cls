@isTest
public class PostUpListControllerTest {
	    @isTest static void testCreateList() {
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
        	PostUpListController.createList(campaign.Name, campaign.id, 'NORMAL');
        Test.StopTest();
    }
    @isTest static void testGetAllPostUpList() {
        Campaign campaign = new Campaign(name='test');
        insert campaign;
        campaign.sync_with_postup__c = true;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        PostUpListController.getAllPostUpList(campaign.Name);
        Test.StopTest();
    }
    @isTest static void testUpdatePostUpList() {
        Campaign campaign = new Campaign(name='Test for');
        insert campaign;
        campaign.sync_with_postup__c = true;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list/'+(Integer)campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        PostUpListController.updatePostUpList((Integer)campaign.ListId__c ,campaign.Name, campaign.id, 'NORMAL');
        Test.StopTest();
    }
}