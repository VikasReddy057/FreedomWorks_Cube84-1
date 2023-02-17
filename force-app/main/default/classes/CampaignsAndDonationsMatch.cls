global class CampaignsAndDonationsMatch Implements Database.Batchable<sObject>,Schedulable{
    
    List<string> campaignsourceCode = new List<string>();
    public CampaignsAndDonationsMatch (List<string> ls) {
        campaignsourceCode = ls;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
                
        string query = 'select Id, Donation_Source__c,CampaignId,Parent_Campaign__c from Opportunity where Donation_Source__c!=null AND CampaignId=null '+ 
            'AND Donation_Source__c=:campaignsourceCode AND StageName!='+'\''+'Posted'+'\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        Set<String> CampaignSourceCode = new Set<String>(); 
        Map<String,Campaign> campRecords = new Map<String,Campaign>();
        
        for(Opportunity opp: scope)
            CampaignSourceCode.add(opp.Donation_Source__c);
        
        Id CampaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Cager Daily').getRecordTypeId();
        
        for(Campaign cm: [Select id,Source_Code__c,ParentId from Campaign where RecordTypeId !=:CampaignRecordTypeId AND 
                          Source_Code__c=:CampaignSourceCode Order by CreatedDate  Desc])
            if(!campRecords.containsKey(cm.Source_Code__c)) campRecords.put(cm.Source_Code__c,cm);
        for(Opportunity opp: scope){
            if(campRecords.ContainsKey(opp.Donation_Source__c))
                opp.CampaignId = campRecords.get(opp.Donation_Source__c).id;
            if(campRecords.ContainsKey(opp.Donation_Source__c) && campRecords.get(opp.Donation_Source__c).ParentId!=null)
                opp.Parent_Campaign__c = campRecords.get(opp.Donation_Source__c).ParentId;
            
        }
        
        Database.SaveResult[] results = Database.Update(scope, false);
    }
    
    
    global void finish(Database.BatchableContext BC){
        
    }
    global void execute(SchedulableContext sc) {
        
    }
    //global void execute(SchedulableContext sc) {
        
        //Database.executeBatch(new CampaignsAndDonationsMatch(), 10);
    //}

}