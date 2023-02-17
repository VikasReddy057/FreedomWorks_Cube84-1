/*
 * To Update PostUp Subscription Status for Recipient (CampaignMember) along postUpCronModifiedTime__c in Salesforce if Status is updated in PostUp Recipient 
 * 
 * This Batch Job is get called from PostUpSubscriptionControllerQueue for each 2000 records from API
 * 
 * In finish() method, after processing all the records to get another 2000 records calling PostUpSubscriptionControllerQueue to do recursion
 * 
 */

global class PostUpSubscriptionControllerBatch implements Database.Batchable<Sobject>, Database.AllowsCallouts{
    
    public static PostUpFieldMap__c addressFields = [select FieldName__c, PostUp_Field_Type__c, SfField__c, SalesforceField__c from PostUpFieldMap__c where SfField__c !=: null And SalesforceField__c !=: null AND FieldName__c='address' limit 1];
    Integer listId;
    Map<Integer, Map<Integer, PostUpListSubscriptionModel>> postUpListSubscriptionMap;
    List<Integer> recipientList;
    Integer lastRecipientId;
    Set<Integer> listIdList;
    
    public PostUpSubscriptionControllerBatch(Integer listId, Map<Integer, Map<Integer, PostUpListSubscriptionModel>> postUpListSubscriptionMap, List<Integer> recipientList, Integer lastRecipientId, Set<Integer> listIdList) {
        System.debug('PostUpSubscriptionControllerBatch Constructor and listId = '+ listId);
        this.listId= listId;
        this.postUpListSubscriptionMap = postUpListSubscriptionMap;
        this.recipientList =recipientList;
        this.lastRecipientId = lastRecipientId;
        this.listIdList = listIdList;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        System.debug(listId);
        System.debug(recipientList);
        String soqlQuery= 'Select id, leadId, Contact.Id, contact.'+addressFields.SalesforceField__c+', PostUp_Status__c, recipientId__c, Campaign.id, Campaign.Name, Campaign.sync_with_postup__c, Campaign.ListId__c, Campaign.IsActive from CampaignMember where Campaign.ListId__c =: listId AND recipientId__c in :recipientList';
        return database.getquerylocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<CampaignMember> scope){
        System.debug('PostUpSubscriptionControllerBatch : execute');
        set<CampaignMember> memberSet = new set<CampaignMember>();
        for(CampaignMember member: scope) {
            System.debug('CampaignMember in PostUpListSubscriptionModel(in PostUp) is '+postUpListSubscriptionMap.get((Integer)member.campaign.ListId__c).get((Integer)member.recipientId__c));
            PostUpListSubscriptionModel model = postUpListSubscriptionMap.get((Integer)member.campaign.ListId__c).get((Integer)member.recipientId__c);
            if(member.recipientId__c == model.recipientId && member.PostUp_Status__c != model.status) {
                System.debug('Subscription Changed Recipient is ' + member.recipientId__c + ' and Status is ' + model.status + ' and Modified at ' + model.modifiedTime);
                member.PostUp_Status__c = model.status;
                member.postUpCronModifiedTime__c = model.modifiedTime;
                member.Dummy_lastModifiedDate__c = String.valueof(System.now());
                memberSet.add(member);
            }
        }
        List<CampaignMember> memberList = new List<CampaignMember>(memberSet);
        if(memberList .size()>0)
        createStatusRecord(memberList );
        //update memberList;
    }
    
    Public void finish(Database.BatchableContext bc){
        System.enqueueJob(new PostUpSubscriptionControllerQueue(listId, lastRecipientId, listIdList));
    }
    
    public static void createStatusRecord(List<CampaignMember> cmpList){
    
    List<Campaign_Status__c> stList = new List<Campaign_Status__c>();
        for(CampaignMember cm: cmpList){
            Campaign_Status__c record = new Campaign_Status__c();
            record.CampaignId__c = cm.Id;
            record.Status__c= cm.PostUp_Status__c ;
            record.CronDateTime__c = cm.postUpCronModifiedTime__c;
            stList .add(record);    
        }
        if(stList.size()>0)
        Upsert  stList CampaignId__c;
    }
}