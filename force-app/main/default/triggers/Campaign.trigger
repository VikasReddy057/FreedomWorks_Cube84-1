trigger Campaign on Campaign (after Insert,after Update) {

Set<String> sourceCode = new Set<String>();
if(trigger.isInsert && trigger.isafter ){

    for(Campaign cm: trigger.New){
    if(cm.Source_Code__c!=null)
        sourceCode.add(cm.Source_Code__c); 
    }
}
if(trigger.isUpdate && trigger.isafter ){

    for(Campaign cm: trigger.New){
    if(cm.Source_Code__c!=null && cm.Source_Code__c!= trigger.oldMap.get(cm.Id).Source_Code__c)
        sourceCode.add(cm.Source_Code__c); 
    }
}
if(sourceCode.size()>0)
Database.executeBatch(new CampaignsAndDonationsMatch(new List<String>(sourceCode)),10);
}