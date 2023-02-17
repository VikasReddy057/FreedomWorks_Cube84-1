trigger LeadTrigger on Lead (before Insert, before Update) {


if(Trigger.isBefore){

    if(trigger.isInsert){
        for(Lead ld: Trigger.new){
            if(ld.Add_To_Prospect__c){
                ld.Prospect_Last_Action_Date__c = system.today();
                ld.Add_To_Prospect__c = false;
            }            
        }
    }
    
    if(trigger.isUpdate){
        for(Lead ld: Trigger.new){
            if(ld.Add_To_Prospect__c){
                ld.Prospect_Last_Action_Date__c = system.today();
                ld.Add_To_Prospect__c = false;
            }            
        }    
    }
}

}