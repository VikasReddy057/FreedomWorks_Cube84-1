trigger CampaignMemberTrigger2 on CampaignMember (before insert) {

if(trigger.isInsert && trigger.isBefore)
for(CampaignMember cm: trigger.new){
    if(cm.contactId!=null && cm.uniqueId__c==null)
        cm.uniqueId__c = String.valueof(cm.campaignId)+string.valueof(cm.ContactId);
}
}