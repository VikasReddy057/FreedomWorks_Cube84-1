trigger OpportunityTrigger on Opportunity (after Insert, after Update,after Delete) {

if(trigger.isafter){
    if(trigger.isInsert){
        OpportunityTriggerHandler.afterInsert(trigger.new,trigger.newMap);
    }
    if(trigger.isUpdate){
        OpportunityTriggerHandler.afterUpdate(trigger.new, trigger.newMap,trigger.oldMap);
    }
        if(trigger.isDelete){
        OpportunityTriggerHandler.afterDelete(trigger.old,trigger.oldMap);
    }
}

}