global class PostUpListBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    String listTitle;
    String camId; 
    String postUpStatus;
    Integer listId;
    Boolean isUpdation;
    
    Set<Id> ids = new set<Id>();
    
    global PostUpListBatch(String listTitle, String camId, String postUpStatus, Boolean isUpdation, Integer listId) {
        this.listTitle = listTitle;
        this.camId = camId;
        this.postUpStatus = postUpStatus;
        this.isUpdation = isUpdation;
        this.listId = listId;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        //String soqlQuery = 'Select id, leadId, Contact.Id, PostUp_Status__c, recipientId__c, Campaign.id, Campaign.Name, Campaign.sync_with_postup__c, Campaign.ListId__c, Campaign.IsActive from CampaignMember where id in :ids AND campaign.id=:campaignId AND LeadId=Null';
        String soqlQuery = 'Select id from Campaign where Id =: camId';
        
        return database.getquerylocator(soqlQuery);
        //return members;
    }
    
    global void execute(Database.BatchableContext bc, List<Campaign> scope){
        for(Campaign campaign: scope){
            if(!isUpdation) {
                System.debug('IS Update false');
                if(!Test.isRunningTest()) 
                    listId = PostUpListController.createListFuture(listTitle, campaign.Id, postUpStatus);    
            }
            else {
                System.debug('IS Update true');
                PostUpListController.updatePostUpListImplementation(listId, listTitle, campaign.Id, postUpStatus);
                listId = listId;
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('campaignId='+camId);
        //Database.executeBatch(new PostUpRecipientCreationBatch(camId), 200);
    }
}