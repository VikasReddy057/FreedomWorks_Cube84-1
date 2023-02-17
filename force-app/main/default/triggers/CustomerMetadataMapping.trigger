trigger CustomerMetadataMapping on bt_stripe__Stripe_Customer__c (before insert,before update) {
    List<bt_stripe__Stripe_Customer__c> cusList = new List<bt_stripe__Stripe_Customer__c>();
    
    for(bt_stripe__Stripe_Customer__c tra : Trigger.new){
        
        if(Trigger.isUpdate && Trigger.oldMap.get(tra.Id).bt_stripe__Metadata__c != Trigger.newMap.get(tra.Id).bt_stripe__Metadata__c){
             cusList.add(Trigger.newMap.get(tra.Id));   
        }else if(Trigger.isInsert){
              cusList.add(tra);  
        }
         
    }
    
    if(cusList.size()>0){
        TransactionMetadataMapping.doCustomerMapping(cusList);
    }
}