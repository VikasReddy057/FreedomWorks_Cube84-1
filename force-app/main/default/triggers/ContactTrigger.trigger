/*
* 1. For Contact Delete in Salesforce, Global Unsub the recipient in Salesforce 
* 2. For Contact merge Remove child contacts from campaign in Salesforce
* 3. For update in Salesforce Contact, change the same in PostUp Recipient
*/ 
trigger ContactTrigger on Contact (before Insert,after Insert,after delete, before delete, before update,after update) {

    if(Trigger.isBefore && ( Trigger.isInsert)){
        ContactTriggerHandler.isInsert = true;
        ContactTriggerHandler.beforeInsert(trigger.New);
  
    } 
    
    if(Trigger.isAfter && ( Trigger.isInsert)){

             ContactTriggerHandler.afterInsert(trigger.New,trigger.newMap);
            
    }    
    if(Trigger.isBefore && ( Trigger.isUpdate)){
    System.debug(ContactTriggerHandler.beforeUpdateFirstRun);
    System.debug(ContactTriggerHandler.isInsert);
     if(ContactTriggerHandler.beforeUpdateFirstRun && !ContactTriggerHandler.isInsert){
         ContactTriggerHandler.beforeUpdateFirstRun = false;
         ContactTriggerHandler.beforeUpdate(trigger.New,trigger.Old,Trigger.newMap, Trigger.OldMap);
         }
    for(Contact con: trigger.new){
    
        
        if( con.Dummy_Update__c!='processed' && (! (con.Dummy_Update__c!= trigger.oldMap.get(con.id).Dummy_Update__c) &&
        trigger.new.size()==1 && !System.isFuture()  && !system.isBatch())){
            con.Dummy_LastGiftDate__c  = System.today();
            ContactDonationStatusBatch.updateContacts(con.Id);
        }else if( con.Dummy_Update__c!='processed' ){
            con.Dummy_LastGiftDate__c  = System.today();
        }else if(con.Dummy_Update__c== 'processed'){
            con.Dummy_LastGiftDate__c  = null;
            con.Dummy_Update__c='';
        }
        
       
    }
    }
    //if(!Test.isRunningTest()) {
    if(!System.isFuture() && !System.isBatch() && !System.isScheduled() && !System.isQueueable()) {
        //Campaign[] campaignList = new List<Campaign>();
        if(trigger.isDelete && trigger.isBefore) {
            Set<ID> ids = Trigger.oldMap.keySet();
            List<CampaignMember> memberList = [Select campaign.Id, recipientId__c, ContactId, PostUp_Status__c, 
                                               Campaign.Name, Campaign.sync_with_postup__c, Campaign.ListId__c, Campaign.IsActive
                                               from CampaignMember where ContactId in: ids AND leadId = null AND recipientId__c!=null 
                                               AND Campaign.sync_with_postup__c = true AND PostUp_Status__c = 'Subscribed'];
            
                Set<Id> campaignIds = new Set<Id>();
                Set<Id> memberIds = new Set<Id>();
            if(!memberList.isEmpty()) {
                for(CampaignMember member : memberList) {
                    campaignIds.add(member.CampaignId);
                    memberIds.add(member.Id);
                }
            }
                List<Campaign> campaignList = [select id, ListId__c, name, isActive from Campaign where id in : campaignIds];
                System.debug('campaignList='+campaignList);
                ContactMergeCampaign.setCampaign(campaignList);
                System.debug('memberList= '+memberList);  
                if(memberList.size() > 0 && !test.isRunningTest()) {
                    Database.executeBatch(new PostUpRecipientUnSubBatch('Unsubscribed', memberIds, memberList), 20); 
                }
                Contact[] contacts = [select id, recipientId__c from Contact where id in :ids AND recipientId__c != null];
                if(contacts.size() > 0 && !test.isRunningTest()) {
                    Database.executeBatch(new ContactDeletionBatch(contacts), 20);    
                }
            }
            if(trigger.isDelete && trigger.isAfter){
                System.debug('ContactTrigger : Delete Contact Trigger After');
                //Set<ID> ids = Trigger.oldMap.keySet(); 
                for(Contact contact : trigger.old) {
                  if(!Test.isRunningTest()) {if(contact.MasterRecordId != null) {Contact masterContact = [select id from Contact where id =: contact.MasterRecordId];for(Campaign campaign: ContactMergeCampaign.getCampaign()) { CampaignMember member = new CampaignMember();member.CampaignId = campaign.id;member.ContactId = masterContact.id; try{ insert member; } catch(Exception e) {System.debug('Exception is '+e.getMessage());} } }}
                } 
            }
            if(trigger.isUpdate && trigger.isAfter){
                if(ContactTriggerHandler.afterUpdateFirstRun && !ContactTriggerHandler.isInsert){
                 ContactTriggerHandler.afterUpdateFirstRun = false;
                 ContactTriggerHandler.afterUpdate(trigger.New,trigger.Old,Trigger.newMap, Trigger.OldMap);
                 }            
            
                System.debug('ContactTrigger : Update Contact');
                List<string> records = new List<String>();
                if(trigger.New.size()==1){
                    if(trigger.New[0].recipientId__c != null && !test.isRunningtest())                      
                        PostUpRecipientController.updateRecipient(trigger.New[0].Id, (Integer)trigger.New[0].recipientId__c);
                }
                else {
                    for(Contact con : trigger.new) {
                        if((con.recipientId__c!=null && !System.isBatch() ) || 
                            (con.recipientId__c!=null && System.isBatch() && 
                              (trigger.oldMap.get(con.id).Dummy_Update__c!= con.Dummy_Update__c  || trigger.oldMap.get(con.id).recipientId__c == con.recipientId__c ) 
                            )
                           || test.isRunningTest())
                        records.add(con.Id);
                    }
                    if(records.size()>0)
                    {
                    insert new Postup_Contact_Log__c(Contact__c=records[0],
                                                     ContactResponse__c=JSON.serialize(records),
                                                     ContactUpdate__c = true);
                    String jobName = 'Postup-UpdateContact='+ System.Today().format();
                    String hour = String.valueOf(Datetime.now().hour());
                    String min = String.valueOf(Datetime.now().addMinutes(10).minute()); //+ 10
                    String ss = String.valueOf(Datetime.now().second());
                    
                    //parse to cron expression
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                    
                    PostupUpdateContactQueueBatch jobInstance  = new PostupUpdateContactQueueBatch();                     
                    List<AsyncApexJob> apexjobs=  [SELECT ApexClass.Name , JobType, Status FROM AsyncApexJob where JobType= 'BatchApex' AND 
                                                   status IN('Preparing','Processing')  AND ApexClass.Name='PostupUpdateContactQueueBatch'];
                    
                    List<cronTrigger> cron= [select Id,CronJobDetail.Name from CronTrigger where CronJobDetail.Name =:jobName  ];
                    if( apexjobs.size()==0 && cron.size()==0){
                        //for(cronTrigger ct: cron)
                            //System.abortJob(ct.Id);
                        System.schedule(jobName , nextFireTime, jobInstance );
                    }/*else if(apexjobs.size()==0 ){
                        System.schedule(jobName , nextFireTime, jobInstance );
                    } */   
                    }
                }
            }
        }
}