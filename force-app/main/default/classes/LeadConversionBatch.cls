global class LeadConversionBatch implements Database.Batchable<Sobject>,Schedulable{
        static boolean recursive = false;
    List<id> recordIds ;
    global void execute(SchedulableContext SC) {
        if(!recursive) {recursive = true;
        
        
        if(!Test.isRunningTest()) Database.executeBatch( new LeadConversionBatch( ),2);else Database.executeBatch(new LeadConversionBatch( ),2  );  
        }
    }
    global  LeadConversionBatch(){
        
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select id,bt_stripe__Related_Lead__c,bt_stripe__Transaction_Status__c,bt_stripe__Payment_Status__c
                                         
                                         from bt_stripe__Transaction__c where CreatedDate >= LAST_N_DAYS:31 AND
                                        bt_stripe__Payment_Status__c IN ('Captured','Refunded') AND 
                                        bt_stripe__Transaction_Status__c='Completed' AND bt_stripe__Related_Lead__r.isConverted=false AND bt_stripe__Related_Lead__c!=null
                                        AND bt_stripe__Related_Account__c=null ]);
    }
    global void execute(Database.BatchableContext BC, List<bt_stripe__Transaction__c> scope){
        
        TransactionHelperClass.autoLeadConversion(scope,null);
    }
    global void finish(Database.BatchableContext BC){
        
    }
}