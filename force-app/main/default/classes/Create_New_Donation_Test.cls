@isTest
private class Create_New_Donation_Test {

    @isTest
    static void method1(){
    Account acc2 = new Account (name='test');
        insert acc2;
        Create_New_Donation.getAccount(acc2.Id);
        Create_New_Donation.createDonation('tes','2022-03-24',null,'FreedomWorks, Inc','1.0','1','','','','',acc2.Id);
    }
}