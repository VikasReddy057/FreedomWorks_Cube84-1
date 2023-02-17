/*
 * 1. Get All List Subscription details from PostUp during Cron Job
 * 2. From hashmap getting the Status and modified time (Date of joined/ UnSub time)
 * 3. Update Subscription status of the list from Salesforce to PostUp and also Unsub the List while Campaign member is removed
 * 4. Update Global UnSub in PostUp while contact is deleted
 */ 
public class PostUpSubscriptionController {
    
    public static Http http = new Http();
    
    //Get All List Subscription Detail from PostUp
    public static String getListSubscription(Integer listId, Integer lastRecipientId) {
        System.debug('PostUpSubscriptionController : getListSubscription');
        HttpRequest request = new HttpRequest();
        request.setMethod('GET'); 
        request.setTimeout(120000);
        HttpResponse res;
        System.debug('lastRecipientId= ' + lastRecipientId);
        request.setEndpoint('callout:PostUp'+'/listsubscription?listid=' + listId +'&limit=2000&lastrecipid='+lastRecipientId);
        System.debug('request is ' + request);

         res = http.send(request);   
        
        System.debug('res is ' + res.getBody());        
        return  res.getBody();
    }
    
    // Called from CampaignMember Trigger to update status in PostUp
    public static void updateSubscription(Integer listId, Integer recipientId, String status) {
        System.debug('PostUpSubscriptionController : updateSubscription');
        if(System.isFuture()) {
            System.debug('System.isFuture()');
        }
        else if(System.isBatch() || System.isScheduled() || System.isQueueable()) {
            System.debug('System.isBatch() || System.isScheduled() || System.isQueueable()');
            updateSubscriptionImplementation(listId, recipientId, status);
        }
        else if(!System.isFuture()) {
            if(!Test.isRunningTest()) {
            updateSubscriptionExecution(listId, recipientId, status);
            }
        }
    }
    
    // Update Subscription status in PostUp from Salesforce
    @future(callout=true)
    public static void updateSubscriptionExecution(Integer listId, Integer recipientId, String status) {
        System.debug('PostUpSubscriptionController : updateSubscriptionExecution');
        updateSubscriptionImplementation(listId, recipientId, status);
    }
    
    public static void updateSubscriptionImplementation(Integer listId, Integer recipientId, String status) {
        System.debug('PostUpSubscriptionController : updateSubscriptionImplementation');
        Map<String, Object> reqJson = new Map<String, Object>();
        reqJson.put('listId', listId);
        reqJson.put('recipientId', recipientId);
        if(status.equalsignorecase('Subscribed')) {
            System.debug('status= '+status);
            reqJson.put('status', 'NORMAL');
        }
        else if(status.equalsignorecase( 'Unsubscribed')) {
            System.debug('status= '+status);
            reqJson.put('status', 'UNSUB');
        }
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint('callout:PostUp'+'/listsubscription');
        request.setBody(JSON.serialize(reqJson));
        HttpResponse res = http.send(request);
    }
    
    // GlobalUnsub the recipient once Contact is deleted
    //@future(callout=true)
    public static void updateGlobalUnSub(Integer recipientId) {
        System.debug('PostUpSubscriptionController : updateGlobalUnSub');
        Map<String, Object> reqJson = new Map<String, Object>();
        reqJson.put('status', 'U');
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint('callout:PostUp'+'/recipient/' + recipientId);
        request.setBody(JSON.serialize(reqJson));
        HttpResponse res = new HttpResponse();
        if(!Test.isRunningTest()) {
            res = http.send(request);    
        }
    }
    
    //Subscribe the list by the recipient in PostUp
    Public static void subscribeList(Integer listId, Integer recipientId, String status) {
        System.debug('PostUpSubscriptionController : subscribeList');
        Map<String, object> reqJson = new Map<String, object>();
        reqJson.put('listId', listId);
        reqJson.put('recipientId', recipientId);
        reqJson.put('status', status);
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('callout:PostUp'+'/listsubscription');
        request.setBody(JSON.serialize(reqJson));
        HttpResponse res = http.send(request);
    }
}