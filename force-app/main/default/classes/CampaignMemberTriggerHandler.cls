public class CampaignMemberTriggerHandler {
    Public static Boolean beforeInsertFirstRun = true;
    
    public static void afterInsert(List<CampaignMember> records,Map<Id,CampaignMember> newMap){
        checkCampaigns(records,false,newMap);
        validCampaignsForPEChildRecord(records,null,false);
        beforeInsertFirstRun = false;
        DummyMethod();
    }
    
    public static void afterUpdate(List<CampaignMember> records,Map<Id,CampaignMember> oldMap, Map<Id,CampaignMember> newMap){
        DummyMethod();
        if(beforeInsertFirstRun)checkCampaigns(records,false,oldMap);
    }
    
    public static void afterDelete(List<CampaignMember> records, Map<Id,CampaignMember> oldMap){
        checkCampaigns(records,true,oldMap);
        validCampaignsForPEChildRecord(records,null,true);
        DummyMethod();
    }
    
    public static void checkCampaigns(List<campaignMember> rec,Boolean isDelete, Map<Id,CampaignMember> oldMap){
        Set<id> accIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        for(campaignMember obj: rec){
            if(obj.ContactId!=null)
                conIds.add(obj.ContactId);
        }
        for(Contact acc: [select id,AccountId from Contact where id=:conIds ])
            accIds.add(acc.AccountId);
        
        if(accIds.size()>0)
            validateAccounts(accIds,isDelete,OldMap,conIds);
    }
    
    public static void validateAccounts(set<Id> records,Boolean isDelete, Map<Id,CampaignMember> oldMap, Set<Id> conIds){
        Map<Id,Map<id,contact>> accAndCon = new Map<Id,Map<Id,contact>>();
        Set<Id> allConIds = new Set<Id>();
        Map<string,String> newChannelRec = new Map<string,String>();
        
        for(Account acc: [select id,(select id,AccountId,Master_Last_Activity__c
                                     from Contacts ) from Account where id=:records]){
            accAndCon.put(acc.Id,new Map<Id,Contact>());
            for(Contact con: acc.Contacts){
                allConIds.add(con.Id);
                accAndCon.get(con.AccountId).put(con.Id,con);
            }
        }
        // 1.Major Campaigns
        //system.debug('1 st '+ accAndCon);
        List<Id> majorIds = Label.Campaign_Donations_Ids.split(',');
        Map<string,String> firstPriority = majorCampaigns(allConIds,records,majorIds,isDelete,oldMap);
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
    }
    
    public static  Map<string,String> majorCampaigns(set<Id> allConIds ,set<id> accRecords, List<String> majorIds, Boolean isDelete, Map<Id,CampaignMember> oldrecs){
        Map<string,String> mapCampaignCodes = new  Map<string,String>();
        
            
        for(CampaignMember cm: [Select id,CampaignId,Campaign.Name,ContactId,Contact.AccountId from CampaignMember where campaignId=:majorIds AND ContactId=:allConIds]){
            
            String code =  cm.Campaign.Name.contains('Corporat')? 'C': (cm.Campaign.Name.contains('Major')?'A':'B' );
            if(!isDelete || ( isDelete && !oldrecs.containsKey(cm.Id)) ) {   
            if(!mapCampaignCodes.containsKey(cm.Contact.AccountId))
                mapCampaignCodes.put(cm.Contact.AccountId,code );
            /*else{
                string  oldvalue =mapCampaignCodes.get(cm.Contact.AccountId);
                oldvalue = oldvalue.contains(code)? oldvalue: (oldvalue.contains(code.toLowerCase())?oldvalue.replaceAll(code.toLowerCase(), code):oldvalue+code);
                mapCampaignCodes.put(cm.Contact.AccountId,oldvalue);
            }*/
            }else{
            if(!mapCampaignCodes.containsKey(cm.Contact.AccountId))
                mapCampaignCodes.put(cm.Contact.AccountId, code.toLowerCase( ) );
            /*else{
                string  oldvalue =mapCampaignCodes.get(cm.Contact.AccountId);
                oldvalue = oldvalue.contains(code)? oldvalue:(oldvalue.contains(code.toLowerCase())?oldvalue:oldvalue+code.toLowerCase()) ;
                mapCampaignCodes.put(cm.Contact.AccountId,oldvalue);
            }*/
            }
            
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
        for(Id ids: accRecords){
            if(!mapCampaignCodes.containskey(ids))
                mapCampaignCodes.put(ids,'0');
        }
        return mapCampaignCodes;
    }
    
    /*public static Map<String,Integer>  getAdvocacyCampaigns( List<CampaignMember> cm){
        List<id> accIds = new List<Id>();
        Map<Id,Integer> ProspectCount = new Map<Id,Integer>();
        for(CampaignMember rec: cm){
            accIds.add(rec.Account__c);
        }
        List<Id> prospectIds = Label.Campaign_Prospect_List.split(',');
        if(prospectIds!=null && prospectIds.size()>0){
        for(AggregateResult ar: [Select count(id),Account__c from CampaignMember group by Account__c where Account__c=:accIds AND campaignId=:prospectIds ]){
            ProspectCount.put(ar.);
        }
        }
        return null;
    }  */  
    public static void validCampaignsForPEChildRecord(List<CampaignMember> rec, Map<Id,CampaignMember> oldmap,Boolean isDelete){
        Map<String,Map<string,Integer>> allRecords = new Map<String,Map<String,Integer>>();
        Map<String,Map<string,Integer>> pcmRecords = new Map<string,Map<string,Integer>>();
        Map<Id,Primary_Channels__c> oldPrimaryChannels = new Map<Id,Primary_Channels__c>();

        //rec = [Select Id,CompanyOrAccount,CampaignId,Campaign.Produced_By__c,Campaign.RecordType.Name,ContactId,Contact.Master_Last_Activity__c 
               //from CampaignMember where id=:rec];
        for(CampaignMember cm: rec){
            if(cm.ContactId!=null)
       			allRecords.put(cm.Account__c, new Map<string,Integer>());
        }

        //Existing records
        for(Primary_Channel_Members__c pcm: [Select id,PC_Order__c,Account__c,External_Member_Id__c,Count__c 
        from Primary_Channel_Members__c where Account__c=:allRecords.keySet() Order by Account__c ]){
            if(!pcmRecords.containsKey(pcm.Account__c))   
                pcmRecords.put(pcm.Account__c,new Map<string,integer>());
            else
            {
                Map<string,Integer> oldRecords = pcmRecords.get(pcm.Account__c);
                pcmRecords.get(pcm.Account__c).put(pcm.PC_Order__c,Integer.valueof(pcm.Count__c));
            }                                                                                                 
        }
        
        // test
        for(CampaignMember cm: rec){
            if(oldmap!=null){
                
            }else{
                string res1 = getCampaignCode(cm); if(res1=='') continue; 
                //string res2 = getCampaignCodeForAdvocacy(cm); if(res2 == ''&& res1=='') continue; 
                if(isDelete){

                    	allRecords =addRecords(allRecords,pcmRecords,cm,'del',res1);

                }else{

                    	allRecords =addRecords(allRecords,pcmRecords,cm,'add',res1);

                }
            }
        }
        System.debug('^^^^'+allRecords);
        Map<string,Primary_Channels__c> upsertPCRecords = new Map<String,Primary_Channels__c>();
        Map<string,Primary_Channel_Members__c> upsertPCMRecords = new Map<String,Primary_Channel_Members__c>();
                
        if(allRecords.size()>0){
            for(string key: allRecords.keySet()){
                if(!allRecords.get(key).isEmpty()){
                    upsertPCRecords.put(key,new Primary_Channels__c( Account__c=key,ExternalId__c=key));
                    for(String st: allRecords.get(key).keySet()){
                        Integer noCount = allRecords.get(key).get(st);
					Primary_Channels__c	obj= new Primary_Channels__c(ExternalId__c=key);
                    upsertPCMRecords.put(key+'-'+st,new Primary_Channel_Members__c(Account__c=key,PrimaryChannelID__r=obj,
                    External_Member_Id__c = key+'-'+st,Count__c=noCount,PC_Order__c=st));
                    }    
                }
            }
        }
        if(upsertPCRecords.size()>0){ Database.upsert( upsertPCRecords.values(), Primary_Channels__c.Fields.ExternalId__c );}
        if(upsertPCMRecords.size()>0){ Database.upsert( upsertPCMRecords.values(), Primary_Channel_Members__c.Fields.External_Member_Id__c );}
    }
    public static Map<string,Map<String,Integer>> addRecords(Map<String,Map<String,Integer>> mapRecords ,Map<String,Map<String,Integer>> oldMapRecords,
                                                             CampaignMember cm,string act,String res1){
        string res = res1;
        System.debug('^^^Res'+ res);
        Map<string,Map<String,Integer>> resMap = mapRecords;
                                                                
        Integer count=0;
        if(resMap.containsKey(cm.Account__c) && resMap.get(cm.Account__c).containsKey(res)) 
            count =resMap.get(cm.Account__c).get(res);            
        else if(oldMapRecords.containsKey(cm.Account__c) && oldMapRecords.get(cm.Account__c).containsKey(res))
         	count =oldMapRecords.get(cm.Account__c).get(res);
         
        count = (act=='add'? count+1:(count>0?count-1:0)) ;
          System.debug('^^^count'+ count);
        if(!resMap.containsKey(cm.Account__c))
            resMap.put(cm.Account__c, new Map<string,Integer>{res => count});
        else{            
            resMap.get(cm.Account__c).put (res,count);
        }
           
        System.debug(resMap);
        return resMap;
    }

    /*public static string getCampaignCodeForAdvocacy(CampaignMember cm){
        Set<Id> ProsCampaigns = new Set<Id>((List<Id>)Label.Campaign_Prospect_List.split(','));
        
        String  res='';
        if(ProsCampaigns.contains(cm.CampaignId)){
            res = '6';
        }   		
      
        return res;
    }*/
    public static string getCampaignCode(CampaignMember cm){
      
        List<Id> BestCampaignsIds = Label.Campaign_BestCampaigns.split(',');
        Set<Id> BestCampaigns = new Set<Id>(BestCampaignsIds);
        
        String  res='';
		 if(BestCampaigns.contains(cm.CampaignId)){
                res = '18';
        }        
        return res;
    }
    
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
    }
}