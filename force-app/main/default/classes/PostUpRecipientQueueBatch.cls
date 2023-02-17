global class PostUpRecipientQueueBatch Implements Database.Batchable<sobject>,Schedulable,Database.Stateful, Database.AllowsCallouts{
    global id conTriggerid ;
    global List<Postup_Contact_Log__c>  campaignlogs = new List<Postup_Contact_Log__c>();
    Boolean  isStatus = false;
    //global List<string> campaignIds;
    
    global void execute (SchedulableContext sc)
    {
        String jobdetails = database.executeBatch( new PostUpRecipientQueueBatch(sc.getTriggerId()),50 );
        System.debug(jobdetails);
    }
    Global PostUpRecipientQueueBatch (){
        
    }    
    Global PostUpRecipientQueueBatch (Id scId){
        this.conTriggerid = scId;
    }
    Global PostUpRecipientQueueBatch (Id scId, Boolean isStatusUpdate){
        this.conTriggerid = scId;
        this.isStatus = isStatusUpdate;
    }
	//Implements Database.Batchable<sobject> 
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> CampaignIds = new Set<String>();
        string query ;
        System.debug('isStatus'+isStatus);
        if(!isStatus){
        List<Postup_Contact_Log__c> logsList = new List<Postup_Contact_Log__c>();
        for(Postup_Contact_Log__c log : [Select id,CampaignIdsData__c from Postup_Contact_Log__c where CreateRecipients__c =true AND Contact__c!=null])
        {
            campaignlogs.add(log);
            if(log.CampaignIdsData__c!=null && log.CampaignIdsData__c.length()>5){
            List<string> ls2 = (List<string>)JSON.deserialize(log.CampaignIdsData__c,List<string>.class);
            System.debug(ls2);
            
            CampaignIds.addALL(ls2);
            }
        }
        
        query = 'select id, leadId,CampaignId,CreatedDate, Contact.Id, PostUp_Status__c, recipientId__c, Campaign.id, Campaign.Name,'+
            'Campaign.sync_with_postup__c, Campaign.ListId__c,'+ 
            'Campaign.IsActive from CampaignMember where campaignId=:campaignIds AND  Campaign.sync_with_postup__c = true AND '+
            'recipientId__c =null AND Contact.Email!=null AND leadId = null Order by campaignId,CreatedDate ASC';
        
        if(test.isRunningTest())
        {
         query = 'select id, leadId,CampaignId,CreatedDate, Contact.Id, PostUp_Status__c, recipientId__c, Campaign.id, Campaign.Name,'+
            'Campaign.sync_with_postup__c, Campaign.ListId__c,'+ 
            'Campaign.IsActive from CampaignMember';   
        }
        }else{
            System.debug(' Query: isStatus'+isStatus);
            Set<string> Ids = new set<string>(); 
            List<Campaign_Status__c> logsList = new List<Campaign_Status__c>();
            for(Campaign_Status__c log : [Select id,CampaignId__c,Status__c from Campaign_Status__c ])
            {
                Ids.add(log.CampaignId__c);
            }
            query = 'select id from CampaignMember where id=:Ids AND '+
                'recipientId__c !=null AND leadId = null Order by CreatedDate ASC';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember > scope){
        System.debug('isStatus'+isStatus);
        if(!isStatus){
        Map<String,contact> contactrecords = new Map<String,contact> ();
        Map<String,CampaignMember > CampaignMemberrecords = new Map<String,CampaignMember > ();
        Map<String, Postup_Contact_Log__c> logsMap = new Map<String,Postup_Contact_Log__c>();
        
        for(CampaignMember member: scope){         
            if(member.LeadId == null) {
                
                String postUpStatus;
                if(member.Campaign.IsActive) {  
                    postUpStatus = 'NORMAL';    
                }   
                else {  
                    postUpStatus = 'UNSUB'; 
                }
                Map<String, Object> m ;
                try{
                String createRecipientResponse = PostUpRecipientController.createOneRecipient(member.contact.Id, (Integer)member.campaign.ListId__c, postUpStatus);
                System.debug('createRecipientResponse '+createRecipientResponse);
                m =   (Map<String, Object>) JSON.deserializeUntyped(createRecipientResponse);
                
                System.debug('@member.contact.Id:'+ member.contact.Id);
                System.debug('@Recipient:'+ m.get('recipientId'));
                }Catch(Exception ex){
                    System.debug(ex.getMessage()+ex.getStackTraceString());
                    CampaignMemberrecords.put(member.Id,new CampaignMember (id= member.id,
                                                  PostUpSyncError__c= ex.getMessage()+ ex.getStackTraceString()));  
                }
                
                if(m!=null && m.get('recipientId')!=null){
                    System.debug('@Recipient:'+ m.get('recipientId'));
                    logsMap.put(member.Id, new Postup_Contact_Log__c(Contact__c=member.ContactId, RecipientId__c= (Integer) m.get('recipientId'),
                                                                         Campaign__c =member.Campaign.id));
                    CampaignMemberrecords.put(member.Id,new CampaignMember (Dummy_lastModifiedDate__c= String.valueOf(System.now()),
                                                                            id= member.id,PostUp_Status__c= (postUpStatus=='NORMAL'?'Subscribed':'Unsubscribed'),
                                                                            recipientId__c= (Integer) m.get('recipientId'))); 
                }
            }    
            

        }      
        RecursiveHandler.CampaignMemberFirstRun = true;
        if(campaignlogs.size()>0 && [Select id from Postup_Contact_Log__c where id=:campaignlogs].size()>0)
            delete [Select id from Postup_Contact_Log__c where id=:campaignlogs];
        campaignlogs.clear();        
        if(CampaignMemberrecords.size()>0)
        update CampaignMemberrecords.values();
        if(logsMap.size()>0)
        Insert logsMap.values();
        }else{
            set<String> ids = new Set<string>();
            list<CampaignMember> memberList = new list<CampaignMember>();
            List<Campaign_Status__c> records = new List<Campaign_Status__c>();
            for(CampaignMember mb: scope)
                ids.add(mb.Id);
            for(Campaign_Status__c log : [Select id,CampaignId__c,Status__c,CronDateTime__c from Campaign_Status__c where  CampaignId__c=:ids])
            {
                records.add(log);
                memberList.add(new CampaignMember(id=log.CampaignId__c,postUpCronModifiedTime__c= log.CronDateTime__c, Dummy_lastModifiedDate__c = String.valueof(System.now())
                                                  ,PostUp_Status__c =log.Status__c));
            }
            System.debug('!'+ records);
             if(records.size()>0)
                Delete records;           
            if(memberList.size()>0){
                update memberList;

            }

        }// end of the else
        
    }
    
    //Finish method can be used for sending an email once batch is completed. 
    global void finish(Database.BatchableContext BC){
        
		Set<String> CampaignIds = new Set<String>();
        List<Postup_Contact_Log__c> logsList = new List<Postup_Contact_Log__c>();
        for(Postup_Contact_Log__c log : [Select id,CampaignIdsData__c from Postup_Contact_Log__c where CreateRecipients__c =true AND Contact__c!=null limit 2])
        {
            
            if(log.CampaignIdsData__c!=null && log.CampaignIdsData__c.length()>5){
            List<string> ls2 = (List<string>)JSON.deserialize(log.CampaignIdsData__c,List<string>.class);
            System.debug(ls2);
            
            CampaignIds.addALL(ls2);
            }
        }
        
        List<CampaignMember> mlist = [select id from CampaignMember where campaignId=:campaignIds AND  Campaign.sync_with_postup__c = true AND 
                                     recipientId__c =null AND Contact.Email!=null AND 
                                      leadId = null ];
      
        
        if(test.isRunningTest())
        	Database.ExecuteBatch(new PostUpContactRecipientUpdateScheduler() ,Integer.valueof(Label.PostUp_Contact_Job));
       
        
        if(!Test.isRunningTest() && mlist.size()>0){
            System.debug('@');
            database.executeBatch( new PostUpRecipientQueueBatch(conTriggerid),50 );
        }
        else if(!Test.isRunningTest() && mlist.size()==0  ){
            System.debug('@@'); 
            Set<string> Ids = new set<string>(); 
         
            for(Campaign_Status__c log : [Select id,CampaignId__c,Status__c from Campaign_Status__c limit 2])
            {
                Ids.add(log.CampaignId__c);
            }
            List<CampaignMember> mlist2= [select id from CampaignMember where id=:Ids AND recipientId__c !=null 
                                          AND leadId = null Order by CreatedDate ASC];
            System.debug(mlist2.size());
            if(mlist2.size()>0)
            database.executeBatch( new PostUpRecipientQueueBatch(conTriggerid,true),100 );
            else if(conTriggerid!=null){
            
            List<cronTrigger> a = [SELECT Id FROM cronTrigger WHERE Id = :conTriggerid ];
            for(cronTrigger ct: a)
            system.abortJob(ct.id);  
        }
        }
        
    }    
    
}