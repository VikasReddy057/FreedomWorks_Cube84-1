@isTest
public class ContactTriggerTest {
@TestSetup
static void initData()
{

}
    @isTest static void testContactInsert() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        List<contact> conList = new List<Contact>(); // Add_to_MarketLists__c  ,  Add_To_Prospect_List__c
        Contact contact = new Contact(Add_to_MarketLists__c=campaign.Id ,LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        Contact contact2 = new Contact(LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        conList.add(contact );
        conList.add(contact2 );
        
        Test.StartTest();
  
        
        insert conList;
        ContactDonationStatusBatch.updateContacts(String.valueof(conList[0].Id));
        test.stopTest();
        }
    @isTest static void testDeleteContact() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        List<contact> conList = new List<Contact>();
        Contact contact = new Contact(LastName='abc',Add_to_MarketLists__c=campaign.Id , recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        Contact contact2 = new Contact(LastName='abc',Add_To_Prospect_List__c=true, recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        conList.add(contact );
        conList.add(contact2 );
        
        Test.StartTest();

            
        insert conList;
        //ContactDonationStatusBatch.updateContacts(String.valueof(conList[0].Id));
        for(contact cn: conList)
            cn.npo02__LastCloseDate__c = System.today().addDays(-1);
         
        update conList;
        String sch = '0 0 23 * * ?'; 
        system.schedule('test', sch, new ContactDonationStatusBatch()); 
        PostupUpdateContactQueueBatch.method1();
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp'+'/recipient/' + (Integer)contact.recipientId__c, 'UpdateRecipient');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c, 'GetListSubscription');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
                delete contact;
        Test.StopTest(); 
    }
    @isTest static void testDeleteContactCampaign() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        Test.StartTest();
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        Contact contact = new Contact(LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        insert contact;
        CampaignMember member = new CampaignMember(campaignId=campaign.Id, contactId=contact.id);
        insert member;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp'+'/recipient/' + (Integer)contact.recipientId__c, 'UpdateRecipient');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c, 'GetListSubscription');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        
        delete contact;
        Test.StopTest(); 
    }
    @isTest static void testDeleteContactCampaignMasterContact() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
           
        insert mapFieldAddress;
        insert mapFieldExternalId;

        
        Contact contact = new Contact(LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        //insert contact;
        Contact contact2 = new Contact(LastName='cde', recipientId__c=321,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        //insert contact2;
        Contact contact3 = new Contact(LastName='cde', recipientId__c=321,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        //insert contact3;
        Contact[] contact1 = new List<Contact>();
        contact1.add(contact2);
        contact1.add(contact);
        contact1.add(contact3);
        
        insert contact1;
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        List<CampaignMember> cmpList = new List<CampaignMember>();
        CampaignMember member1 = new CampaignMember(campaignId=campaign.Id, contactId=contact1[0].id);
        CampaignMember member2 = new CampaignMember(campaignId=campaign.Id, contactId=contact1[1].id);
        cmpList.add(member1 );
        cmpList.add(member2 );
        insert cmpList;
        Test.startTest();
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp'+'/recipient/' + (Integer)contact.recipientId__c, 'UpdateRecipient');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c, 'GetListSubscription');
        mock.setStatusCode(200);
        
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        
        //delete contact;
        Database.MergeResult[] results = Database.merge(contact, contact1, false);
        Test.StopTest(); 
    }
    @isTest static void testUpdateContact() {
    Test.StartTest();
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        Contact contact = new Contact(LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        insert contact;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp'+'/recipient/' + (Integer)contact.recipientId__c, 'UpdateRecipient');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c, 'GetListSubscription');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        
        update contact;
        Test.StopTest(); 
    }
        @isTest static void testMassUpdateContact() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(FieldName__c = 'Address', SfField__c = 'Email', SalesforceField__c = 'Email', PostUp_Table__c='Recipients');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(FieldName__c = 'ExternalId', SfField__c = 'Id', SalesforceField__c = 'Id', PostUp_Table__c='Standard Field');
        PostUpFieldMap__c mapMiddleName = new PostUpFieldMap__c(FieldName__c = 'Middle Name', SfField__c = 'OwnerId', SalesforceField__c = 'Owner.Name', PostUp_Table__c='Standard Field');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=110);
        insert campaign;
        list<Contact> conList = new list<Contact>();
        Contact contact = new Contact(LastName='abc', recipientId__c=123,npe01__HomeEmail__c='test@test.com',npe01__WorkPhone__c='1234567890');
        conList.add(contact);
              Contact contact2 = new Contact(LastName='abc', recipientId__c=123);
        conList.add(contact2);
        Insert conList;
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:PostUp/list', 'GetAllPostUpList');
        mock.setStaticResource('callout:PostUp/recipient', 'CreateRecipient');
        mock.setStaticResource('callout:PostUp'+'/listsubscription', 'SubscribeAListByRecipient');
        mock.setStaticResource('callout:PostUp/brand', 'GetPostUpBrand');
        mock.setStaticResource('callout:PostUp'+'/recipient/' + (Integer)contact.recipientId__c, 'UpdateRecipient');
        mock.setStaticResource('callout:PostUp/list/'+campaign.ListId__c, 'CreatePostUpList');
        mock.setStaticResource('callout:PostUp'+'/listsubscription?listid='+campaign.ListId__c, 'GetListSubscription');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        ContactTriggerHandler.isInsert = false;
        ContactTriggerHandler.afterUpdateFirstRun = true;
        ContactTriggerHandler.beforeUpdateFirstRun = true;

            for(Contact con: conList)
        con.Add_to_MarketLists__c=campaign.Id ;   
        update conList;
        Test.StopTest(); 
    }
}