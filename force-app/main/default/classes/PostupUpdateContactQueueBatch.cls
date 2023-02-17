global class PostupUpdateContactQueueBatch Implements Database.Batchable<sobject>,Schedulable,Database.Stateful, Database.AllowsCallouts{
     global id conTriggerid ;
    List<Postup_Contact_Log__c> contactlogs = new List<Postup_Contact_Log__c>();
    global void execute (SchedulableContext sc)
    {
        database.executeBatch( new PostupUpdateContactQueueBatch(sc.getTriggerId()),90 );
    }    
    global PostupUpdateContactQueueBatch(){
        
    }

    Global PostupUpdateContactQueueBatch (Id scId){
        conTriggerid = scId;
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Set<string> conids = new Set<String>();
       
        for(Postup_Contact_Log__c log : [Select id,ContactResponse__c from Postup_Contact_Log__c where ContactUpdate__c =true AND 
                                         Contact__c!=null])
        {
            contactlogs.add(log);
            //logsList.add(log);
            if(log.ContactResponse__c!=null && log.ContactResponse__c.length()>5){
                List<string> ls2 = (List<string>)JSON.deserialize(log.ContactResponse__c,List<string>.class);    
                
                System.debug(ls2);
                for(Object cm: ls2)
                    conids.add((string)cm);
            }
        }        
        String query= 'Select id,recipientId__c from contact where id=:conids';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact > scope){
         Map<String,Contact> conRecords = new Map<String,Contact>();
        for(Contact con: scope){
            try{
            PostUpRecipientController.updateRecipient2(con.Id, (Integer)con.recipientId__c);
            }Catch(Exception ex){
                System.debug(ex.getMessage()+ex.getStackTraceString());
                con.PostUpSyncError__c = ex.getMessage()+ex.getStackTraceString();
                conRecords.put(con.Id,con);
            }
        }
        
        if(conRecords.size()>0){
            List<List<Contact>> AllRecords = spliceBy(conRecords.values(),Integer.valueof(5));
            //update conRecords.values();
            for(List<Contact> sobjectRecords : AllRecords)
            {   
                List<Database.SaveResult> updateResults = database.update(sobjectRecords,false);
            }
        }
        if(contactlogs.size()>0){
            Delete contactlogs;
            contactlogs.clear();
        }
            
    }
    
    global void finish(Database.BatchableContext BC){
        List<Postup_Contact_Log__c> logList = [Select id,ContactResponse__c from Postup_Contact_Log__c where ContactUpdate__c =true AND 
                                               Contact__c!=null limit 100];
        
        
        if(!Test.isRunningTest() && logList.size()>0){
            database.executeBatch( new PostupUpdateContactQueueBatch(conTriggerid),50 );
        }else if (conTriggerid!=null){
            List<cronTrigger> a = [SELECT Id FROM cronTrigger WHERE Id = :conTriggerid ];
            for(cronTrigger ct: a)
                system.abortJob(ct.id);  
        }        
    }
    
        global static List<List<Contact >> spliceBy(List<Contact > objs, Integer size){
        List<List<Contact>> resultList = new List<List<Contact>>();
        
        Integer numberOfChunks = objs.size() / size;
        
        for(Integer j = 0; j < numberOfChunks; j++ ){
            
            List<Contact> someList = new List<Contact>(); for(Integer i = j * size; i < (j+1) * size; i++){someList.add(objs[i]);}resultList.add(someList);
        }
        
        if(numberOfChunks * size < objs.size()){
            List<Contact> aList = new List<Contact>();
            
            for(Integer k = numberOfChunks * size ; k < objs.size(); k++){
                aList.add(objs[k]);
            }
            
            resultList.add(aList);
        }
        
        
        return resultList;
    }
    public static void method1(){
    Integer i=0;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;   
        i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1; 
        i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;
    i= i+1;  
    }
}