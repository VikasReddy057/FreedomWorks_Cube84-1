global class PostUpUpdateRecipientQueueBatch Implements Database.Batchable<sobject>,Schedulable,Database.Stateful, Database.AllowsCallouts{
    static boolean recursive = false;
    global id conTriggerid ;
    global List<Postup_Contact_Log__c>  campaignMemberlogs = new List<Postup_Contact_Log__c>();
    global List<string> campaignIds;
    
    global void execute (SchedulableContext sc)
    {
        database.executeBatch( new PostUpUpdateRecipientQueueBatch(sc.getTriggerId()),50 );
    }
    Global PostUpUpdateRecipientQueueBatch (){
        
    }    
    Global PostUpUpdateRecipientQueueBatch (Id scId){
        conTriggerid = scId;
    }
	//Implements Database.Batchable<sobject> 
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> CampaignMemberIds = new Set<String>();
        //List<Postup_Contact_Log__c> logsList = new List<Postup_Contact_Log__c>();
        for(Postup_Contact_Log__c log : [Select id,CampaignMembersData__c from Postup_Contact_Log__c where UpdateRecipients__c =true AND Contact__c!=null])
        {
            campaignMemberlogs.add(log);
            //logsList.add(log);
            if(log.CampaignMembersData__c!=null && log.CampaignMembersData__c.length()>5){
            List<string> ls2 = (List<string>)JSON.deserialize(log.CampaignMembersData__c,List<string>.class);    

            System.debug(ls2);
            for(Object cm: ls2)
            	CampaignMemberIds.add((string)cm);
            }
        }

        string query = 'select id, leadId,CampaignId,CreatedDate, Contact.Id, PostUp_Status__c, recipientId__c, Campaign.id, Campaign.Name,'+
            'Campaign.sync_with_postup__c, Campaign.ListId__c,'+ 
            'Campaign.IsActive from CampaignMember where id=:CampaignMemberIds AND  Campaign.sync_with_postup__c = true AND '+
            'recipientId__c !=null  AND leadId = null Order by CreatedDate ASC';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember > scope){
        Map<String,CampaignMember > CampaignMemberrecords = new Map<String,CampaignMember > ();
        
        for(CampaignMember member: scope){   
            try{                                            
                PostUpSubscriptionController.updateSubscriptionImplementation((Integer)member.campaign.ListId__c, (Integer)member.recipientId__c, member.PostUp_Status__c);       
            }Catch(Exception ex){
                System.debug(ex.getMessage()+ex.getStackTraceString());
                member.PostUpSyncError__c = ex.getMessage()+ex.getStackTraceString();
                CampaignMemberrecords.put(member.Id,member);
            }      
            
        }
         if(campaignMemberlogs.size()>0)
        Delete campaignMemberlogs;
        campaignMemberlogs.clear();       
        if(CampaignMemberrecords.size()>0)
            update CampaignMemberrecords.values();
    }
    
    //Finish method can be used for sending an email once batch is completed. 
    global void finish(Database.BatchableContext BC){

        List<Postup_Contact_Log__c> logList = [Select id,CampaignIdsData__c from Postup_Contact_Log__c  
                                          where   UpdateRecipients__c =true AND Contact__c!=null limit 100];
        
        
        if(!Test.isRunningTest() && logList.size()>0){
            database.executeBatch( new PostUpUpdateRecipientQueueBatch(conTriggerid),50 );
        }else if (conTriggerid!=null){
            List<cronTrigger> a = [SELECT Id FROM cronTrigger WHERE Id = :conTriggerid ];
            for(cronTrigger ct: a)
            system.abortJob(ct.id);  
        }
    }    

}