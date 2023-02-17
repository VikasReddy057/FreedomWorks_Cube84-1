@isTest
public class CampaignMemberClsTest {

    @isTest static void method1(){
        contact con = new contact(lastName='test',email='test@test.com');
        insert con;
        campaign cm = new campaign(name='test');
        Insert cm;
        OCP__Message__c m =  new OCP__Message__c(name='test',campaign__c=cm.Id);
        Insert m;
        OCP__ContactMessageAssociation__c cma= new OCP__ContactMessageAssociation__c(OCP__Contact__c=con.Id,OCP__Message__c=m.Id);
        Insert cma;
        CampaignMemberCls.Request r= new CampaignMemberCls.Request();
        r.ids = new List<id>{cma.id};
        CampaignMemberCls.addMembers(new list<CampaignMemberCls.Request>{r});
    }
}