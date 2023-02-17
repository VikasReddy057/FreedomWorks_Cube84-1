global class PostUpContactRecipientUpdateScheduler Implements Database.Batchable<sobject>,Schedulable {
    Date dt;
    global void execute(SchedulableContext ctx) {
        //Batch size is 200, records will be split into batches      
        Database.ExecuteBatch(new PostUpContactRecipientUpdateScheduler() ,Integer.valueof(Label.PostUp_Contact_Job));
    } 
    global PostUpContactRecipientUpdateScheduler(){
        
    }
    global PostUpContactRecipientUpdateScheduler(Date dtt){
        this.dt = dtt;
    }
 global Database.QueryLocator start(Database.BatchableContext BC){
 string query = 'select Id,RecipientId__c,Contact__c,Campaign__c from Postup_Contact_Log__c where ';
     if(dt !=null)
     query = query+ 'LastModifiedDate=:dt AND  ';

     query = query+ 'isProcessed__c=false AND Campaign__c!=null AND Contact__c!=null  AND'+
     ' RecipientId__c!=null AND CreateRecipients__c= false AND UpdateRecipients__c= false order by CreatedDate,Campaign__c,Contact__c ASC';
 return Database.getQueryLocator(query);
 }

 global void execute(Database.BatchableContext BC, List<Postup_Contact_Log__c > scope){
 
     Map<String,Contact> conRecords = new Map<String,Contact>();
     List<Postup_Contact_Log__c> updateLogs = new List<Postup_Contact_Log__c>();
     Set<Postup_Contact_Log__c> removeLogs = new Set<Postup_Contact_Log__c>();
     Set<String> contactIds = new Set<String>();
     Map<String,Contact> contactRecordsList = new Map<String,Contact>();
     Map<string,Postup_Contact_Log__c> IdandLogMap = new Map<String,Postup_Contact_Log__c>();
     for (Postup_Contact_Log__c logRecord: scope ){
         contactIds.add(logRecord.Contact__c);
     }
     for(Contact con: [Select id,RecipientId__c from Contact Where id=:contactIds and RecipientId__c!=null])
         contactRecordsList.put(con.Id,Con);
     
     for (Postup_Contact_Log__c logRecord: scope ){
         IdandLogMap.put(logRecord.Id,logRecord);
         if(contactRecordsList.containsKey(logRecord.Contact__c) && logRecord.RecipientId__c == contactRecordsList.get(logRecord.Contact__c).RecipientId__c)
         {
            removeLogs.add(logRecord);IdandLogMap.remove(logRecord.Id);continue;
             
         } 
         conRecords.put(logRecord.Contact__c, new Contact(id=logRecord.Contact__c,
                                                          RecipientId__c=logRecord.RecipientId__c));
         
     }
     if(conRecords.size()>0){
         List<List<Contact>> AllRecords = spliceBy(conRecords.values(),Integer.valueof(label.Postup_Split_Size));
         for(List<Contact> sobjectRecords : AllRecords)
         {   
         List<Database.SaveResult> updateResults = database.update(sobjectRecords,false);
         for (Database.SaveResult r : updateResults)
             
         {
             if (!r.isSuccess()){
                 for (Database.Error e : r.getErrors()){ 
                     for (Postup_Contact_Log__c logRecord: scope ){
                         if(logRecord.Contact__c== r.getId()){removeLogs.remove(logRecord);IdandLogMap.remove(logRecord.Id);logRecord.Error_Message__c = e.getMessage();logRecord.isProcessed__c= true;updateLogs.add(logRecord); }
                     }
                 }                 
             }/*else
             {
                 for (Postup_Contact_Log__c logRecord: scope ){
                     if(logRecord.Contact__c== r.getId()){
                         removeLogs.add(logRecord);
                     }
                 }
             }*/
         }

         if(updateLogs.size()>0)update updateLogs;
         }
     }
     System.debug(IdandLogMap.values());
     System.debug(removeLogs);
     List<Postup_Contact_Log__c> logListDel = [Select id from Postup_Contact_Log__c 
                                               where id=:removeLogs OR id=:IdandLogMap.keySet()];
	if(logListDel.size()>0)
        Delete logListDel;
             
     
 }
 
 //Finish method can be used for sending an email once batch is completed. 
 global void finish(Database.BatchableContext BC){
     
     List<Postup_Contact_Log__c> logs= [select Id from Postup_Contact_Log__c where  Campaign__c!=null AND Contact__c!=null  AND isProcessed__c=false AND 
     RecipientId__c!=null AND CreateRecipients__c= false AND UpdateRecipients__c= false order by CreatedDate ASC  limit 200 ];
	if(!Test.isRunningTest() && logs.size()>0)
        Database.ExecuteBatch(new PostUpContactRecipientUpdateScheduler() ,Integer.valueof(Label.PostUp_Contact_Job));
     
 }
    global static List<List<Contact >> spliceBy(List<Contact > objs, Integer size){
        List<List<Contact>> resultList = new List<List<Contact>>();
        
        Integer numberOfChunks = objs.size() / size;
        
        for(Integer j = 0; j < numberOfChunks; j++ ){
            
            List<Contact> someList = new List<Contact>(); for(Integer i = j * size; i < (j+1) * size; i++){someList.add(objs[i]);}resultList.add(someList);
        }
        
        if(numberOfChunks * size < objs.size()){
            List<Contact> aList = new List<Contact>();
            
            for(Integer k = numberOfChunks * size ; k < objs.size(); k++){
                aList.add(objs[k]);
            }
            
            resultList.add(aList);
        }
        
        
        return resultList;
    }
}