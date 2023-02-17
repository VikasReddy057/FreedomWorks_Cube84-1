@isTest
public class PostUpSubscriptionControllerTest {
    @isTest static void testGetListSubscription() {
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
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+272+'&limit=2000&lastrecipid='+0, 'EmptyList');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        	PostUpSubscriptionController.getListSubscription(272, 0);
        Test.StopTest();
    } 
    @isTest static void testAddRecipientList() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        Contact contact = new Contact(LastName='abc');
        CampaignMember member = new CampaignMember(campaignId=campaign.id, contactId=contact.id, recipientId__c=123, status='Subscribed');
        CampaignMember[] memberList = new List<CampaignMember>();
        memberList.add(member);
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c+'&limit=50', 'GetListSubscription');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        String response = '[   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951328,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T15:28:47Z\",       \"address\": \"rdinesh5697@gmail.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951398,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:15Z\",       \"address\": \"dfhb@berijam.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951399,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:15Z\",       \"address\": \"dfhb@berijam.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951400,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:15Z\",       \"address\": \"dfhb@berijam.com\"   },   {       \"mailingId\": null,       \"listId\": 149,       \"recipientId\": 951401,       \"status\": \"NORMAL\",       \"confirmed\": false,       \"sourceId\": null,       \"dateUnsub\": null,       \"dateJoined\": \"2020-01-21T10:18:16Z\",       \"address\": \"dfhb@berijam.com\"   }]';
        Test.StartTest();
        //	PostUpSubscriptionController.addRecipientList(response, (Integer)campaign.ListId__c, campaign.id, memberList);
        Test.StopTest();
    }
    @isTest static void testGetAllListSubscription() {
        Test.startTest();
       // PostUpSubscriptionController.getAllListSubscription();
        Test.stopTest();
    }
    @isTest static void testUpdateSubscriptionExecutionSub() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        Contact contact = new Contact(LastName='abc');
        CampaignMember member = new CampaignMember(campaignId=campaign.id, contactId=contact.id, recipientId__c=1, PostUp_Status__c= 'Subscribed');
        CampaignMember[] memberList = new List<CampaignMember>();
        memberList.add(member);
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
        Test.StartTest();
        PostUpSubscriptionController.updateSubscriptionExecution((Integer) campaign.ListId__c, (Integer)member.recipientId__c, member.PostUp_Status__c);
        Test.StopTest();
    }
    @isTest static void testUpdateSubscriptionExecutionUnSub() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        Contact contact = new Contact(LastName='abc');
        CampaignMember member = new CampaignMember(campaignId=campaign.id, contactId=contact.id, recipientId__c=1, PostUp_Status__c= 'Unsubscribed');
        CampaignMember[] memberList = new List<CampaignMember>();
        memberList.add(member);
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
        Test.StartTest();
        PostUpSubscriptionController.updateSubscriptionExecution((Integer) campaign.ListId__c, (Integer)member.recipientId__c, member.PostUp_Status__c);
        Test.StopTest();
    }
    @isTest static void testUpdateSubscriptionFuture() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        Contact contact = new Contact(LastName='abc');
        CampaignMember member = new CampaignMember(campaignId=campaign.id, contactId=contact.id, recipientId__c=1, PostUp_Status__c= 'Unsubscribed');
        CampaignMember[] memberList = new List<CampaignMember>();
        memberList.add(member);
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
        Test.StartTest();
        PostUpSubscriptionController.updateSubscriptionImplementation((Integer) campaign.ListId__c, (Integer)member.recipientId__c, member.PostUp_Status__c);
        Test.StopTest();
    }
    @isTest static void testUpdateGlobalUnSub() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        Contact contact = new Contact(LastName='abc');
        CampaignMember member = new CampaignMember(campaignId=campaign.id, contactId=contact.id, recipientId__c=1, PostUp_Status__c= 'Unsubscribed');
        CampaignMember[] memberList = new List<CampaignMember>();
        memberList.add(member);
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp'+'/recipient/' + (Integer)member.recipientId__c, 'UpdateRecipient');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c, 'GetListSubscription');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        PostUpSubscriptionController.updateGlobalUnSub((Integer)member.recipientId__c);
        Test.StopTest();
    }
    @isTest static void testSubscribeList() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        Contact contact = new Contact(LastName='abc');
        CampaignMember member = new CampaignMember(campaignId=campaign.id, contactId=contact.id, recipientId__c=1, PostUp_Status__c= 'Unsubscribed');
        CampaignMember[] memberList = new List<CampaignMember>();
        memberList.add(member);
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp'+'/recipient/' + (Integer)member.recipientId__c, 'UpdateRecipient');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c, 'GetListSubscription');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        PostUpSubscriptionController.subscribeList((Integer)campaign.ListId__c, (Integer)member.recipientId__c, 'NORMAL');
        Test.StopTest();
    }
}