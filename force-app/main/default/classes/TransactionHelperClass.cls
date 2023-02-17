public class TransactionHelperClass {
    Public static boolean  afterUpdateFirstRun = true;
    public static boolean isInsert = false;
    public static void beforeUpdate(List<bt_stripe__Transaction__c> newRecords,List<bt_stripe__Transaction__c> oldRecords, 
                                    Map<Id,bt_stripe__Transaction__c> newMap,Map<Id,bt_stripe__Transaction__c> oldMap ){
                                       
                                       autoLeadConversion(newRecords,oldMap);
                                    }  
    public static void beforeInsert(List<bt_stripe__Transaction__c> newRecords ){
                                       
                                        autoLeadConversion(newRecords,null);
                                    }  
    public static void autoLeadConversion(List<bt_stripe__Transaction__c> newRecords, Map<Id,bt_stripe__Transaction__c> oldMap ){
         Set<id>  leadIds = new Set<Id>();              
         for(bt_stripe__Transaction__c trn: newRecords){
             if(oldMap!=null && trn.bt_stripe__Transaction_Status__c=='Completed'  && trn.bt_stripe__Related_Lead__c!=null
                 && trn.bt_stripe__Payment_Status__c!=oldMap.get(trn.Id).bt_stripe__Payment_Status__c &&
                (trn.bt_stripe__Payment_Status__c=='Captured' || trn.bt_stripe__Payment_Status__c=='Refunded' || 
                trn.bt_stripe__Related_Lead__c!=oldMap.get(trn.Id).bt_stripe__Related_Lead__c))
             {
                 leadIds.add(trn.bt_stripe__Related_Lead__c);
                 afterUpdateFirstRun = false;
             }
             else if(oldMap==null && trn.bt_stripe__Transaction_Status__c=='Completed'  && trn.bt_stripe__Related_Lead__c!=null                 
                && (trn.bt_stripe__Payment_Status__c=='Captured' || trn.bt_stripe__Payment_Status__c=='Refunded' ))
             {
                 leadIds.add(trn.bt_stripe__Related_Lead__c);
                 isInsert = true; 
             }             
         }
         if(leadIds.size()>0)
             LeadConversion(leadIds);
    }
    
    public static void LeadConversion(Set<id> leadIds){
        list<Lead> LeadsToConvert = new list<Lead>();
        Set<string> emails = new Set<String>();
        Map<id,String> idsMap = new Map<Id,String>();
        for(Lead myLead: [select id,Email,isConverted from Lead where id=:leadIds AND isConverted=false]){
            if(!myLead.isConverted && myLead.Email!=null){
                LeadsToConvert.add(myLead);
                emails.add(myLead.Email);
            }
        }
        Map<string,contact> conMap = new Map<string,Contact>();
        for(Contact con: [Select id,Email,CreatedDate,AccountId from Contact where Email=:emails Order By CreatedDate ASC]){
            
            if(!conMap.containsKey(con.Email))conMap.put(con.Email, Con);
        }
        try{
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        for(Lead myLead : LeadsToConvert){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(myLead.Id);
            if(conMap.containsKey(myLead.Email) ){
                lc.setContactId(conMap.get(myLead.Email).Id);
                lc.setAccountId(conMap.get(myLead.Email).AccountId);
            }
            lc.convertedStatus = 'Closed - Converted';
            lc.setDoNotCreateOpportunity(true);
            leadConverts.add(lc);
        }
        
        if(!leadConverts.isEmpty()){
            for(Integer i = 0; i <= leadConverts.size()/5 ; i++){
                list<Database.LeadConvert> tempList = new list<Database.LeadConvert>();
                Integer startIndex = i*5;
                Integer endIndex = ((startIndex+5) < leadConverts.size()) ? startIndex+5 : leadConverts.size();
                for(Integer j=startIndex;j<endIndex;j++){
                    tempList.add(leadConverts[j]);
                }
                Database.LeadConvertResult[] lcrList = Database.convertLead(tempList, true);
                for(Database.LeadConvertResult lcr : lcrList){
                    System.assert(lcr.isSuccess());
                    idsMap.put(lcr.getLeadId(), String.valueof(lcr.getContactId())+','+String.valueof(lcr.getAccountId()));
                }
                    
            }
        }
        List<bt_stripe__Transaction__c> trnRec = new List<bt_stripe__Transaction__c>();
        for(bt_stripe__Transaction__c trn : [Select id,bt_stripe__Related_Lead__c from bt_stripe__Transaction__c where bt_stripe__Related_Lead__c=:leadIds
                                            AND bt_stripe__Related_Contact__c=null]){
            bt_stripe__Transaction__c rec = new bt_stripe__Transaction__c(id=trn.Id);
            if(idsMap.containsKey(trn.bt_stripe__Related_Lead__c)){
            rec.bt_stripe__Related_Account__c =idsMap.get(trn.bt_stripe__Related_Lead__c).split(',')[1];
            rec.bt_stripe__Related_Contact__c=idsMap.get(trn.bt_stripe__Related_Lead__c).split(',')[0];
            //rec.bt_stripe__Related_Lead__c=null;
            trnRec.add(rec);
            }
        }
        if(trnRec.size()>0)
            Update trnRec;
        }Catch(Exception ex){System.debug(ex.getStackTraceString());}
    }
}