global class CampaignDeletionBatch implements Database.Batchable<Campaign>, Database.AllowsCallouts{
    List<Campaign> campaigns;
    global CampaignDeletionBatch(List<Campaign> campaigns) {
        this.campaigns = campaigns;
    }
	global Iterable<Campaign> start(Database.BatchableContext bc){
        return campaigns;
    }
     
    global void execute(Database.BatchableContext bc, List<Campaign> scope){
        System.debug('execute');
        for(Campaign campaign: scope){
			PostUpListController.updatePostUpListImplementation((Integer)campaign.ListId__c, 'ARCHIVED | ' + campaign.Name + ' | ' + campaign.Id, campaign.Id, 'NORMAL');
        } 
    }
     
    Public void finish(Database.BatchableContext bc){ 
    }
}