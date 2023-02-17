global class PostUpRecipientUnSubBatch implements Database.Batchable<CampaignMember>, Database.AllowsCallouts{
    String listStatus;
    Set<ID> ids;
    List<CampaignMember> members;
    global PostUpRecipientUnSubBatch(String listStatus, Set<ID> ids, List<CampaignMember> members) {
        this.listStatus = listStatus; 
        this.ids = ids;
        this.members = members;
    }
	global Iterable<CampaignMember> start(Database.BatchableContext bc){
        System.debug('Start');
        System.debug('members= '+members);
        String soqlQuery = 'select id, leadId, ContactId, PostUp_Status__c, recipientId__c, Campaign.id, Campaign.Name, Campaign.sync_with_postup__c, Campaign.ListId__c, Campaign.IsActive from CampaignMember where id in :ids AND leadId = null AND recipientId__c!=null AND Campaign.sync_with_postup__c = true AND PostUp_Status__c = \'Subscribed\'';
        System.debug('database.getquerylocator(soqlQuery)= '+database.getquerylocator(soqlQuery));
        return members;
    }
     
    global void execute(Database.BatchableContext bc, List<CampaignMember> scope){
        System.debug('execute');
        for(CampaignMember member: scope){
            PostUpSubscriptionController.updateSubscription((Integer)member.campaign.ListId__c, (Integer)member.recipientId__c, listStatus);
        } 
    }
     
    Public void finish(Database.BatchableContext bc){ 
    }
}