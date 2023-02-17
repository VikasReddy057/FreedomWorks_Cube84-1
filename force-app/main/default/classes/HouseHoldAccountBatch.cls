global class HouseHoldAccountBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
    Date dt = system.today();
        dt = dt.addMonths(-59);
    String query = 'SELECT Id,Name,Is_LastGift_5_years_old__c,npo02__LastCloseDate__c FROM Account where recordType.Name='+
        '\''+ 'Household'+'\'' +' AND npo02__LastCloseDate__c <=:dt' + ' AND Is_LastGift_5_years_old__c=false';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accList) {
        List<Contact> conList = new List<Contact>();
        for(Account acc : accList)
        {        
            acc.Is_LastGift_5_years_old__c = true;
        }
        try {

            update accList;
            

        } catch(Exception e) {System.debug(e);}
        
    }   
    
    global void finish(Database.BatchableContext BC) {

  }

}