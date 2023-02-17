/*
 * 1. Create a new Recipient for the campaign member of the syncing campaign in Salesforce
 * 2. Retrieve the mapped fields of the PostUp as the Parameters for Recipient POST API 
 * 3. Update Recipient for PostUp List Status change from Salesforce Campaign Member record
 */ 
public class PostUpRecipientController {
    
    //Parsing the response of Recipient API
    public Integer recipientId;	
    public String status;
    public Data data;
    class Data {
        public String message;
    }
    
    // To avoid 'Too many SOQL queries: 201', fields variable is converted as a static variable
    public static PostUpFieldMap__c[] allMappedFields = [select FieldName__c, PostUp_Field_Type__c, SfField__c, SalesforceField__c from PostUpFieldMap__c where SfField__c !=: null And SalesforceField__c !=: null];
    public static PostUpFieldMap__c[] fields = [select FieldName__c, PostUp_Field_Type__c, SfField__c, SalesforceField__c from PostUpFieldMap__c where SfField__c !=: null And SalesforceField__c !=: null AND PostUp_Table__c = 'Recipients'];
    public static PostUpFieldMap__c[] demographicsFields =  [select FieldName__c, PostUp_Field_Type__c, SfField__c, SalesforceField__c from PostUpFieldMap__c where SfField__c !=: null AND SalesforceField__c !=: null And (PostUp_Table__c = 'Custom Field' OR PostUp_Table__c = 'Standard Field')];
    public static Http http = new Http();
    
    //Assign values for Paramters of Recipient API. Pass ContactId as parameter
    public static String createRecipientRequest(String contactId) {
        System.debug('PostUpRecipientController : createRecipientRequest');
        Map<String, object> reqJson = new Map<String, object>();
        String[] demographics = new List<String>();
        String contactFields = '';
        Set<String> allMappedFieldSet = new Set<String>();
        for(PostUpFieldMap__c field : allMappedFields) {
            allMappedFieldSet.add(field.SalesforceField__c);
        }
        for(String field : allMappedFieldSet) {
            if(contactFields != '') contactFields += ',';
            contactFields += field;
        }
        Contact[] contact= Database.query('select ' + contactFields +' FROM Contact '+'WHERE Id =: contactId');
        if(!contact.isEmpty()){
            for(PostUpFieldMap__c mapField : fields) {
                if(contact[0].get(mapField.SfField__c) != null) {
                    reqJson.put(mapField.FieldName__c , contact[0].get(mapField.SalesforceField__c));    
                }
            }
            for(PostUpFieldMap__c demographicsField : demographicsFields) {
                if(contact[0].get(demographicsField.SfField__c) != null) {
                    try{
                        demographics.add(demographicsField.FieldName__c+'='+contact[0].get(demographicsField.SalesforceField__c));        
                    }
                    catch (SObjectException e) {
                        System.debug(e);
                        demographics.add(demographicsField.FieldName__c+'='+contact[0].getSobject(demographicsField.SalesforceField__c.split('\\.')[0]).get(demographicsField.SalesforceField__c.split('\\.')[1]));
                    }
                }
            }
        }
        reqJson.put('channel', 'E');
        reqJson.put('demographics', demographics);
        return JSON.serialize(reqJson);
    }
	
    //Create a new PostUp Recipient for campaign member
    public static String createOneRecipient(String contactId, Integer listId, String status) {
        System.debug('PostUpRecipientController : createOneRecipient');
        String requestBody = createRecipientRequest(contactId);
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setEndpoint('callout:PostUp'+'/recipient');
        request.setBody(requestBody);
        HttpResponse response = http.send(request);
        PostUpSubscriptionController.subscribeList(listId, parse(response.getBody()).recipientId, status);
        return response.getBody();
    }
    
    //Update Recipient for Change in Status of Campaign Member
    public static void updateRecipient(String contactId, Integer recipientId) {
        System.debug('PostUpRecipientController : updateRecipient');
        if(!System.isFuture() && !System.isBatch() && !System.isScheduled() && !System.isQueueable()) {
            updateRecipientFuture(contactId, recipientId);
        }
    }
    
    //Only call from CampaignMember Trigger
    @future(callout=true)
    public static void updateRecipientFuture(String contactId, Integer recipientId) {
        System.debug('PostUpRecipientController : updateRecipientFuture');
        String requestBody = createRecipientRequest(contactId);
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint('callout:PostUp'+'/recipient/' + recipientId); 
        request.setBody(requestBody);
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest()) {
            response = http.send(request);    
        }
    }
     
    public static void updateRecipient2(String contactId, Integer recipientId) {
        System.debug('PostUpRecipientController : updateRecipientFuture');
        String requestBody = createRecipientRequest(contactId);
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint('callout:PostUp'+'/recipient/' + recipientId); 
        request.setBody(requestBody);
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest()) {
            response = http.send(request);    
        }
    }   
    public static PostUpRecipientController parse(String json) {
        System.debug('PostUpRecipientController : parse');
        return (PostUpRecipientController) System.JSON.deserialize(json,PostUpRecipientController.class);
    }
}