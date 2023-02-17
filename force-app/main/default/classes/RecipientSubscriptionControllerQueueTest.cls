@isTest
public class RecipientSubscriptionControllerQueueTest {
    public static TestMethod void test() {
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        insert mapFieldAddress;
        Set<Integer> listIdList = new Set<Integer>();
        Campaign cmp = new Campaign(name = 'test', listId__c = 238, sync_with_postup__c=true);
        insert cmp;
        Campaign[] cmpList = [select id, listId__c from Campaign where listId__c != null];
        for(Campaign c : cmpList) {
            listIdList.add((Integer) c.listId__c);
        }
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+272+'&limit=2000&lastrecipid='+0, 'EmptyList');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        	System.enqueueJob(new RecipientSubscriptionControllerQueue(272, 0));
        Test.StopTest();
    }
    
    public static TestMethod void testGetmailList() {
        String response = '[   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951328,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T15:28:47Z\",       \"address\": \"rdinesh5697@gmail.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951398,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:15Z\",       \"address\": \"dfhb@berijam.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951399,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:15Z\",       \"address\": \"dfhb@berijam.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951400,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:15Z\",       \"address\": \"dfhb@berijam.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951401,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:16Z\",       \"address\": \"dfhb@berijam.com\"   }]';
        Test.startTest();
        RecipientSubscriptionControllerQueue.getmailList(response);
        Test.stopTest();
    }
    
    public static TestMethod void testGetpostUpListSubscriptionMap() {
        String response = '[   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951328,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T15:28:47Z\",       \"address\": \"rdinesh5697@gmail.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951398,       \"status\": \"UNSUB\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:15Z\",       \"address\": \"dfhb@berijam.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951399,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:15Z\",       \"address\": \"dfhb@berijam.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951400,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:15Z\",       \"address\": \"dfhb@berijam.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951401,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:16Z\",       \"address\": \"dfhb@berijam.com\"   }]';
        Test.startTest();
        RecipientSubscriptionControllerQueue.getpostUpRecipientSubscriptionMap(response);
        Test.stopTest();
    }
}