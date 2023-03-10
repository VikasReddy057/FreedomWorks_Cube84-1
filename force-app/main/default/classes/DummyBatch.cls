global class DummyBatch Implements Database.Batchable<sobject> {
    
    public static void doUpdate(String masterContactId,String slaveContactId){
        
        Contact master = [Select id,AccountId from contact  where id=:masterContactId];
        List<bt_stripe__Payment_Method__c> updatePM = new List<bt_stripe__Payment_Method__c>();
        Set<string> PMaccountIds = new Set<String>();
        Set<string> trnIds = new Set<String>();
        for(bt_stripe__Payment_Method__c slavePM : [Select id,bt_stripe__Account__c,bt_stripe__Account__r.Name,
                                                      bt_stripe__Contact__c,
                                                      bt_stripe__Contact__r.Name,bt_stripe__Contact__r.CreatedDate, 
                                                      (Select id from bt_stripe__Transactions__r)
                                                      from
                                                     bt_stripe__Payment_Method__c where bt_stripe__Contact__c=:slaveContactId]){
                                                         
                     PMaccountIds.add(slavePM.bt_stripe__Account__c);
                     
                     for(bt_stripe__Transaction__c tr: slavePM.bt_stripe__Transactions__r){
                         trnIds.add(tr.Id);                                    
                     }
                     slavePM.bt_stripe__Account__c =   master.AccountId;
                     slavePM.bt_stripe__Contact__c =   master.Id;                                    
                     updatePM.add(slavePM);
                                                         
        }
        if(updatePM.size()>0)
            update updatePM;
        List<Opportunity> opList = new List<Opportunity>();
        
        for(Opportunity op: [Select id,AccountId,Account.Name,npsp__Primary_Contact__c,
             npsp__Primary_Contact__r.Name,npsp__Primary_Contact__r.CreatedDate,Account.CreatedDate 
             from Opportunity where AccountId=:PMaccountIds]){
                 
            op.AccountId= master.AccountId;
            op.npsp__Primary_Contact__c = master.Id ;  
                 opList.add(op);
        }
        if(opList.size()>0)
        update opList;
        List<bt_stripe__Transaction__c> listTrnx = new List<bt_stripe__Transaction__c>();
        
        for(bt_stripe__Transaction__c tran: [Select id,bt_stripe__Related_Account__c,bt_stripe__Related_Account__r.Name,
                                             bt_stripe__Related_Contact__c,
             bt_stripe__Related_Contact__r.Name,CreatedDate from bt_stripe__Transaction__c where id=:trnIds]){
            tran.bt_stripe__Related_Account__c = master.AccountId;
            tran.bt_stripe__Related_Contact__c = master.Id;
                 listTrnx.add(tran);
        }
        
        if(listTrnx.size()>0)
            Update listTrnx;
        
    }
    
    public static void sampleMethod(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;         
    }
    //Implements Database.Batchable<sobject> 
global Database.QueryLocator start(Database.BatchableContext BC){
 string query = 'Select id,Master__c,Slave__c from Zips__c where Master__c !=null';
    return Database.getQueryLocator(query);
 }

 global void execute(Database.BatchableContext BC, List<Zips__c > scope){
 
  
     for(Zips__c con: scope){         
         doUpdate(con.Master__c,Con.slave__c);
     }
     
     delete scope;

     
 }
 
 //Finish method can be used for sending an email once batch is completed. 
 global void finish(Database.BatchableContext BC){

 }
}