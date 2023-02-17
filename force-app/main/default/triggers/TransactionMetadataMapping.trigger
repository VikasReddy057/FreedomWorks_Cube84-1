trigger TransactionMetadataMapping on bt_stripe__Transaction__c (before insert,before update,after Insert,after Update) {
    List<bt_stripe__Transaction__c> traList = new List<bt_stripe__Transaction__c>();
    
    if( trigger.isBefore) {
    for(bt_stripe__Transaction__c tra : Trigger.new){

               
        if(Trigger.isUpdate && Trigger.oldMap.get(tra.Id).bt_stripe__Metadata__c != Trigger.newMap.get(tra.Id).bt_stripe__Metadata__c){
             traList.add(Trigger.newMap.get(tra.Id));   
        }else if(Trigger.isInsert){
              traList.add(tra);  
        }
         
    }
    
    if(traList.size()>0){
        TransactionMetadataMapping.doMapping(traList);
    }
    }
    if(trigger.isUpdate && trigger.isAfter && TransactionHelperClass.afterUpdateFirstRun  
       && !TransactionHelperClass.isInsert  && trigger.New.Size()==1)
        TransactionHelperClass.beforeUpdate(trigger.New,trigger.Old,Trigger.newMap, Trigger.OldMap);
    if(trigger.isInsert && trigger.isAfter  && trigger.New.Size()==1)
        TransactionHelperClass.beforeInsert(trigger.new);
}