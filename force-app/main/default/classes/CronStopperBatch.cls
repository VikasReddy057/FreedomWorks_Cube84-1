global class CronStopperBatch implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext bc){
        String soqlQuery = 'SELECT Id FROM CronTrigger';   
        return database.getquerylocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<CronTrigger> scope){
        for(CronTrigger cron: scope){
            System.abortJob(cron.Id); 
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}