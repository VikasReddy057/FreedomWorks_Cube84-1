/*
 * Call PostUp "listsubscription" API with 2000 limit
 * 
 * For each 2000 records calling PostUpSubscriptionControllerBatch Batch Class to do DML operation for non empty response
 *  
 * For Empty response, remove proceed ListId from List of ListId and pass that list to PostUpSubscriptionQueue for recursive Process
 * 
 */
public class PostUpSubscriptionControllerQueue implements Queueable, Database.AllowsCallouts{
    
    Integer listId;
    Integer lastRecipientId;
    Set<Integer> listIdList;
    
    public PostUpSubscriptionControllerQueue(Integer listId, Integer lastRecipientId, Set<Integer> listIdList) {
        System.debug('PostUpSubscriptionControllerQueue Constructor and listId, lastRecipientId, listIdList are ' + listId + lastRecipientId + listIdList);
        this.listId = listId;
        this.lastRecipientId = lastRecipientId;
        this.listIdList = listIdList;
    }
    
    public void execute(QueueableContext qc){
        System.debug('PostUpSubscriptionControllerQueue : execute');
        String response = '[]';
        if(!Test.isRunningTest()) {
            response = PostUpSubscriptionController.getListSubscription(listId, lastRecipientId);    
        }
        for(ListSubscriptionJson recipientDetail:ListSubscriptionJson.parseList(response)) {
            lastRecipientId = recipientDetail.recipientId;
        }
        if(response != '[]') {
            Map<Integer, PostUpListSubscriptionModel> postUpListSubscriptionModelSet = getpostUpListSubscriptionMap(response);
            Map<Integer, Map<Integer, PostUpListSubscriptionModel>> postUpListSubscriptionMap = new Map<Integer, Map<Integer, PostUpListSubscriptionModel>>();
            postUpListSubscriptionMap.put(listId, postUpListSubscriptionModelSet);
            Integer[] recipientList = getRecipientList(response);
            Database.executeBatch(new PostUpSubscriptionControllerBatch(listId, postUpListSubscriptionMap, recipientList, lastRecipientId, listIdList));
        }
        else if(response == '[]') {
            listIdList.remove(listId);
            if(!listIdList.isEmpty()) {
                System.debug('listIdList for recursion '+listIdList);
                if(!Test.isRunningTest()){
                    System.enqueueJob(new PostUpSubscriptionQueue(listId, listIdList));   
                }
            }
        }
    }
    
    // To get Map of PostUpSubscription detail from API response. Key - RecipientId and Value - PostUpListSubscriptionModel (RecipientId, Status, ModifiedTime)
    public static Map<Integer, PostUpListSubscriptionModel> getpostUpListSubscriptionMap(String response) {
        System.debug('PostUpSubscriptionControllerQueue : getpostUpListSubscriptionMap');
        Map<Integer, PostUpListSubscriptionModel> postUpListSubscriptionModelSet = new Map<Integer, PostUpListSubscriptionModel>();
        if(!Test.isRunningTest()) {
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
                    postUpListSubscriptionModelSet.put(recipientSubscription.recipientId, postUpListSubscriptionModel); 
                }
            }
        }
        return postUpListSubscriptionModelSet;
    }
    
    // To get List of RecipientId from API response
    public static List<Integer> getRecipientList(String response) {
        System.debug('PostUpSubscriptionControllerQueue : getRecipientList');
        List<Integer> recipientList = new List<Integer>();
        if(!Test.isRunningTest()) {
            if(response != '[]') {
                ListSubscriptionJson[] recipientSubscriptionList = ListSubscriptionJson.parseList(response);
                for(ListSubscriptionJson recipientSubscription : recipientSubscriptionList)  {
                    recipientList.add(recipientSubscription.recipientId); 
                }
            }
        }
        return recipientList;
    }
}