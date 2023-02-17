@isTest
public class ContactMergeCampaignTest {
    public static TestMethod void test() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=123);
        insert campaign;
        Campaign[] campaignList = new List<Campaign>();
        campaignList.add(campaign);
        Test.startTest();
        ContactMergeCampaign.setCampaign(campaignList);
        Test.stopTest();
    }
    public static TestMethod void testGetMethod() {
        Campaign campaign = new Campaign(name='test', sync_with_postup__c=true, ListId__c=123);
        insert campaign;
        Campaign[] campaignList = new List<Campaign>();
        campaignList.add(campaign);
        ContactMergeCampaign.setCampaign(campaignList);
        Test.startTest();
        Campaign[] campaignListget = ContactMergeCampaign.getCampaign();
        Test.stopTest();
        System.assertEquals(campaignList, campaignListget);
    }
}