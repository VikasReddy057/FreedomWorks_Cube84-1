/*
* 1. For Campaign Delete in Salesforce Changing the PostUp List Name 
* 2. For Campaign UnSync in Salesforce Remove the ListId from the Campaign Field
* 3. Showing the error while the campaign has Salesforce Lead as a campaign member 
* 4. Update Campaign Name for Change in isActive field in Campaign
*/
trigger CampaignPostUpSync on Campaign (after insert, before update, before delete) {
    if(!System.isFuture() && !System.isBatch() && !System.isScheduled() && !System.isQueueable()) {
        if(trigger.isDelete){
            System.debug('CampaignPostUpSync : Delete Campaign');
            Set<ID> ids = Trigger.oldMap.keySet();
            Campaign[] campaigns = [select id, name, ListId__c from Campaign where id in: ids AND sync_with_postup__c = true AND ListId__c != null];
            Database.executeBatch(new CampaignDeletionBatch(campaigns));    
        }
        
        else {
            System.debug('CampaignPostUpSync : Insert or Update Campaign');
            String listTitle;
            String postUpStatus;
            Set<ID> ids = Trigger.newMap.keySet();
            CampaignMember[] leadMembers = [select leadId from CampaignMember where CampaignId in: ids AND campaign.sync_with_postup__c = true AND leadId != null limit 50];
            if(!leadMembers.isEmpty()) {
                for(Campaign campaign : Trigger.new) {
                    for(CampaignMember leadMember : leadMembers) {
                        if(leadMember.campaignId == campaign.id) {
                            trigger.newMap.get(campaign.Id).addError('Campaign should not contain Lead');
                        }
                    }
                }
            }     
            for (Campaign campaign: Trigger.new) {
                if(campaign.sync_with_postup__c) {
                    if(campaign.IsActive) {
                        postUpStatus = 'NORMAL';
                        listTitle = campaign.Name + ' | ' + campaign.Id;
                    }
                    else {
                        postUpStatus = 'NORMAL';
                        listTitle = 'ARCHIVED | ' + campaign.Name + ' | ' + campaign.Id; 
                    }
                    if(campaign.ListId__c != null && trigger.isUpdate) {
                        System.debug('CampaignPostUpSync : Update Campaign field isActive');
                        System.debug('isActive new = '+ Trigger.newMap.get(campaign.id).IsActive +' & isActive new old =' + Trigger.oldMap.get(campaign.id).IsActive);
                        if(Trigger.newMap.get(campaign.id).IsActive != Trigger.oldMap.get(campaign.id).IsActive) {
                            Database.executeBatch(new PostUpListBatch(listTitle, campaign.Id, postUpStatus, true, (Integer)campaign.ListId__c));    
                        }
                    }
                    else {
                            //Create new list for sync with Postup
                            //PostUpListController.createList(listTitle, campaign.Id, postUpStatus);
                            Database.executeBatch(new PostUpListBatch(listTitle, campaign.Id, postUpStatus, false, null));
                    }
                }
                if(!campaign.sync_with_postup__c && campaign.ListId__c != null) {
                    campaign.ListId__c = null;
                }
            }
        } 
    }
}