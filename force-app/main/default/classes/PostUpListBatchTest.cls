@isTest()
public class PostUpListBatchTest {
    public static TestMethod void test() {
        Campaign c = new Campaign(name = 'test', listId__c = 238, sync_with_postup__c=true);
        insert c;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list/'+(Integer)c.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.startTest();
        Database.executeBatch(new PostUpListBatch(c.Name, c.id, 'Subscribed', true, 238));   
        Test.stopTest();
    }
    public static TestMethod void testfalseupdate() {
        Campaign c = new Campaign(name = 'test', listId__c = 238, sync_with_postup__c=true);
        insert c;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list/'+(Integer)c.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.startTest();
        Database.executeBatch(new PostUpListBatch(c.Name, c.id, 'Subscribed', false, 238));   
        Test.stopTest();
    }
}