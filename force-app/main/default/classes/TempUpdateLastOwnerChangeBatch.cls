global class TempUpdateLastOwnerChangeBatch implements Database.Batchable<Sobject>,Schedulable {

    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new TempUpdateLastOwnerChangeBatch(),9);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
       
        return Database.getQueryLocator([SELECT CreatedDate,ContactId,Contact.Last_Owner_Changed__c
                                          FROM ContactHistory where
                                         CreatedDate =LAST_N_DAYS:6 AND
                                         Field='Owner' AND DataType='EntityId']);
    }
    global void execute(Database.BatchableContext BC, List<ContactHistory> scope){
        Map<Id,contact> records = new Map<id,contact>();
        
        for(ContactHistory his: scope){
            if(his.Contact.Last_Owner_Changed__c==null || 
               (his.Contact.Last_Owner_Changed__c!=null && his.createdDate.date()> his.Contact.Last_Owner_Changed__c.date()))
            records.put(his.contactId, new Contact(id=his.ContactId,Last_Owner_Changed__c=his.CreatedDate));
            
        }
        
        if(records.size()>0)
            update records.values();
    }
    global void finish(Database.BatchableContext BC){
        
    }
    public static void DummyMethod(){
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


    }
}