trigger AccountTrigger on Account (before Update,before Insert) {

/*if(trigger.isBefore && trigger.isUpdate){
 Map<string,Account> delAcc = new map<string,Account>();
     Set<string> accids = new Set<string>();
   for(Account acc: trigger.new)
   accids.add(acc.Id); 
 
    for(Account acc: [ Select MasterRecordId  from Account where  LastModifiedDate=TODAY AND  MasterRecordId=:accids AND isDeleted= true AND MasterRecordId !=null  ALL ROWS]) delAcc.put(acc.MasterRecordId  ,acc); 
    if(test.isRunningTest())
    delAcc.put(trigger.new[0].Id,trigger.new[0]); 
    
    for(Account acc: trigger.new){
    //(acc.npo02__LargestAmount__c != trigger.oldMap.get(acc.id).npo02__LargestAmount__c || acc.ownerId != trigger.oldMap.get(acc.id).ownerId ) && 
    if(delAcc.containskey(acc.id) &&  !acc.isMerged__c){
        acc.isMerged__c = true;
    }else
     acc.isMerged__c  = false;
    }

}*/
 if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
   
   
   for(Account acc: Trigger.new){
 
       if(trigger.isUpdate && (Trigger.oldMap.get(acc.Id).npo02__LargestAmount__c != acc.npo02__LargestAmount__c ||
                               Trigger.oldMap.get(acc.Id).OwnerId!= acc.OwnerId ||
                               Trigger.oldMap.get(acc.Id).npo02__LastOppAmount__c!= acc.npo02__LastOppAmount__c||
                               Trigger.oldMap.get(acc.Id).npo02__AverageAmount__c!= acc.npo02__AverageAmount__c||
                               Trigger.oldMap.get(acc.Id).npo02__LastCloseDate__c!= acc.npo02__LastCloseDate__c||
                               Trigger.oldMap.get(acc.Id).Do_Not_Contact__c!= acc.Do_Not_Contact__c
                              )
       
       ){
           
           acc.Dummy_Contact_Trigger_Time__c = System.Today();
           if(Trigger.new.size()==1 && !system.isFuture() && !system.isBatch()){
               ContactDonationStatusBatch.updateContactsfromAccount(String.valueof(acc.Id));
           }
       }
        
       if(trigger.isInsert && (acc.npo02__LargestAmount__c>0 ||
                                acc.npo02__LastOppAmount__c>0 ||
                                acc.npo02__AverageAmount__c>0 ||
                                acc.npo02__LastCloseDate__c !=null ||
                                acc.Do_Not_Contact__c
                              )
       
       ){
           
           acc.Dummy_Contact_Trigger_Time__c = System.Today();
       }
       }
   }
 
 
 }