@isTest
public class SplitCampaignTest {

    @isTest
    public static void method1(){
        String cm1 = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Advocacy Campaign').getRecordTypeId();
		String cmr2 = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Text Campaign').getRecordTypeId();

        Campaign cm= new Campaign(name='test',recordTypeId=cm1);
        Insert cm;
        Campaign cm2= new Campaign(name='test',recordTypeId=cmr2);
        Insert cm2;
        Contact con = new contact(LastName='test',Email='test@test.com');
        Insert con;
        Campaignmember cmm = new CampaignMember(contactid=con.id,Campaignid=cm.id);
        Insert cmm;
        Campaignmember cmm2 = new CampaignMember(contactid=con.id,Campaignid=cm2.id);
        Insert cmm2;        
        SplitCampaignCtrl.getData('Marketing List',con.Id, 'HistoricalCampaigns', 'Historical Campaigns');
        //SplitCampaignCtrl.getData('Marketing List',con.Id, 'ActiveCampaign', 'Active Campaigns');
    }
        @isTest
    public static void method2(){
        String cm1 = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Advocacy Campaign').getRecordTypeId();
		String cmr2 = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Text Campaign').getRecordTypeId();

        Campaign cm= new Campaign(name='test',recordTypeId=cm1);
        Insert cm;
        Campaign cm2= new Campaign(name='test',recordTypeId=cmr2);
        Insert cm2;
        Contact con = new contact(LastName='test',Email='test@test.com');
        Insert con;
        Campaignmember cmm = new CampaignMember(contactid=con.id,Campaignid=cm.id);
        Insert cmm;
        Campaignmember cmm2 = new CampaignMember(contactid=con.id,Campaignid=cm2.id);
        Insert cmm2;        
        //SplitCampaignCtrl.getData('Marketing List',con.Id, 'HistoricalCampaigns', 'Historical Campaigns');
        SplitCampaignCtrl.getData('Marketing List',con.Id, 'ActiveCampaign', 'Active Campaigns');
    }
    
            @isTest
    public static void method3(){
        String cm1 = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing List').getRecordTypeId();
		String cmr2 = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Text Campaign').getRecordTypeId();

        Campaign cm= new Campaign(name='test',recordTypeId=cm1);
        Insert cm;
        Campaign cm2= new Campaign(name='test',recordTypeId=cmr2);
        Insert cm2;
        Contact con = new contact(LastName='test',Email='test@test.com');
        Insert con;
        Campaignmember cmm = new CampaignMember(contactid=con.id,Campaignid=cm.id);
        Insert cmm;
        Campaignmember cmm2 = new CampaignMember(contactid=con.id,Campaignid=cm2.id);
        Insert cmm2;        
        //SplitCampaignCtrl.getData('Marketing List',con.Id, 'HistoricalCampaigns', 'Historical Campaigns');
        SplitCampaignCtrl.getData('Marketing List',con.Id, 'MarketList', 'Active Campaigns');
    }
}