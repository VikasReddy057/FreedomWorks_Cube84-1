/*
* Call PostUp "listsubscription" API with 2000 limit
* 
* For each 2000 records calling RecipientSubscriptionControllerBatch Batch Class to do DML operation (update recipientId and PostupStatus based on address field in PostUp response) for non empty response
*  
* For Empty response, call PostUpRecipientSubscriptionQueue for recursive Process
* 
*/

public class RecipientSubscriptionControllerQueue implements Queueable, Database.AllowsCallouts {
    
    Integer listId;
    Integer lastRecipientId;
    
    public RecipientSubscriptionControllerQueue(Integer listId, Integer lastRecipientId) {
        System.debug('RecipientSubscriptionControllerQueue Constructor and values are listId = ' + listId + ' and lastRecipientId = ' + lastRecipientId);
        this.listId = listId;
        this.lastRecipientId = lastRecipientId;
    }
    public void execute(QueueableContext qc){
        System.debug('RecipientSubscriptionControllerQueue : execute');
        String response = '[]';
        if(!Test.isRunningTest()) {
            response = PostUpSubscriptionController.getListSubscription(listId, lastRecipientId);    
        }
        for(ListSubscriptionJson recipientDetail:ListSubscriptionJson.parseList(response)) {
            lastRecipientId = recipientDetail.recipientId;
        }
        if(response != '[]') {
            Map<String, PostUpListSubscriptionModel> mapStatus = getpostUpRecipientSubscriptionMap(response);
            Map<Integer, Map<String, PostUpListSubscriptionModel>> recipientMap = new Map<Integer, Map<String, PostUpListSubscriptionModel>>();
            recipientMap.put(listId, mapStatus);
            String[] mailList = getmailList(response);
            Database.executeBatch(new RecipientSubscriptionControllerBatch(listId, recipientMap, mailList, lastRecipientId)); 
        }
        else if(response == '[]') {
            if(!Test.isRunningTest()) {
                System.enqueueJob(new PostUpRecipientSubscriptionQueue());
            }
        }
        
    }
    
    // To get Map of PostUpSubscription detail from API response. Key - address and Value - PostUpListSubscriptionModel (RecipientId, Status, ModifiedTime)
    public static Map<String, PostUpListSubscriptionModel> getpostUpRecipientSubscriptionMap(String response) {
        System.debug('RecipientSubscriptionControllerQueue : getpostUpRecipientSubscriptionMap');
        Map<String, PostUpListSubscriptionModel> mapStatus = new Map<String, PostUpListSubscriptionModel>();
            if(response != '[]') {
                ListSubscriptionJson[] recipientSubscriptionList = ListSubscriptionJson.parseList(response);
                for(ListSubscriptionJson recipientSubscription : recipientSubscriptionList)  {
                    String modifiedTime, status;
                    if(recipientSubscription.status == 'UNSUB' || recipientSubscription.status == 'NORMAL') {
                        if(recipientSubscription.status == 'UNSUB') {
                            status = 'Unsubscribed';
                            modifiedTime = recipientSubscription.dateUnsub;
                        }
                        else if(recipientSubscription.status == 'NORMAL') {
                            status = 'Subscribed';
                            modifiedTime = recipientSubscription.dateJoined;
                        }
                    }
                    PostUpListSubscriptionModel postUpListSubscriptionModel = new PostUpListSubscriptionModel(recipientSubscription.recipientId, status, modifiedTime);
                    mapStatus.put(recipientSubscription.address, postUpListSubscriptionModel); 
                }
            }
        return mapStatus;
    }
    
    // To get List of address from API response
    public static List<String> getmailList(String response) {
        System.debug('RecipientSubscriptionControllerQueue : getmailList');
        List<String> mailList = new List<String>();
            if(response != '[]') {
                ListSubscriptionJson[] recipientSubscriptionList = ListSubscriptionJson.parseList(response);
                for(ListSubscriptionJson recipientSubscription : recipientSubscriptionList)  {
                    mailList.add(recipientSubscription.address); 
                }
            }
        return mailList;
    }
}