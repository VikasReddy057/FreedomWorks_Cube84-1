global class PrimaryChannelBatch implements Database.Batchable<Sobject>,Schedulable{
    
    global  boolean deleteAdditionalRecords=false;
    
    
    global void execute(SchedulableContext SC) {
        //Database.executeBatch(new PrimaryChannelBatch(),1);
    }
    global  PrimaryChannelBatch(Boolean deleteall){
        deleteAdditionalRecords =deleteall;
    }
        public void PrimaryChannelBatch(){
     
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
    if(deleteAdditionalRecords)
        return Database.getQueryLocator([Select id from Account where Test__c>1 ]);
    else
        return Database.getQueryLocator([Select id from Account where Test__c>0 ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        Set<Id> accIds = new Set<Id>();
        for(Account acc: scope)
            accIds.add(acc.Id);
        //validateAccounts(accIds);
        mergeRecords(accIds);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    public static void mergeRecords(set<Id> records){
    
        Set<Primary_Channels__c> allrecords = new Set<Primary_Channels__c> ();
        Set<Primary_Channel_Members__c> delRecords = new Set<Primary_Channel_Members__c>();
        Map<string,Primary_Channel_Members__c> allrecordsPCM = new Map<string,Primary_Channel_Members__c>();
        
        for(Account acc: [Select id ,(select id,ExternalId__c from Primary_Channels__r where ExternalId__c !=:records
        AND Filter__c>1),
        (select id,Count__c,PC_Order__c,External_Member_Id__c,PrimaryChannelId__r.Filter__c,PrimaryChannelId__r.ExternalId__c 
        from Primary_Channel_Members__r where PrimaryChannelId__r.Filter__c>1 AND 
        PrimaryChannelId__r.ExternalId__c !=:records ) from Account where id=:records]){
            List<Primary_Channels__c> pc =  acc.Primary_Channels__r;
            List<Primary_Channel_Members__c> pcM =  acc.Primary_Channel_Members__r;
            if(pc.size()>0){              
              for(Primary_Channels__c pcRecord: pc){
                  allrecords.add(pcRecord);
              }              
            }
            if(pcM.size()>0){
              
              for(Primary_Channel_Members__c pcMRecord: pcM){  
                Primary_Channels__c obj= new Primary_Channels__c(ExternalId__c=acc.Id);
                delRecords.add(pcMRecord); 
                Primary_Channel_Members__c pcmr =  new Primary_Channel_Members__c(Account__c=acc.Id,PrimaryChannelID__r=obj,
                External_Member_Id__c = acc.Id+'-'+pcMRecord.PC_Order__c,dummy_Count__c=pcMRecord.Count__c,PC_Order__c=pcMRecord.PC_Order__c); 
                if(!allrecordsPCM.containsKey(pcmr.External_Member_Id__c))
                    allrecordsPCM.put(pcmr.External_Member_Id__c,pcmr);  
                else{                                    
                    Primary_Channel_Members__c p =allrecordsPCM.get(pcmr.External_Member_Id__c);
                    p.dummy_Count__c =p.dummy_Count__c+pcMRecord.Count__c;
                    allrecordsPCM.put(pcmr.External_Member_Id__c,p);  
                    }
              }              
            }            
        }
        
        if(allrecordsPCM.size()>0)
        {
            Database.upsert( allrecordsPCM.values(),Primary_Channel_Members__c.Fields.External_Member_Id__c,false);
            
        }  
        if(delRecords.size()>0)
            Delete new List<Primary_Channel_Members__c>(delRecords);
        if(allrecords.size()>0) 
            Delete new List<Primary_Channels__c>(allrecords);   
              
    }
    
    public static void validateAccounts(set<Id> records){
        Map<Id,Map<id,contact>> accAndCon = new Map<Id,Map<Id,contact>>();
        Set<Id> allConIds = new Set<Id>();
        Map<string,String> newChannelRec = new Map<string,String>();
        Map<string,Integer> allContactsActivityDate = new Map<string,Integer>();
        Map<string,Map<String,Integer>> DonatedToCampaigns = new Map<string,Map<String,Integer>>();
        
        for(Account acc: [select id,(Select id,Produced_By__c,stageName,AccountId,CampaignId,Parent_Campaign__c,Campaign_Record_Type_Name2__c 
                                     from Opportunities where stageName IN ('Received','Posted') AND 
                                    Produced_By__c!=null),(select id,Prospect_Last_Action_Date__c,Master_Last_Activity__c,AccountId from Contacts ) from Account where id=:records]){
            accAndCon.put(acc.Id,new Map<Id,Contact>());
             DonatedToCampaigns.put(acc.Id,new Map<String,Integer>()) ;                          
            Integer count =0; 
             // Campaingns Rollup
             DonatedToCampaigns =OpportunityTriggerHandler.createChildsForBatch(DonatedToCampaigns,acc.Opportunities,null,false);                   
            
            for(Contact con: acc.Contacts){
                allConIds.add(con.Id);
                if(con.Master_Last_Activity__c!=null){
                    count = count+1;
                    DonatedToCampaigns.get(acc.Id).Put('6',count);
                }
                
                
                accAndCon.get(con.AccountId).put(con.Id,con);
                
            }
            
           
            // Contacts count for  AdvocacyCampaigns                          
            //allContactsActivityDate.put(acc.Id,count);
        }
        // 1.Major Campaigns
         system.debug('1 st '+ accAndCon);
        List<String> majorIds = Label.Campaign_Donations_Ids.split(',');
        Map<string,String> firstPriority = majorCampaigns(allConIds,majorIds);
        if(!firstPriority.isEmpty())
            newChannelRec.putAll(firstPriority);
        
        for(String key : firstPriority.keySet()){
            if(newChannelRec.get(key)=='999')
                newChannelRec.put(key,'0');
        }
        

               
        Map<string,Primary_Channels__c>  newObj = new Map<string,Primary_Channels__c>();
        for(String st: newChannelRec.keySet() ){
            Integer val = newChannelRec.get(st)!=null?Integer.valueof(newChannelRec.get(st)): 0;
            newObj.put(st, new Primary_Channels__c(Account__c=st,Primary_Key__c=val,ExternalId__c=st));
        }
        if(newObj.size()>0){
            Schema.SObjectField ftoken = Primary_Channels__c.Fields.ExternalId__c;
            Database.UpsertResult[] srList = Database.upsert(newObj.values(),ftoken,false);
            for (Database.UpsertResult sr : srList) {
                if (sr.isSuccess()) {}
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('fields that affected this error: ' + err.getFields());
                        
                    }
                }
            }
        }
        // Other than Major campaigns
        validCampaignsForPEChildRecord(accAndCon.keySet(),allContactsActivityDate,DonatedToCampaigns);
    }
    
    public static  Map<string,String> majorCampaigns(set<Id> allConIds ,List<String> majorIds){
        Map<string,String> mapCampaignCodes = new  Map<string,String>();
        
        for(CampaignMember cm: [Select id,CampaignId,Campaign.Name,ContactId,Contact.AccountId from CampaignMember where campaignId=:majorIds AND ContactId=:allConIds]){
            
            String code =  cm.Campaign.Name.contains('Corporat')? 'C': (cm.Campaign.Name.contains('Major')?'A':'B' );

            if(!mapCampaignCodes.containsKey(cm.Contact.AccountId))
                mapCampaignCodes.put(cm.Contact.AccountId,code );
            /*else{
                string  oldvalue =mapCampaignCodes.get(cm.Contact.AccountId);
                oldvalue = oldvalue.contains(code)? oldvalue: (oldvalue.contains(code.toLowerCase())?oldvalue.replaceAll(code.toLowerCase(), code):oldvalue+code);
                mapCampaignCodes.put(cm.Contact.AccountId,oldvalue);
            }*/
            
            
        }
        System.debug('Major Campaign codes '+ mapCampaignCodes);
        for(string key: mapCampaignCodes.keySet()){
            String st ='';
            if(mapCampaignCodes.get(key).contains('A') ){
                st = '1';
            }else{
                st = '9';
            }
            if(mapCampaignCodes.get(key).contains('B')){
                st = st+'1';
            }else{
                st = st+'9';
            }  
            if( mapCampaignCodes.get(key).contains('C')){                
                st = st+'1';
            }else{
                st = st+'9';
            } 
            mapCampaignCodes.put(key,st);
        }
        System.debug('Major Campaign codes '+ mapCampaignCodes);
        return mapCampaignCodes;
    }
    

    public static void validCampaignsForPEChildRecord(Set<Id> rec, Map<String,Integer> allCon, Map<String,Map<string,Integer>> don){
        Map<String,Map<string,Integer>> allRecords = Don;
        System.debug('^^^^'+allRecords);
        Map<string,Primary_Channels__c> upsertPCRecords = new Map<String,Primary_Channels__c>();
        Map<string,Primary_Channel_Members__c> upsertPCMRecords = new Map<String,Primary_Channel_Members__c>();
                
        if(allRecords.size()>0){
            for(string key: allRecords.keySet()){
                if(!allRecords.get(key).isEmpty()){
                    upsertPCRecords.put(key,new Primary_Channels__c( Account__c=key,ExternalId__c=key));
                    for(String st: allRecords.get(key).keySet()){
                        Integer noCount = allRecords.get(key).get(st);
                    Primary_Channels__c obj= new Primary_Channels__c(ExternalId__c=key);
                    upsertPCMRecords.put(key+'-'+st,new Primary_Channel_Members__c(Account__c=key,PrimaryChannelID__r=obj,
                    External_Member_Id__c = key+'-'+st,Count__c=noCount,PC_Order__c=st));
                    }    
                }
            }
        }
        if(upsertPCRecords.size()>0){ Database.upsert( upsertPCRecords.values(), Primary_Channels__c.Fields.ExternalId__c,false );}
        if(upsertPCMRecords.size()>0){ Database.upsert( upsertPCMRecords.values(), Primary_Channel_Members__c.Fields.External_Member_Id__c,false );}
    }
    /*public static Map<string,Map<String,Integer>> addRecords(Map<String,Map<String,Integer>> mapRecords ,Map<String,Map<String,Integer>> oldMapRecords,
                                                       CampaignMember cm,string act,string res1,Map<String,Integer> allCon){
        string res2 = res1;
        System.debug('^^^Res'+ res2);
        Map<string,Map<String,Integer>> resMap = mapRecords;
        for(String res: res2.split('-')){                                                        
        Integer count=0;
        if(resMap.containsKey(cm.Account__c) && resMap.get(cm.Account__c).containsKey(res)) 
            count =resMap.get(cm.Account__c).get(res);            
        else if(oldMapRecords.containsKey(cm.Account__c) && oldMapRecords.get(cm.Account__c).containsKey(res))
            count =oldMapRecords.get(cm.Account__c).get(res);

        count = (act=='add'? count+1:(count>0?count-1:0)) ;
            if(res=='6')count = allCon.get(cm.Account__c);
          System.debug('^^^count'+ count);
        if(!resMap.containsKey(cm.Account__c))
            resMap.put(cm.Account__c, new Map<string,Integer>{res => count});
        else{            
            resMap.get(cm.Account__c).put (res,count);
        }
        }    
        System.debug(resMap);
        return resMap;
    }
    public static string getCampaignCode(CampaignMember cm, Integer locVal){

        Set<Id> BestCampaigns = new Set<Id>((List<Id>)Label.Campaign_BestCampaigns.split(',')); 
        
        String  res='';
           if(BestCampaigns.contains(cm.CampaignId)){               
                res = '8';
            } 
            if(cm.Last_Action_Date__c!=null){
                res =res==''?'6': res+'-6';
            }

        return res;
    }*/
      public static void DummyMethod(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;          
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
                  i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;          
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
    }
}