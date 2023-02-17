trigger PrimayChannelMember on Primary_Channel_Members__c (Before Update,Before Insert) {
    
    if(trigger.isBefore  && (trigger.isUpdate || trigger.isInsert)){
    for(Primary_Channel_Members__c pc: trigger.New){
        if(pc.dummy_Count__c>0){
            pc.count__c = pc.count__c>0? pc.count__c+ pc.dummy_Count__c:pc.dummy_Count__c;
            pc.dummy_Count__c =0;
        }
    }
    
    }

}