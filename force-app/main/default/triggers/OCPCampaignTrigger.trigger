trigger OCPCampaignTrigger on Campaign (before insert, after insert) {
    if(trigger.isBefore && trigger.isInsert){
        for(Campaign cam : trigger.new){
            cam.OCP_Campaign_Id__c = '41075';
        }
    }
    
    if(trigger.isAfter && trigger.isInsert){
        List<Campaign> camList = new List<Campaign>();
        for(Campaign cam : trigger.new){
            if(String.isNotBlank(cam.OCP_Campaign_Id__c)){
                camList.add(cam);
            }
        }
        if(!camList.isEmpty()){
            OCPCampaignTriggerHandler.isAfterInsert(JSON.serialize(camList));
        }
    }
}