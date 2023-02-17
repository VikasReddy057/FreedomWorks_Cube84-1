/*
* Get Sync With PostUp Campaigns (recipientId is null) and ListIds from Campaigns
*
* To Process on each ListId pass ListId to RecipientSubscriptionControllerQueue
*
*/ 
public class PostUpRecipientSubscriptionQueue implements Queueable, Database.AllowsCallouts{
   
    Set<Integer> listIdList = new Set<Integer>();
     
    public void execute(QueueableContext qc) {
        System.debug('PostUpRecipientSubscriptionQueue : execute');
        for(Campaign syncedCampaign : [select id, Name, ListId__c from Campaign where sync_with_postup__c = true AND ListId__c != null]) {
            System.debug('syncedCampaign = ' + syncedCampaign);
            if(!([select id, name from CampaignMember where campaignId =: syncedCampaign.id AND recipientId__c = null limit 5]).isEmpty()) {
                listIdList.add((Integer)syncedCampaign.ListId__c);
            }
        }
        System.debug('listIdList= ' + listIdList);
        if(!listIdList.isEmpty()){
            if(!Test.isRunningTest()) {
                System.enqueueJob(new RecipientSubscriptionControllerQueue(new List<Integer>(listIdList)[0], 0));   
            }
        }
    }
}