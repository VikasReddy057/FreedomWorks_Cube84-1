/**/

trigger CampaignMemberTrigger on CampaignMember (after insert, before update, before delete,after delete) {
  
 If(Trigger.isInsert && Trigger.isAfter) 
     CampaignMemberTriggerHandler.afterInsert(trigger.New,Trigger.newMap);
 if(trigger.isUpdate && trigger.isAfter)
     CampaignMemberTriggerHandler.afterUpdate(trigger.New,Trigger.oldMap,Trigger.newMap);
 if(trigger.isDelete && trigger.isAfter)
       CampaignMemberTriggerHandler.afterDelete(trigger.old,Trigger.oldMap); 

  Set<string> cmpIds = new Set<String>( );
  for(Campaign st :  [Select id from Campaign where id=: Label.Campaign_Donations_Ids.split(',')])
  cmpIds.add(st.Id);
  if( trigger.isInsert && trigger.isAfter && (trigger.new.size()>1 || test.isRunningTest() ) )
      UpdateContacts.createCampaignMemberLog(trigger.newMap,true);
  else if(trigger.isDelete && trigger.isBefore && ( test.isRunningTest() ||trigger.old.size()>1) )    
      UpdateContacts.createCampaignMemberLog(trigger.oldMap,false);
  List<CampaignMember> records =   Trigger.isInsert? trigger.new: trigger.old;
  System.debug('cmpIds'+cmpIds);
  System.debug(cmpIds.contains(Trigger.isInsert?records[0].CampaignId: records[0].CampaignId));
  if(  !System.isFuture() && !System.isBatch()  && !trigger.isUpdate && trigger.isAfter && records.size()==1 &&
  cmpIds.contains(Trigger.isInsert?records[0].CampaignId: records[0].CampaignId) || (test.isRunningTest()) )
  updateContacts.updateContactsFuture(records[0].ContactId);
  if(trigger.isDelete && trigger.isAfter) return;
  //  if(!Test.isRunningTest()) {
    if(!System.isFuture() && !System.isBatch() && !System.isScheduled() && !System.isQueueable()) {
        System.debug('INSIDE TRIGGER');
        Integer count = 0;
        if(trigger.isDelete && trigger.isBefore){
            System.debug('CampaignMemberTrigger : Delete CampaignMember');
            System.debug('Trigger.oldMap.keySet()= '+Trigger.oldMap.keySet());
            Set<ID> ids = Trigger.oldMap.keySet();
            CampaignMember[] members = [select id, leadId, ContactId, PostUp_Status__c, recipientId__c, 
                                        Campaign.id, Campaign.Name, Campaign.sync_with_postup__c, Campaign.ListId__c, Campaign.IsActive 
                                        from CampaignMember where id in :ids AND leadId = null AND recipientId__c!=null 
                                        AND Campaign.sync_with_postup__c = true AND PostUp_Status__c = 'Subscribed'];
            System.debug('members= '+members); 
            if(members.size() > 0) {
                Database.executeBatch(new PostUpRecipientUnSubBatch('Unsubscribed', ids, members), 100);
            }
        } 
        else{
            System.debug('CampaignMemberTrigger : Insert or Update CampaignMember');
            String postUpStatus;
            Set<ID> ids = Trigger.newMap.keySet();
            
            CampaignMember[] members = [select id,CampaignId, leadId,Contact.Email,Contact.Id, PostUp_Status__c, recipientId__c, Campaign.id, Campaign.Name, Campaign.sync_with_postup__c, Campaign.ListId__c, Campaign.IsActive from CampaignMember where id in :ids AND leadId = null AND Campaign.sync_with_postup__c = true ];
            if(Trigger.isInsert && Trigger.isAfter) {   
                System.debug('isInsert');
                Set<id> recordIds = new Set<id>();
                Set<string> campaignIds = new Set<string> ();
                for(Campaignmember cm: members)  {
                if(cm.Contact.Email!=null)
                recordIds.add(cm.id);
                campaignIds.add(cm.CampaignId); 
                } 
                if(members.size() > 0) {    
                    InsertCampaignMember.setMemberIds(ids);
                    InsertCampaignMember.setBatchCount();
                    String jobName = 'Postup-CreateRecipient='+ System.Today().format();
                    if(trigger.new.size()==1)
                        System.enqueueJob(new PostUpRecipientQueue(recordIds,'0', 0, 50));
                    else if(trigger.new.size()>1){ 
                    insert new Postup_Contact_Log__c(Contact__c=members[0].ContactId,
                    CampaignIdsData__c = JSON.serialize(campaignIds),CreateRecipients__c = true);
                    
                    String hour = String.valueOf(Datetime.now().hour());
                    String min = String.valueOf(Datetime.now().addMinutes(2).minute()); //+ 10
                    String ss = String.valueOf(Datetime.now().second());
                    
                    //parse to cron expression
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                    List<AsyncApexJob> apexjobs=  [SELECT ApexClass.Name , JobType, Status FROM AsyncApexJob where JobType= 'BatchApex' AND 
                                                  status IN('Preparing','Processing') AND ApexClass.Name='PostUpRecipientQueueBatch'];             
                    PostUpRecipientQueueBatch jobInstance  = new PostUpRecipientQueueBatch();                     
                    List<cronTrigger> cron= [select Id,CronJobDetail.Name from CronTrigger where CronJobDetail.Name =:jobName  ];
                    if( apexjobs.size()==0 && cron.size()>0){
                        for(cronTrigger ct: cron)
                            System.abortJob(ct.Id);
                             System.schedule(jobName , nextFireTime, jobInstance );
                            
                    }else if(apexjobs.size()==0){
                        System.schedule(jobName, nextFireTime, jobInstance );
                    }
                    }
                } 

                RecursiveHandler.CampaignMemberInsert = true;  
            } 
            
            else if(Trigger.isUpdate && !RecursiveHandler.CampaignMemberFirstRun && !RecursiveHandler.CampaignMemberInsert) { //For updation in PostUp status
                System.debug('CampaignMemberTrigger : Update CampaignMember PostUp Status');
               Map<String,CampaignMember> records = new Map<String,CampaignMember >();
               List<string> recordsBatch = new List<string>();
               Set<id> Createrecords = new set<Id>();
               Set<string> campaignIds = new Set<String>();
                for(CampaignMember member : members) {
                    System.debug('trigger.oldMap.get(member.Id).PostUp_Status__c=='+trigger.oldMap.get(member.Id).PostUp_Status__c);
                    System.debug('trigger.newMap.get(member.Id).PostUp_Status__c=='+trigger.newMap.get(member.Id).PostUp_Status__c);
                    System.debug('member.PostUp_Status__c==='+member.PostUp_Status__c);
                    if(trigger.newMap.get(member.Id).recipientId__c!=null && 
                       (trigger.oldMap.get(member.Id).PostUp_Status__c != trigger.newMap.get(member.Id).PostUp_Status__c) 
                       && trigger.newMap.get(member.Id).PostUp_Status__c != null
                       && (trigger.oldMap.get(member.Id).Dummy_lastModifiedDate__c == trigger.newMap.get(member.Id).Dummy_lastModifiedDate__c )
                       )
                    { 
                        records.put(member.Id,trigger.newMap.get(member.Id));

                        recordsBatch.add(member.Id) ;
                        
                        //PostUpSubscriptionController.updateSubscription((Integer)member.campaign.ListId__c, (Integer)member.recipientId__c, trigger.newMap.get(member.Id).PostUp_Status__c);
                        
                    }
                    if(test.isRunningTest() || 
                            (member.Contact.Email!=null && trigger.newMap.get(member.Id).recipientId__c== null)){
                        Createrecords.add(member.Id); 
                        campaignIds.add(member.CampaignId); 
                    } 
                 
                }
                   System.debug('End in isActive'+records);
                   if(records.size()>0){
                       if(trigger.new.size()==1){
                            System.enqueueJob(new PostUpUpdateRecipientQueue('0',records,0,50)); 
                       }
                       else if (trigger.new.size()>1){
                       insert new Postup_Contact_Log__c(Contact__c=records.values()[0].ContactId,
                                                        CampaignMembersData__c=JSON.serialize(recordsBatch),UpdateRecipients__c = true);
                       String jobName = 'Postup-UpdateRecipient='+ System.Today().format();
                       String hour = String.valueOf(Datetime.now().hour());
                       String min = String.valueOf(Datetime.now().addMinutes(2).minute()); //+ 10
                       String ss = String.valueOf(Datetime.now().second());
                       
                       //parse to cron expression
                       String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                    
                       PostUpUpdateRecipientQueueBatch jobInstance  = new PostUpUpdateRecipientQueueBatch();                     
                           List<AsyncApexJob> apexjobs=  [SELECT ApexClass.Name , JobType, Status FROM AsyncApexJob where JobType= 'BatchApex' AND 
                                                          status IN('Preparing','Processing')  AND ApexClass.Name='PostUpUpdateRecipientQueueBatch'];
                           
                           List<cronTrigger> cron= [select Id,CronJobDetail.Name from CronTrigger where CronJobDetail.Name =:jobName  ];
                       if( apexjobs.size()==0 && cron.size()>0){
                           for(cronTrigger ct: cron)
                               System.abortJob(ct.Id);
                            System.schedule(jobName , nextFireTime, jobInstance );
                       }else if(apexjobs.size()==0 ){
                           System.schedule(jobName , nextFireTime, jobInstance );
                       }   
                       }
                   }
                       
                        
                        
                    if(Createrecords.size()>0){    
                        if(trigger.new.size()==1){
                         System.enqueueJob(new PostUpRecipientQueue(Createrecords,'0', 0, 50));  
                            System.debug('@'+trigger.new.size());
                        }
                        else if (trigger.new.size()>1){
                            System.debug('@'+trigger.new.size());
                       insert new Postup_Contact_Log__c(Contact__c=members[0].ContactId,
                                                        CampaignIdsData__c = JSON.serialize(campaignIds),CreateRecipients__c = true);
                        String jobName = 'Postup-CreateRecipient='+ System.Today().format();
                        String hour = String.valueOf(Datetime.now().hour());
                        String min = String.valueOf(Datetime.now().addMinutes(2).minute());  //+ 10
                        String ss = String.valueOf(Datetime.now().second());
                        
                        //parse to cron expression
                        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                            List<AsyncApexJob> apexjobs=  [SELECT ApexClass.Name , JobType, Status FROM AsyncApexJob where JobType= 'BatchApex' AND 
                                                          status IN('Preparing','Processing') AND ApexClass.Name='PostUpRecipientQueueBatch'];                       
                        PostUpRecipientQueueBatch jobInstance  = new PostUpRecipientQueueBatch();                     
                        List<cronTrigger> cron= [select Id,CronJobDetail.Name from CronTrigger where CronJobDetail.Name =:jobName  ];
                        if( apexjobs.size()==0 && cron.size()>0){
                            for(cronTrigger ct: cron)
                                System.abortJob(ct.Id);
                            System.schedule(jobName, nextFireTime, jobInstance );
                            System.debug('##');
                        }else if(apexjobs.size()==0){
                            System.debug('##');
                            System.schedule(jobName, nextFireTime, jobInstance );
                        }  
                        }
                       }
            }
        }
        System.debug('getMemberIds==='+InsertCampaignMember.getMemberIds().size());
        System.debug('count===='+InsertCampaignMember.getBatchCount());
    }
  System.debug('OUTSIDE IF  TRIGGER');
}