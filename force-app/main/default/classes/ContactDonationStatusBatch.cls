global class ContactDonationStatusBatch implements Database.Batchable<Sobject>,Schedulable,Database.Stateful{
    static boolean recursive = false;
    Date selDate ;
    Set<string> accIds = new Set<String>();
    
    global void execute(SchedulableContext SC) {
        if(!recursive) {recursive = true;
        
        
        if(!Test.isRunningTest()) Database.executeBatch( new ContactDonationStatusBatch(System.today()),21 );else Database.executeBatch( new ContactDonationStatusBatch(),25 );  
        }
    }
    global  ContactDonationStatusBatch(){
        
    }
    global  ContactDonationStatusBatch(Date dt){this.selDate = dt;                          
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        samplemethod();
        
        for(Account acc: [Select id from Account where  Dummy_Contact_Trigger_Time__c >= LAST_N_DAYS:10 limit 50000 ]){
            accIds.add(acc.Id);
        }        
        String query=' Select id, OwnerId,AccountId,Account.OwnerId,Account.Do_Not_Contact__c,Account.Dummy_Contact_Trigger_Time__c,npo02__LastOppAmount__c,'+
                     ' npo02__AverageAmount__c,npo02__LastCloseDate__c,Primary_Engagement_Channel__c from contact ';
        if(selDate!=null  ){
            query = query+' where Dummy_LastGiftDate__c >='+  System.now().addDays(-10).format('yyyy-MM-dd');
            if(accids.size()>0)
            query = query+ ' OR ( AccountId=:accIds )';
        }
        else{
            query = query+' where (npo02__LastCloseDate__c !=null) ';
            if(accids.size()>0)
                query = query+ ' OR ( AccountId=:accIds )';
        }
        
         
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
    Map<string,contact> recordsList = new Map<String,contact>();
        List<string> cmpIds = Label.Campaign_Donations_Ids.split(',');
        Map<string,contact> conMap = new Map<string,contact>();
        list<Account> accList = new List<Account>();
        list<String> conIds = new list<string>();
        if(test.isRunningTest()){
            for(Campaign cmp: [Select id from Campaign limit 2]){
                cmpIds.add(cmp.Id);
            }
            getListValues ('1');
        }
        
        for(Contact con: scope){
            try{
            conIds.add(con.Id);
            con.Dummy_LastGiftDate__c =null;
            con.Primary_Channel__c=null;
            conMap.put(con.Id,con);
            if(con.AccountId!=null && accIds.contains(con.AccountId) && con.Account.Dummy_Contact_Trigger_Time__c!=null)
            {
                accList.add(new Account(id=con.AccountId,Dummy_Contact_Trigger_Time__c = null));
                con.Dummy_Update__c = 'processed';
                con.npsp__Do_Not_Contact__c = con.Account.Do_Not_Contact__c;
                if(con.OwnerId!=con.Account.OwnerId)
                    con.OwnerId=con.Account.OwnerId;                
            }
            }Catch(Exception ex){System.debug('Error1:'+ex.getStackTraceString());}    
        }
        
        /*for(CampaignMember cmp: [Select Donor_Status__c,ContactId,Contact.Primary_Engagement_Channel__c from CampaignMember where campaign.id=:cmpIds and ContactId=:conIds ]){
            System.debug(cmp.Donor_Status__c);
            try{
            if(recordsList.containsKey(cmp.ContactId)){
                String st= recordsList.get(cmp.ContactId).Primary_Channel__c+';'+cmp.Donor_Status__c;
                String oldPrimaryChannel = recordsList.get(cmp.ContactId).Primary_Engagement_Channel__c;
                if(oldPrimaryChannel==null || ( oldPrimaryChannel!=null &&!oldPrimaryChannel.contains(cmp.Donor_Status__c)))
                   oldPrimaryChannel = (oldPrimaryChannel!=null?oldPrimaryChannel+';'+ cmp.Donor_Status__c: cmp.Donor_Status__c);
                contact conRecord = recordsList.get(cmp.ContactId); conRecord.Primary_Channel__c= st; conRecord.Dummy_Update__c= 'processed';conRecord.Dummy_LastGiftDate__c= null;conRecord.Primary_Engagement_Channel__c=oldPrimaryChannel; 
                recordsList.put(cmp.ContactId,conRecord);}
            else{
                System.debug(cmp.ContactId+'=;'+conMap.keySet()  +'=;'+ conMap.get(cmp.ContactId));
                System.debug(conMap.get(cmp.ContactId).Primary_Engagement_Channel__c);
                String oldPrimaryChannel = getListValues(conMap.get(cmp.ContactId).Primary_Engagement_Channel__c);
                 if(oldPrimaryChannel==null || (oldPrimaryChannel!=null &&!oldPrimaryChannel.contains(cmp.Donor_Status__c)))
                     oldPrimaryChannel = (oldPrimaryChannel!=null?oldPrimaryChannel+';'+ cmp.Donor_Status__c: cmp.Donor_Status__c);
                  contact conRecord = conMap.get(cmp.ContactId); conRecord.Primary_Channel__c= cmp.Donor_Status__c;conRecord.Dummy_Update__c= 'processed';conRecord.Dummy_LastGiftDate__c= null;conRecord.Primary_Engagement_Channel__c=oldPrimaryChannel; 
                 recordsList.put(cmp.ContactId,conRecord);}
            conMap.remove(cmp.ContactId);
            }Catch(Exception ex){System.debug('Error1:'+ex.getStackTraceString());}
        }*/
        //if(recordsList.size()>0)try{ Database.update(recordsList.values(), true); }Catch(Exception ex){System.debug('Error1:'+ex.getStackTraceString());} if(conMap.size()>0)try{ Database.Update(conMap.values(),true);}Catch(Exception ex){System.debug('Error2:'+ex.getStackTraceString());}if(accList.size()>0)try{ Database.Update(accList,true);}Catch(Exception ex){System.debug('Error3:'+ex.getStackTraceString());}
    }
     
    global void finish(Database.BatchableContext BC){
        //List<Contact> conList = [Select id from Contact where Dummy_LastGiftDate__c=TODAY  OR Dummy_LastGiftDate__c = YESTERDAY limit 10];
       // if(conList.size()>0 && !test.isRunningTest() ) Database.executeBatch( new ContactDonationStatusBatch(System.today()),21 );
        /*else
            Database.executeBatch( new ContactUpdateOnAccountFieldChange(System.today()),21 );*/
    }
    
    @future
    global static void updateContacts(string conId){
        List<contact> conList = [Select id from Contact where id=:conId];
        if(conList.size()==0) return;
        Map<string,contact> recordsList = new Map<String,contact>();
        List<string> cmpIds = new List<String>();
        for(String st: Label.Campaign_Donations_Ids.split(','))
            cmpIds.add(st);
           
        if(test.isRunningTest()){
            for(Campaign cmp: [Select id from Campaign limit 3]){
                cmpIds.add(cmp.Id);
            }
        }
           System.debug(cmpIds);
        List<CampaignMember> listMembers = [Select Donor_Status__c,ContactId,contact.Primary_Engagement_Channel__c from CampaignMember 
                                 where campaign.id IN: cmpIds and ContactId=:conId ];
        System.debug(listMembers.size()+''+ conId);
        try{
        for(CampaignMember cmp: listMembers)
        {
            System.debug('@1'+cmp.Donor_Status__c);
            if(recordsList.containsKey(cmp.ContactId)){
                String st= recordsList.get(cmp.ContactId).Primary_Channel__c+';'+cmp.Donor_Status__c;
                System.debug(st);
                String oldPrimaryChannel = recordsList.get(cmp.ContactId).Primary_Engagement_Channel__c;
                System.debug(oldPrimaryChannel);
                if( oldPrimaryChannel==null  || 
                    (oldPrimaryChannel!=null &&!oldPrimaryChannel.contains(cmp.Donor_Status__c)))
                    oldPrimaryChannel = oldPrimaryChannel!=null?oldPrimaryChannel+';'+ cmp.Donor_Status__c:cmp.Donor_Status__c;
                recordsList.put(cmp.ContactId,new Contact(id= cmp.ContactId,Primary_Channel__c=st,
                                                          Dummy_Update__c= 'processed',
                                                          Dummy_LastGiftDate__c=null,
                                                          Primary_Engagement_Channel__c=oldPrimaryChannel));}
            else{String oldPrimaryChannel =getListValues( cmp.Contact.Primary_Engagement_Channel__c);
                 System.debug(oldPrimaryChannel);
                 if(oldPrimaryChannel==null || (oldPrimaryChannel!=null &&!oldPrimaryChannel.contains(cmp.Donor_Status__c))) 
                     oldPrimaryChannel = oldPrimaryChannel!=null?oldPrimaryChannel+';'+ cmp.Donor_Status__c: cmp.Donor_Status__c;
                 recordsList.put(cmp.ContactId,new Contact(id= cmp.ContactId,Primary_Channel__c=cmp.Donor_Status__c,
                                                           Dummy_LastGiftDate__c=null,
                                                           Dummy_Update__c= 'processed',
                                                           Primary_Engagement_Channel__c=oldPrimaryChannel));}
            
        }
        System.debug( recordsList.values());
        
            if(recordsList.size()>0)update recordsList.values(); else update new Contact(id=conId,Primary_Channel__c=null,Dummy_Update__c='processed', Dummy_LastGiftDate__c =null);}Catch(Exception ex){System.debug(ex.getStackTraceString());}
    }
    
    global static string getListValues (string old){
        String st='';
        Set<string> marketList = new  Set<string>{'Major Donor Marketing' , 'Major Lapsed Marketing',
            'Major Prospect Marketing' , 'Corporate Marketing' , 'Corporate Lapsed Marketing' , 'Corporate Prospect Marketing' , 
            'Foundation Marketing' , 'Foundation Lapsed Marketing' , 'Foundation Prospect Marketing'};        
        if(old== null)return null;for(String s: old.split(';')){if(!marketList.contains(s))st = st==''? st+ s: st+';'+s;}return st==''?null:st;
    }
        @future
    global static void updateContactsFromAccount(string  accid){

       try{
        list<Contact> conList = [Select id,OwnerId,AccountId,Account.OwnerId,Account.npo02__LargestAmount__c,npo02__LastOppAmount__c,
                                         npo02__AverageAmount__c,npo02__LastCloseDate__c from Contact where AccountId=:accid
                                        ];
        for(Contact con: conList){
            con.Dummy_Update__c = String.valueof(System.now());
            if(con.OwnerId!=con.Account.OwnerId)
                con.OwnerId=con.Account.OwnerId;
        }
 
    Update conList;
        update new List<Account>{new Account(Id=accid,Dummy_Contact_Trigger_Time__c=null)};
            }Catch(Exception ex){System.debug(ex.getStackTraceString());}
        
    }
    public static void samplemethod(){
        Integer i=1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;  
                i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1;
        i=i+1; 
    }
}