/*
* Get Sync With PostUp Campaigns (recipientId is not null) and ListIds from Campaigns
*
* To Process on each ListId pass ListId to PostUpSubscriptionControllerQueue
*
*/ 
public class PostUpSubscriptionQueue implements Queueable, Database.AllowsCallouts{
    
    Set<Integer> listIdList;
    Integer listId;
    
    public PostUpSubscriptionQueue(Integer listId, set<Integer> listIdList) {
        System.debug('PostUpSubscriptionQueue Parameterized Constructor');
        System.debug('PostUpSubscriptionQueue Parameterized Constructor listId and listIdList are ' + listId + listIdList);
        this.listId = listId;
        this.listIdList = listIdList;
    }
    
    public PostUpSubscriptionQueue() {
        System.debug('PostUpSubscriptionQueue Non-Parameterized Constructor');
    }
    
    public void execute(QueueableContext qc) {
        System.debug('PostUpSubscriptionQueue : execute');
        if(listIdList == null) {
            listIdList = new Set<Integer>();
            for(Campaign syncedCampaign : [select id, Name, ListId__c from Campaign where sync_with_postup__c = true AND ListId__c != null]) {
                System.debug('syncedCampaign = ' + syncedCampaign);
                if(!([select id, name from CampaignMember where campaignId =: syncedCampaign.id AND recipientId__c != null AND PostUp_Status__c != null limit 5]).isEmpty()) {
                    listIdList.add((Integer)syncedCampaign.ListId__c);
                }
            }
        }
        System.debug('listIdList = ' + listIdList);
        if(!listIdList.isEmpty()){
            System.enqueueJob(new PostUpSubscriptionControllerQueue(new List<Integer>(listIdList)[0], 0, listIdList));
        }
    }   
}