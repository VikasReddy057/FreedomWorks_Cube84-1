/*
* To Update PostUp RecipientId and Subscription Status (CampaignMember) based on address in Salesforce if mail in SF is matched with address in PostUp Recipient 
* 
* This Batch Job is get called from RecipientSubscriptionControllerQueue for each 2000 records from API
* 
* In finish() method, after processing all the records to get another 2000 records calling RecipientSubscriptionControllerQueue to do recursion
* 
*/

global class RecipientSubscriptionControllerBatch implements Database.Batchable<Sobject>, Database.AllowsCallouts{
    
    public static PostUpFieldMap__c addressFields = [select FieldName__c, PostUp_Field_Type__c, SfField__c, SalesforceField__c from PostUpFieldMap__c where SfField__c !=: null And SalesforceField__c !=: null AND FieldName__c='address' limit 1];
    Integer listId;
    Map<Integer, Map<String, PostUpListSubscriptionModel>> recipientMap;
    List<String> mailList;
    Integer lastRecipientId;
    
    public RecipientSubscriptionControllerBatch(Integer listId, Map<Integer, Map<String, PostUpListSubscriptionModel>> recipientMap, List<String> mailList, Integer lastRecipientId) {
        System.debug('RecipientSubscriptionControllerBatch Constructor and listId = ' + listId);
        this.listId= listId;
        this.recipientMap = recipientMap;
        this.mailList =mailList;
        this.lastRecipientId = lastRecipientId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery= 'Select id, leadId, Contact.Id, contact.'+addressFields.SalesforceField__c+', PostUp_Status__c, recipientId__c, Campaign.id, Campaign.Name, Campaign.sync_with_postup__c, Campaign.ListId__c, Campaign.IsActive from CampaignMember where Campaign.ListId__c =: listId AND recipientId__c=null AND contact.'+addressFields.SalesforceField__c+' in: mailList';
        return database.getquerylocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<CampaignMember> scope){
        System.debug('RecipientSubscriptionControllerBatch : execute');
        set<CampaignMember> memberSet = new set<CampaignMember>();
        set<Contact> contactSet = new set<Contact>();
        for(CampaignMember member: scope) {
            System.debug('email=='+member.contact.get(addressFields.SalesforceField__c));
            String email = (String)member.contact.get(addressFields.SalesforceField__c);
            System.debug('PostUpListSubscriptionModel = '+recipientMap.get((Integer)member.campaign.ListId__c).get(email));
            if(recipientMap.get((Integer)member.campaign.ListId__c).get(email) != null) {
                PostUpListSubscriptionModel model = recipientMap.get((Integer)member.campaign.ListId__c).get(email);
                member.recipientId__c = model.recipientId;
                member.contact.recipientId__c = model.recipientId;
                member.PostUp_Status__c = model.status;
                memberSet.add(member);
                contactSet.add(member.contact);
            }
        }
        List<CampaignMember> memberList = new List<CampaignMember>(memberSet);
        List<Contact> contactList = new List<Contact>(contactSet);
        update memberList;
        update contactList;
    } 
    
    Public void finish(Database.BatchableContext bc){
        System.enqueueJob(new RecipientSubscriptionControllerQueue(listId, lastRecipientId));
    }
}