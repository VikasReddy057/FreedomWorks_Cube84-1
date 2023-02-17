global class PostUpRecipientCreationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    String camId;
    Set<Id> ids = new Set<Id>();
    global PostUpRecipientCreationBatch(String camId) {
        this.camId = camId;
        //this.ids = ids;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'select id, leadId, Contact.Id, PostUp_Status__c, recipientId__c, Campaign.id from CampaignMember where campaignId=:camId AND LeadId=Null AND recipientId__c=null';
        return database.getquerylocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<CampaignMember> scope){
        for(CampaignMember member : scope) {
            ids.add(member.id);
        }
        System.enqueueJob(new PostUpRecipientQueue(ids,'0', 0, 40)); 
    }
    global void finish(Database.BatchableContext bc){
         
    }
}