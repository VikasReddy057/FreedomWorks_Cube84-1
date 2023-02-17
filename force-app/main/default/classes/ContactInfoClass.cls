public class ContactInfoClass {

    @AuraEnabled
    public static boolean getCaseLoadusers(String recId) {
        Boolean isvalid = false;
        Contact con = [Select owner.CaseLoad__c,Auto_Fill_Primary_Channel__c,Donor_Status__c from contact where id=:recId];
        if(con.owner.CaseLoad__c || (con.Auto_Fill_Primary_Channel__c!=null 
                                 && (con.Auto_Fill_Primary_Channel__c.contains('Best') 
                                 || con.Donor_Status__c=='Donor' ||con.Auto_Fill_Primary_Channel__c.contains('Major')
                                 || con.Auto_Fill_Primary_Channel__c.contains('Foundation')||
                                 con.Auto_Fill_Primary_Channel__c.contains('Corporate'))) ){
            isvalid = true;
        }                                   
        
           return isvalid;
    }
}