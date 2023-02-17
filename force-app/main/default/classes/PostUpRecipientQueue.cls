/*
* 1. Get Campaign Members of campaign to create as PostUp Recipient in PostUp. Get 40 members at a time to avoid too many callouts
*/ 
public class PostUpRecipientQueue implements Queueable, Database.AllowsCallouts {
    
    Set<Id> ids;
    Integer queryLimit;
    Integer queryLimitDummy;
    Integer count; 
    Integer offset;
    Integer limitCount;
    Integer recipientId; 
    String lastid;

    CampaignMember[] campaignMemberList = new List<CampaignMember>();
    Contact[] contactList = new List<Contact>();
   
    
    public PostUpRecipientQueue(Set<Id> ids, String lid, Integer count, Integer limitCount) {
        System.debug('PostUpRecipientQueue : PostUpRecipientQueue');
        this.ids = ids;
        this.count = count;
        this.limitCount = limitCount;
        this.lastid = lid;
    }
    
    
    public void execute(QueueableContext qc) {
        System.debug('PostUpRecipientQueue : execute');
        queryLimit = ([Select id, leadId, Contact.Id, PostUp_Status__c, recipientId__c, Campaign.id, Campaign.Name, Campaign.sync_with_postup__c, Campaign.ListId__c, Campaign.IsActive from CampaignMember where id in :ids AND LeadId=Null]).size();
        queryLimitDummy = queryLimit;
        CampaignMember[] ContactIdList;
        Map<String,contact> contactrecords = new Map<String,contact> ();
        Map<String,CampaignMember > CampaignMemberrecords = new Map<String,CampaignMember > ();
        Map<String, Postup_Contact_Log__c> logs = new Map<String,Postup_Contact_Log__c>();
        Integer cnt=0;
        String lid='';
        do{
            
            ContactIdList = [Select id, leadId, Contact.Id, contact.recipientId__c, Contact.Email, PostUp_Status__c, recipientId__c,
             Campaign.id, Campaign.Name, Campaign.sync_with_postup__c, 
            Campaign.ListId__c, Campaign.IsActive from CampaignMember where id >:lastid AND id in :ids AND LeadId=Null Order by Id Asc limit:limitCount ];
            System.debug('PostUpRecipientQueue : execute'+ids+':'+count +':'+':'+limitCount +':'+lastid );
            for(CampaignMember member : ContactIdList) {
                if(member.LeadId == null) {
                    
                    String postUpStatus;
                    if(member.Campaign.IsActive) {  
                        postUpStatus = 'NORMAL';    
                    }   
                    else {  
                        postUpStatus = 'UNSUB'; 
                    }
                    String createRecipientResponse = PostUpRecipientController.createOneRecipient(member.contact.Id, (Integer)member.campaign.ListId__c, postUpStatus);
                    System.debug('createRecipientResponse '+createRecipientResponse);
                    Map<String, Object> m =   (Map<String, Object>) JSON.deserializeUntyped(createRecipientResponse);
                    
                    lid = member.Id;
                    ids.remove(member.Id);
                    
                    System.debug('@Recipient:'+ m.get('recipientId'));
                    contactrecords.put(member.ContactId,new Contact (id= member.ContactId,recipientId__c= (Integer) m.get('recipientId'))); 
                    logs.put(member.ContactId, new Postup_Contact_Log__c(Contact__c=member.ContactId, RecipientId__c= (Integer) m.get('recipientId'),
                                                                        Campaign__c =member.Campaign.id));
                    CampaignMemberrecords.put(member.Id,new CampaignMember (id= member.id,PostUp_Status__c='Subscribed',recipientId__c= (Integer) m.get('recipientId'))); 
                }
                count++;
                cnt++;
            }
        } while(cnt != ContactIdList.size());
        try{
        RecursiveHandler.CampaignMemberFirstRun = true;
        update CampaignMemberrecords.values();
        update contactrecords.values();
        //Insert logs.values();
        if(queryLimit > count) {
            queryLimitDummy = queryLimitDummy - count;
            if(queryLimitDummy < limitCount) {
                limitCount = queryLimitDummy;
            }
            PostUpRecipientQueue queue = new PostUpRecipientQueue(ids, lid ,count, limitCount); 


                System.enqueueJob(queue);

        }} catch(Exception e) {
                System.debug('Exception ' + e.getStackTraceString()+':=:'+e.getMessage());
            }
        
    }
}