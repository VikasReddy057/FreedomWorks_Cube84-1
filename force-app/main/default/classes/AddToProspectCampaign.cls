global class AddToProspectCampaign implements Database.Batchable<Sobject>,Schedulable{
    
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new AddToProspectCampaign(),1);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select id,Members__c from Add_To_Prospect_List__c]);
    }
    global void execute(Database.BatchableContext BC, List<Add_To_Prospect_List__c> scope){
            List<String> prospectList = new List<String>();
            for(Campaign cm: [Select id from Campaign where id=:System.Label.Campaign_Prospect_List.split(',')]){
                prospectList.add(cm.Id);
            }
          Set<id> contactIds = new Set<Id>();
        List<Campaignmember> cmList ;
        Map<string,Campaignmember> records = new Map<string,Campaignmember>();
        for(Add_To_Prospect_List__c ls: scope){
            try{
                if(ls.Members__c!=null && ls.Members__c.length()>9){
                    system.debug(ls.Members__c);
                  cmList = (List<Campaignmember>) JSON.deserialize(ls.Members__c, List<CampaignMember>.class);
                System.debug('cmList'+ cmList);
                    for(CampaignMember mb: cmList){
                        contactIds.add(mb.ContactId);
                        records.put(String.valueof(mb.ContactId)+String.valueOf(mb.CampaignId), mb);
                    }
                    Delete scope;
                    

                for(CampaignMember mb: [Select contactId,Campaignid from CampaignMember where Campaignid=:prospectList
                                       AND ContactId=:contactIds] ){
                    records.remove(String.valueof(mb.ContactId)+String.valueOf(mb.CampaignId));
                }
                    system.debug('###'+records);
                if(records.size()>0) Database.upsert(records.values(),CampaignMember.UniqueId__c.getDescribe().getSObjectField(),false);    

                }}Catch(Exception ex){
                System.debug('@@Error:'+ ex.getMessage()+ ex.getStackTraceString());
            }
        }
        
    }
    global void finish(Database.BatchableContext BC){
        if([Select id,Members__c from Add_To_Prospect_List__c where createdDate = TODAY limit 10].size()>0)
            Database.executeBatch(new AddToProspectCampaign(),1);
    }

}