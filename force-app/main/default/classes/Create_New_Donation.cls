public class Create_New_Donation {

    @AuraEnabled
    public static account getAccount(String accountId) {
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :accountId];
        return acc;
    }
    
    @AuraEnabled
    public static void createDonation(String name,string clsdt, string checkname, string org, 
                                      string amt, String dsource,string checkNo,String bNo,
                                      String oFEC, String EFEC,string accId) {
                                          try{
                                          System.debug(clsdt);
                                              System.debug(checkname);
                                              System.debug(org);
                                              System.debug(amt);
                                              System.debug(dsource);
                                              System.debug(checkNo);
                                              System.debug(bNo);
                                              System.debug(oFEC);
                                              System.debug(EFEC);
                                              System.debug(accId);
        String gsRecordTypeID = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('DirectMail Donation').getRecordTypeId();
        Opportunity opp= new Opportunity(name = name,  RecordTypeId= gsRecordTypeID);
        opp.CloseDate = (string.isNotBlank(clsdt)?date.valueOf(clsdt):system.today());
        opp.CheckNumber__c = checkNo;
        opp.Batch_Number__c = bno;
        opp.AccountId  = accId;
        opp.Donation_Source__c =dsource;
        opp.Name_on_Check_if_Different__c =  checkname ;
        opp.Designated_Organization__c = org;
        opp.Amount = string.isNotBlank(amt)?Decimal.valueOf(amt) :0.00;
        opp.Payment_Type__c = 'Check';
        opp.Processed_By__c = 'In House Deposit';
        opp.StageName ='Received';
        opp.Occupation_for_FEC_Reports__c = oFEC;
        opp.Employer_for_FEC_Reports__c = EFEC;                                  
                                 
                                              
        Insert Opp;    
                                          System.debug('Opp'+Opp.Id);
                                          }Catch(Exception e){
                                              system.debug('@'+e.getMessage()+e.getStackTraceString());
                                              throw new AuraHandledException(e.getMessage());
                                          }
        
    }    
}