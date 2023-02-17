public class CampaignMemberCls {
 @InvocableMethod(label='Add to campaign' description='' category='campaign')
  public static void addMembers(List<Request> recordIds) {
      system.debug(recordIds);
      if(recordIds.isEmpty())return;
      
      list<id> lsr = new list<id>();
      for(Request  d: recordIds){
          lsr.add(d.ids[0]);
      }
      system.debug(lsr);
      List<CampaignMember> cmlst = new List<CampaignMember>();
      for(OCP__ContactMessageAssociation__c cma: [select id,CampaignId__c,OCP__Contact__c from OCP__ContactMessageAssociation__c where id=:lsr]){
          CampaignMember cm = new CampaignMember(status='Sent',campaignId=cma.CampaignId__c, ContactId=cma.OCP__Contact__c);
          cm.UniqueId__c=cma.CampaignId__c+cma.OCP__Contact__c;
          cmlst.add(cm);
      }
      system.debug(cmlst);
      if(cmlst.size()>0){
          Database.upsert( cmlst, CampaignMember.Fields.UniqueId__c );
      }
          
  }
    public class Request {
        @InvocableVariable(label = 'Record Ids' description= 'Specify the record Ids for which you want to process' required = true)
        public List<Id> ids;
    }
}