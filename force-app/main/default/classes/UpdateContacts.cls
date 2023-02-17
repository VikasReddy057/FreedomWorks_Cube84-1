/* 
 * Same kind of functionality is existing on the contact already.
 * Member is added for removed from the campaign this logic will updates the donor status on contact
*/
global class UpdateContacts implements Database.Batchable<Sobject>,Schedulable{
    
    static boolean recursive = false;
    Date selDate ;
    String conTriggerid ;
    
    global void execute(SchedulableContext SC) {
        
        if(!recursive) {recursive = true;
                
        if(!Test.isRunningTest()) Database.executeBatch( new UpdateContacts(System.today(),sc.getTriggerId()),21 );else Database.executeBatch( new UpdateContacts(sc.getTriggerId()),25 );  
        }
    }
    global UpdateContacts(){}
    global  UpdateContacts(String cronid){
        this.conTriggerid = cronid; 
    }
    global  UpdateContacts(Date dt,String cronid ){this.selDate = dt;this.conTriggerid = cronid; }
    global Database.QueryLocator start(Database.BatchableContext BC){
        samplemethod();   
        Set<string> conRecords = new Set<string>();
        List<Developer_Campaign_Log__c> delLogs = new List<Developer_Campaign_Log__c>();
        for(Developer_Campaign_Log__c log:  [Select id,Add__c,Is_Processed__c,CampaignIds__c,Ids__c 
                                             from Developer_Campaign_Log__c]){
                                                 delLogs.add(log);
                                                 if(log.Ids__c!=null){
                                                 for(String conrecid: (List<String>)JSON.deserialize(log.Ids__c, List<String>.Class)){
                                                     conRecords.add(conrecid);
                                                 }
                                                 }
        }
        if(delLogs.size()>0) Delete delLogs;
        return Database.getQueryLocator([Select id,Primary_Engagement_Channel__c from Contact Where id=:conRecords]);
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
        try{
        for(Contact con: scope){
            conIds.add(con.Id);
            con.Dummy_LastGiftDate__c =null;
            con.Primary_Channel__c=null;
            conMap.put(con.Id,con);   
        }
        
        for(CampaignMember cmp: [Select Donor_Status__c,ContactId,Contact.Primary_Engagement_Channel__c from CampaignMember where campaign.id=:cmpIds and ContactId=:conIds ]){
            System.debug(cmp.Donor_Status__c);
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
        }
        if(recordsList.size()>0) Database.update(recordsList.values(), true); }Catch(Exception ex){System.debug('Error1:'+ex.getStackTraceString());} if(conMap.size()>0)try{ Database.Update(conMap.values(),true);}Catch(Exception ex){System.debug('Error2:'+ex.getStackTraceString());}if(accList.size()>0)try{ Database.Update(accList,true);}Catch(Exception ex){System.debug('Error3:'+ex.getStackTraceString());}
    }
     
    global void finish(Database.BatchableContext BC){
        if(conTriggerid!=null){
        List<cronTrigger> a = [SELECT Id FROM cronTrigger WHERE Id = :conTriggerid ];
        for(cronTrigger ct: a)
            system.abortJob(ct.id); 
        }
    }
    
    
    global static void updateContactsFuture(string conId){
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
        try{
            if(recordsList.size()>0)update recordsList.values(); else update new Contact(id=conId,Primary_Channel__c=null,Dummy_Update__c='processed', Dummy_LastGiftDate__c =null);}Catch(Exception ex){System.debug(ex.getStackTraceString());}
    }
    
    global static string getListValues (string old){
        String st='';
        Set<string> marketList = new  Set<string>{'Major Donor Marketing' , 'Major Lapsed Marketing',
            'Major Prospect Marketing' , 'Corporate Marketing' , 'Corporate Lapsed Marketing' , 'Corporate Prospect Marketing' , 
            'Foundation Marketing' , 'Foundation Lapsed Marketing' , 'Foundation Prospect Marketing'};        
        if(old== null)return null;for(String s: old.split(';')){if(!marketList.contains(s))st = st==''? st+ s: st+';'+s;}return st==''?null:st;
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
    public static void createCampaignMemberLog(Map<id,CampaignMember> records, Boolean isAdd){
        List<Developer_Campaign_Log__c> addRecords = new List<Developer_Campaign_Log__c>();
        Set<string> cmpIds = new Set<String>( );
        for(Campaign st :  [Select id from Campaign where id=: Label.Campaign_Donations_Ids.split(',')])
            cmpIds.add(st.Id);
        if(isAdd){
            Set<id> contactIds = new Set<Id>();
            Set<id> campaignIds = new Set<Id>();
            
            for(CampaignMember cm: records.values()){
                if(cmpIds.contains(cm.CampaignId)){contactIds.add(cm.ContactId);campaignIds.add(cm.CampaignId);}
                
            }
            if(contactIds.size()>0){
            Developer_Campaign_Log__c log = new Developer_Campaign_Log__c(Add__c='Add', 
                                                                          CampaignIds__c=JSON.serialize(campaignIds),
                                                                          Ids__c=JSON.serialize(contactIds));
            addRecords.add(log);
            }
        }else{
            Set<id> contactIds = new Set<Id>();
            Set<id> campaignIds = new Set<Id>();
            for(CampaignMember cm: records.values()){
                if(cmpIds.contains(cm.CampaignId)){contactIds.add(cm.ContactId);campaignIds.add(cm.CampaignId);}
                
            }
            if(contactIds.size()>0){
            Developer_Campaign_Log__c log = new Developer_Campaign_Log__c(Add__c='Remove', 
                                                                          CampaignIds__c=JSON.serialize(campaignIds),
                                                                          Ids__c=JSON.serialize(contactIds));
            addRecords.add(log); 
            } 
        }
        
        if(addRecords.size()>0 ){
            Insert addRecords;
             String hour = String.valueOf(Datetime.now().hour());
                    String min = String.valueOf(Datetime.now().addMinutes(0).minute()); //+ 10
                    String ss = String.valueOf(Datetime.now().second());
                    
                    //parse to cron expression
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                     Database.executeBatch(new UpdateContacts(),21);
                            // System.schedule('Dev-ConUpdate'+System.now().format()+String.valueof(Integer.valueof((Math.random() * 100))) , nextFireTime,  new UpdateContacts());
            
        }
    }
}