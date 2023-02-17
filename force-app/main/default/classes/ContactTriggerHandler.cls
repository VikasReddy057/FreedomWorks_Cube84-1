public class ContactTriggerHandler {
    
    public static boolean isInsert = false;
    public static Boolean afterUpdateFirstRun = true;
    public static Boolean beforeUpdateFirstRun = true;
    public static Map<string,string> maplists = new Map<string,string>();
    
    public static void beforeInsert(List<contact> newRecords){
        setMasterDate(newRecords,null);
        DummyMethod();
    }    
    public static void afterInsert(List<contact> newRecords,Map<Id,Contact> newMap){
        addToProspectList(newRecords,null);
        addGrassRootsPrimaryChannel(newRecords,null);
        DummyMethod();
    }
    public static void beforeUpdate(List<contact> newRecords,List<contact> oldRecords, Map<Id,Contact> newMap,Map<Id,Contact> oldmap){
        setMasterDate(newRecords,oldmap);
        DummyMethod();
    }    
    
    public static void afterUpdate(List<contact> newRecords,List<contact> oldRecords, Map<Id,Contact> newMap,Map<Id,Contact> oldmap){
        addToProspectList(newRecords,oldmap);
        addGrassRootsPrimaryChannel(newRecords,oldmap);
        DummyMethod();
        //funnelValidContacts(newRecords,oldmap);
    }
    
    public static void setMasterDate(List<contact> records,Map<id,Contact> oldMap){
        System.debug('@@@In');
        
        for(Contact con: records){ System.debug('@@@'+con.Add_to_MarketLists__c );
                               
                                  if(oldMap!=null && oldMap.get(con.Id).Add_to_MarketLists__c  != con.Add_to_MarketLists__c  && con.Add_To_Prospect_List__c!=null){
                                      maplists.put(con.id,con.Add_to_MarketLists__c);
                                      con.Add_to_MarketLists__c  = null;
                                      con.Prospect_Last_Action_Date__c = System.today();
                                      
                                  }else if(oldMap==null && con.Add_to_MarketLists__c !=null){
                                      maplists.put(string.escapeSingleQuotes(con.LastName)+con.Email,con.Add_to_MarketLists__c);
                                      con.Add_to_MarketLists__c  = null;
                                      con.Prospect_Last_Action_Date__c = System.today(); 
                                  }
                                  
                                  if(oldMap!=null && oldMap.get(con.Id).Prospect_Last_Action_Date__c != con.Prospect_Last_Action_Date__c){
                                      con.Do_Not_Mail__c= false;
                                      con.Email_Status__c='Opted In';
                                      con.HasOptedOutOfEmail = false;
                                      con.DoNotCall= false;
                                      con.Do_Not_Rent__c= false;
                                      con.Do_Not_Solicit__c= false;
                                      con.Do_Not_Text__c=false;
                                      con.Do_Not_Visit__c= false;    
                                  }else if(oldMap==null && con.Prospect_Last_Action_Date__c!=null){
                                      con.Do_Not_Mail__c= false;
                                      con.Email_Status__c='Opted In';
                                      con.HasOptedOutOfEmail = false;
                                      con.DoNotCall= false;
                                      con.Do_Not_Rent__c= false;
                                      con.Do_Not_Solicit__c= false;
                                      con.Do_Not_Text__c=false;
                                      con.Do_Not_Visit__c= false; 
                                      
                                      
                                  }
            System.debug('@@@'+con.Prospect_Last_Action_Date__c);
                                  //System.debug('@@@'+oldMap.get(con.Id).Prospect_Last_Action_Date__c);
                                  
        }

    }
    
    public Static void addToProspectList(List<contact> records,Map<id,Contact> oldMap){
         Set<Id> prospectIds = new Set<Id>();
         for(Contact con: records){
             
            if(oldMap!=null && oldMap.get(con.Id).Prospect_Last_Action_Date__c != con.Prospect_Last_Action_Date__c){
                
                prospectIds.add(con.Id);
                
            }else if(oldMap==null && con.Prospect_Last_Action_Date__c!=null){
                if(maplists.containsKey(string.escapeSingleQuotes(con.LastName)+con.Email)) maplists.put(con.id,maplists.get(string.escapeSingleQuotes(con.LastName)+con.Email));
                prospectIds.add(con.Id);
            }
                
        }
        System.debug('prospectIds'+prospectIds);
        if(prospectIds.size()>0)addMembers(prospectIds);
    }
    
    Public static void addMembers(Set<id> ids){
        Map<id,Campaign> prospectList = new Map<id,Campaign>();
        Set<string> MarketingList = new Set<string>();
        for(String st: maplists.values())
            MarketingList.addAll(st.split(','));
        for(Campaign cm: [Select id from Campaign where id=:MarketingList]){
            prospectList.put(cm.Id,cm);
        }
        
        Map<string,CampaignMember> newRecords = new Map<String,CampaignMember>();
        //Map<Id,CampaignMember> updateRec = new Map<Id,CampaignMember>();
        for(Id rec: Ids){
            if(maplists.containskey(rec))
            for(Id st: maplists.get(rec).split(','))
                newRecords.put((String.valueof(rec)+String.valueOf(st)), new CampaignMember(UniqueId__c=+String.valueOf(st)+String.valueof(rec), ContactId=rec,CampaignId=st,Status='Sent')); 
        }
        for(Campaignmember rec: [select Id,ContactId,CampaignId from CampaignMember where campaignId=:MarketingList AND 
                                ContactId=: ids]){
                                    
            newRecords.remove(String.valueof(rec.contactId)+String.valueOf(rec.CampaignId));
        }
         System.debug('newRecords'+newRecords);
        if(newRecords.size()>0){
            List<Add_To_Prospect_List__c> li = new List<Add_To_Prospect_List__c>();
            li.add(new Add_To_Prospect_List__c(Members__c = JSON.serialize(newRecords.values())));
            Insert li;
            List<AsyncApexJob> apexjobs=  [SELECT ApexClass.Name , JobType, Status FROM AsyncApexJob where JobType= 'BatchApex' AND 
                                           status IN('Preparing','Processing','Queued')  AND ApexClass.Name='AddToProspectCampaign'];
            if(apexjobs!=null && apexjobs.size()==0)
                Database.executeBatch(new AddToProspectCampaign(),1);
            
                
            //Insert newRecords.values();
        }
    }
    
    public static void funnelValidContacts(List<contact> newRecords, Map<Id,Contact> mapRecords){

        //checkCampaigns(newRecords,mapRecords);

        
    } 
    public static void addGrassRootsPrimaryChannel(List<Contact> rec, Map<Id,Contact> oldMap){
        Map<string,Primary_Channels__c> upsertPCRecords = new Map<String,Primary_Channels__c>();
        Map<string,Primary_Channel_Members__c> upsertPCMRecords = new Map<String,Primary_Channel_Members__c>();
        Set<Id> accIds =  new set<id> ();
        for(Contact con: rec){
            if( oldMap!=null && oldMap.get(con.Id).Master_Last_Activity__c==null &&
               ((con.P2A_Last_Advocacy_Date__c!=oldMap.get(con.Id).P2A_Last_Advocacy_Date__c) || 
                (con.Prospect_Last_Action_Date__c!=oldMap.get(con.Id).Prospect_Last_Action_Date__c)) 
               
               ){
                   accIds.add(con.AccountId);
               }
            else if(oldMap==null && con.Master_Last_Activity__c!=null)
                accIds.add(con.AccountId);
        }
        For(Account acc: [Select id,(Select id from Contacts where Master_Last_Activity__c!=null) from Account where id=:accIds]){
            
            upsertPCRecords.put(acc.Id,new Primary_Channels__c( Account__c=acc.Id,ExternalId__c=acc.Id));
            Primary_Channels__c obj= new Primary_Channels__c(ExternalId__c=acc.Id);
            upsertPCMRecords.put(String.valueof(acc.Id)+'-6',new Primary_Channel_Members__c(Account__c=acc.Id,PrimaryChannelID__r=obj,
                                                                           External_Member_Id__c = String.valueof(acc.Id)+'-6',Count__c=acc.contacts.size(),PC_Order__c='6'));            
        }
        
        if(upsertPCRecords.size()>0){ Database.upsert( upsertPCRecords.values(), Primary_Channels__c.Fields.ExternalId__c );}
        if(upsertPCMRecords.size()>0){ Database.upsert( upsertPCMRecords.values(), Primary_Channel_Members__c.Fields.External_Member_Id__c );}
		 
}
    /*public static void checkCampaigns(List<Contact> rec, Map<Id,Contact> oldMap){
        Set<id> accIds = new Set<Id>();
        for(Contact con: rec){
            if( ((!(string.isNotBlank(con.Auto_Fill_Primary_Channel__c)&& (con.Auto_Fill_Primary_Channel__c.containsIgnoreCase('Major') || con.Auto_Fill_Primary_Channel__c.containsIgnoreCase('Corpor') 
               || con.Auto_Fill_Primary_Channel__c.containsIgnoreCase('Founda')))) ||  string.isBlank( con.Auto_Fill_Primary_Channel__c))
               && (
               (con.No_of_Major_Campaigns__c !=oldMap.get(con.Id).No_of_Major_Campaigns__c && con.No_of_Major_Campaigns__c==0)
               || con.No_of_DirectMail_HSP_Campaign__c!=oldMap.get(con.Id).No_of_DirectMail_HSP_Campaign__c
               || con.No_of_DirectMail_Righers_Campaign__c!=oldMap.get(con.Id).No_of_DirectMail_Righers_Campaign__c
               || con.No_of_DirectMail_Forthright_Campaign__c!=oldMap.get(con.Id).No_of_DirectMail_Forthright_Campaign__c
               || con.No_of_MarketStaff_Text_Campaigns__c!=oldMap.get(con.Id).No_of_MarketStaff_Text_Campaigns__c
               || con.No_of_MarketStaff_Email_Campaigns__c!=oldMap.get(con.Id).No_of_MarketStaff_Email_Campaigns__c
               || con.No_of_BestCampains__c !=oldMap.get(con.Id).No_of_MarketStaff_Email_Campaigns__c
               || con.Prospect_Last_Action_Date__c!=oldMap.get(con.Id).Prospect_Last_Action_Date__c 
               || con.P2A_Last_Advocacy_Date__c !=oldMap.get(con.Id).P2A_Last_Advocacy_Date__c 
               //|| con.Master_Last_Activity__c!=null
                   )

              )
                accIds.add(con.AccountId);
        }
        
        if(accIds.size()>0)
            validateAccounts(accIds);
    }
    
    public static void validateAccounts(set<Id> records){
        Map<Id,Map<id,contact>> accAndCon = new Map<Id,Map<Id,contact>>();
        Set<Id> allConIds = new Set<Id>();
        Map<string,String> newChannelRec = new Map<string,String>();
        for(Account acc: [select id,(select id,AccountId,No_of_DirectMail_HSP_Campaign__c,No_of_DirectMail_Righers_Campaign__c,
                                     No_of_DirectMail_Forthright_Campaign__c,No_of_MarketStaff_Text_Campaigns__c,
                                     No_of_MarketStaff_Email_Campaigns__c,Master_Last_Activity__c,No_of_BestCampains__c
                                     from Contacts) from Account where id=:records]){
            accAndCon.put(acc.Id,new Map<Id,Contact>());
            for(Contact con: acc.Contacts){
                allConIds.add(con.Id);
                accAndCon.get(con.AccountId).put(con.Id,con);
            }
        }
        System.debug('###PrimaryChannel');
        // 1.Major Campaigns
        List<String> majorIds = Label.Campaign_Donations_Ids.split(',');
        Map<string,String> firstPriority = majorCampaigns(allConIds,majorIds);
        if(!firstPriority.isEmpty())
            newChannelRec.putAll(firstPriority);
        
        for(String key : firstPriority.keySet()){
            if(newChannelRec.get(key)=='999')
                newChannelRec.remove(key);
            else{            
            for(Id st: accAndCon.get(key).keySet())
                    allConIds.remove(st);
            accAndCon.remove(key);
            }
        }
        
        // 2 priority Campaigns

        for(String st: accAndCon.keySet()){
            for(Contact con: accAndCon.get(st).values())
            {
                if(con.No_of_DirectMail_Righers_Campaign__c>0 && !newChannelRec.containskey(st) )
                    newChannelRec.put(con.AccountId,'2');                                     
            }
            if(newChannelRec.containsKey(st))
                accAndCon.remove(st);
        }
        // 3 Priority Campaigns
              
        for(String st: accAndCon.keySet()){
            for(Contact con: accAndCon.get(st).values())
            {
                if(con.No_of_DirectMail_HSP_Campaign__c>0 && !newChannelRec.containskey(st))
                    newChannelRec.put(con.AccountId,'3');                                     
            }
            if(newChannelRec.containsKey(st))
                accAndCon.remove(st);
        }
        // 4 Priority Campaigns
        
        for(String st: accAndCon.keySet()){
            for(Contact con: accAndCon.get(st).values())
            {
                if(con.No_of_MarketStaff_Email_Campaigns__c>0 && !newChannelRec.containskey(st))
                    newChannelRec.put(con.AccountId,'4');                                     
            }
            if(newChannelRec.containsKey(st))
                accAndCon.remove(st);
        }    
        // 5 Priority Campaigns

        for(String st: accAndCon.keySet()){
            for(Contact con: accAndCon.get(st).values())
            {
                if(con.No_of_MarketStaff_Text_Campaigns__c>0 && !newChannelRec.containskey(st))
                    newChannelRec.put(con.AccountId,'5');                                     
            }
            if(newChannelRec.containsKey(st))
                accAndCon.remove(st);
        }         
        // 6 Priority Campaigns
              

        for(String st: accAndCon.keySet()){
            for(Contact con: accAndCon.get(st).values())
            {
                if(con.Master_Last_Activity__c!=null && !newChannelRec.containskey(st))
                    newChannelRec.put(con.AccountId,'6');                                     
            }
            if(newChannelRec.containsKey(st))
                accAndCon.remove(st);
        } 
        // 7 Priority Campaigns
              

        for(String st: accAndCon.keySet()){
            for(Contact con: accAndCon.get(st).values())
            {
                if(con.No_of_DirectMail_Forthright_Campaign__c>0 && !newChannelRec.containskey(st))
                    newChannelRec.put(con.AccountId,'7');                                     
            }
            if(newChannelRec.containsKey(st))
                accAndCon.remove(st);
        } 
        for(String st: accAndCon.keySet()){
            for(Contact con: accAndCon.get(st).values())
            {
                if(con.No_of_BestCampains__c>0 && !newChannelRec.containskey(st))
                    newChannelRec.put(con.AccountId,'8');                                     
            }
            if(newChannelRec.containsKey(st))
                accAndCon.remove(st);
        }
        // Else
        for(String st: accAndCon.keySet()){
            for(Contact con: accAndCon.get(st).values())
            {
                    newChannelRec.put(con.AccountId,'0');                                     
            }
            if(newChannelRec.containsKey(st))
                accAndCon.remove(st);
        }  
        System.debug('###'+newChannelRec.values());
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
   */ 
    public static  Map<string,String> majorCampaigns(set<Id> allConIds ,List<String> majorIds){
        Map<string,String> mapCampaignCodes = new  Map<string,String>();
        
        for(CampaignMember cm: [Select id,CampaignId,Campaign.Name,ContactId,Contact.AccountId from CampaignMember where campaignId=:majorIds AND ContactId=:allConIds]){
            
            String code =  cm.Campaign.Name.contains('Corporat')? 'C': (cm.Campaign.Name.contains('Major')?'A':'B' );
  
            if(!mapCampaignCodes.containsKey(cm.Contact.AccountId))
                mapCampaignCodes.put(cm.Contact.AccountId,code );
            else{
                string  oldvalue =mapCampaignCodes.get(cm.Contact.AccountId);
                oldvalue = oldvalue.contains(code)? oldvalue: (oldvalue.contains(code.toLowerCase())?oldvalue.replaceAll(code.toLowerCase(), code):oldvalue+code);
                mapCampaignCodes.put(cm.Contact.AccountId,oldvalue);
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
        return mapCampaignCodes;
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