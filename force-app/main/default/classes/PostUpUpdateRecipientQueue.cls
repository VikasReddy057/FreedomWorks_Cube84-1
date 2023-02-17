public class PostUpUpdateRecipientQueue implements Queueable, Database.AllowsCallouts {
    Map<String,CampaignMember> allMembers= new Map<String,CampaignMember>();
    
    Integer queryLimit;
    Integer queryLimitDummy;
    Integer count; 
    Integer offset;
    Integer limitCount;
    Integer recipientId; 
    String lastid;

    Contact[] contactList = new List<Contact>();
    
    public PostUpUpdateRecipientQueue( String lid, Map<String,CampaignMember> records, Integer count, Integer limitCount) {
        System.debug('PostUpUpdateRecipientQueue : PostUpUpdateRecipientQueue');
    
        this.count = count;
        this.limitCount = limitCount;
        this.lastid = lid;
        this.allMembers = records;
    }
    
    
    public void execute(QueueableContext qc) {
        System.debug('PostUpRecipientQueue : execute');
        queryLimit = allMembers.size();
        queryLimitDummy = queryLimit;
        CampaignMember[] ContactIdList;

        Map<String,CampaignMember > CampaignMemberrecords = new Map<String,CampaignMember > ();
        Integer cnt=0;
        String lid='';
        ContactIdList = [Select id, leadId, Contact.Id,Contact.Email, PostUp_Status__c, recipientId__c, Campaign.id, Campaign.Name, Campaign.sync_with_postup__c, Campaign.ListId__c, Campaign.IsActive from CampaignMember where id >:lastid AND id in :allMembers.keySet() AND LeadId=Null Order by Id Asc limit:limitCount ];
        for(Integer i=0; i<ContactIdList.size();i++){
            
            System.debug('PostUpUpdateRecipientQueue : execute'+allMembers.size()+':'+count +':'+limitCount +':'+lastid );
            System.debug('PostUpUpdateRecipientQueue : execute'+allMembers.keyset() );
            CampaignMember member = ContactIdList[i]; 
                    
                    
            PostUpSubscriptionController.updateSubscriptionImplementation((Integer)member.campaign.ListId__c, (Integer)member.recipientId__c, allMembers.get(member.Id).PostUp_Status__c);
            allMembers.remove(member.id);
            lid = member.Id;
            count++;
            cnt++;
            
        }
        if(queryLimit > count) {
            System.debug('@While');
            System.debug('PostUpUpdateRecipientQueue : execute'+allMembers.size()+':'+count +':'+limitCount +':'+lastid );
            System.debug('PostUpUpdateRecipientQueue : execute'+allMembers.keyset() );
            queryLimitDummy = queryLimitDummy - count;if(queryLimitDummy < limitCount) {limitCount = queryLimitDummy;}
            PostUpUpdateRecipientQueue queue = new PostUpUpdateRecipientQueue(lid,allMembers, count, limitCount); 
            try{System.enqueueJob(queue);}
            catch(Exception e) {System.debug('Exception ' + e);}}
        
    }
}