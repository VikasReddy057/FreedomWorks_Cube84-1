public class OpportunityTriggerHandler {

    public static boolean isInsert = true;
    public static  boolean isUpdate = true;
    public static void afterInsert(List<Opportunity> records,Map<Id,Opportunity> newMap){
    
        validOpp(records,null,false);
        String rectypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Grant').getRecordTypeId();
        Map<Id,Opportunity> oppMap1 = new Map<Id,Opportunity>([Select id,amount, Designated_Organization__c,Account.OwnerId,
        AccountId,Account.Owner.Name,Account.recordType.Name,
                            Account.npo02__NumberOfClosedOpps__c,Account.owner.CaseLoad__c,Account.npe01__One2OneContact__c
         from Opportunity where id=:records]); 
            List<Opportunity> opp = new List<Opportunity>();
            for(Opportunity op: records)
            if((op.amount>=250 || oppMap1.get(op.Id).Account.owner.CaseLoad__c) && trigger.isInsert && Trigger.isAfter && op.isWon && Label.CreateDonationTasks== 'true' && op.recordTypeId != '0120b000000B4wIAAS' && op.recordTypeId != rectypeId )
             opp.add(op);
            if(opp.size()>0){    
            DonationTask(opp,null);            
            OpportunityTriggerHandler.isInsert =false;
            }
        
        }
    public static void afterUpdate(List<Opportunity> records,Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        validOpp(records,oldMap,false);
        String rectypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Grant').getRecordTypeId();
        Map<Id,Opportunity> oppMap1 = new Map<Id,Opportunity>([Select id,amount, Designated_Organization__c,Account.OwnerId,
        AccountId,Account.Owner.Name,Account.recordType.Name,
                            Account.npo02__NumberOfClosedOpps__c,Account.owner.CaseLoad__c,Account.npe01__One2OneContact__c
         from Opportunity where id=:records]);        
        if(OpportunityTriggerHandler.isUpdate ){
         List<Opportunity> opp = new List<Opportunity>();
         for(Opportunity op: records)
         if(trigger.isUpdate&& trigger.isAfter && op.isWon && (op.amount>=250 || oppMap1.get(op.Id).Account.owner.CaseLoad__c) && Label.CreateDonationTasks== 'true'
         && op.recordTypeId != '0120b000000B4wIAAS' && op.recordTypeId != rectypeId 
         && (OldMap.get(op.Id).amount!= op.amount || OldMap.get(op.Id).stageName==op.stageName))    
            opp.add(op);  
            if(opp.size()>0){       
            DonationTask(opp ,oldMap);
            OpportunityTriggerHandler.isUpdate =false;
            }
        }
    }
    public static void afterDelete(List<Opportunity> records, Map<Id,Opportunity> oldMap){
        validOpp(records,null,true);
    }
   public static  Map<String,Map<string,Integer>> createChildsForBatch(Map<String,Map<string,Integer>> allRec,List<Opportunity> newOpp, Map<Id,Opportunity> oldmap, Boolean isDelete){
        Map<String,Map<string,Integer>> allRecords = allRec;
        Map<String,Map<string,Integer>> pcmRecords = new Map<string,Map<string,Integer>>();
        Map<string,Primary_Channels__c> upsertPCRecords = new Map<String,Primary_Channels__c>();
        Map<string,Primary_Channel_Members__c> upsertPCMRecords = new Map<String,Primary_Channel_Members__c>();
        Set<Id> BestCampaigns = new Set<Id>((List<Id>)Label.Campaign_BestCampaigns.split(',')); 
        
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
        
        for(Opportunity op: newOpp){
            string res1 = getCampaignCode(op); if(res1=='') continue; 
            if(oldmap!=null){
                allRecords =addRecords(allRecords,pcmRecords,op,'add',res1);
            }else{
                
                if(isDelete){
                    allRecords =addRecords(allRecords,pcmRecords,op,'del',res1);
                }else{
                    allRecords =addRecords(allRecords,pcmRecords,op,'add',res1);
                }
            }
            
        }
        System.debug('^^^^'+allRecords);
                // Best campaigns Count
        for(AggregateResult ar: [Select count(Id),Contact.AccountId from CampaignMember where Contact.AccountId=:allRecords.keySet() AND 
                                 campaignId=:BestCampaigns Group by Contact.AccountId]){
            allRecords.get((string)ar.get('AccountId')).put('18', (Integer)ar.get('expr0'));
        }
        return allRecords;
    } 
    public static void validOpp(List<Opportunity> newOpp, Map<Id,Opportunity> oldmap, Boolean isDelete){
        Map<String,Map<string,Integer>> allRecords = new Map<String,Map<String,Integer>>(); 
        for(Opportunity op: newOpp){
            if( (op.stageName=='Received' || op.StageName=='Posted') ||  isDelete)
                allRecords.put(op.AccountId, new Map<string,Integer>());
            else if(!isDelete && oldmap!=null && (op.stageName=='Received' || op.StageName=='Posted' ) && 
                    (oldmap.get(op.Id).stageName !=op.stageName))
                allRecords.put(op.AccountId, new Map<string,Integer>());
            
        }    
        createChilds(allRecords,newOpp,oldmap,isDelete);
        if(test.isRunningTest())createChildsForBatch(allRecords,newOpp,oldmap,false);
    }
    public static void createChilds(Map<String,Map<string,Integer>> allRec,List<Opportunity> newOpp, Map<Id,Opportunity> oldmap, Boolean isDelete){
        Map<String,Map<string,Integer>> allRecords = allRec;
        Map<String,Map<string,Integer>> pcmRecords = new Map<string,Map<string,Integer>>();
        Map<string,Primary_Channels__c> upsertPCRecords = new Map<String,Primary_Channels__c>();
        Map<string,Primary_Channel_Members__c> upsertPCMRecords = new Map<String,Primary_Channel_Members__c>();

        
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
        
        for(Opportunity op: newOpp){
            string res1 = getCampaignCode(op); if(res1=='') continue; 
            if(oldmap!=null){
                allRecords =addRecords(allRecords,pcmRecords,op,'add',res1);
            }else{
                
                if(isDelete){
                    allRecords =addRecords(allRecords,pcmRecords,op,'del',res1);
                }else{
                    allRecords =addRecords(allRecords,pcmRecords,op,'add',res1);
                }
            }
            
        }
        System.debug('^^^^'+allRecords);
        
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
        if(upsertPCRecords.size()>0){ Database.upsert( upsertPCRecords.values(), Primary_Channels__c.Fields.ExternalId__c );}
        if(upsertPCMRecords.size()>0){ Database.upsert( upsertPCMRecords.values(), Primary_Channel_Members__c.Fields.External_Member_Id__c );}
    }
    
    public static Map<string,Map<String,Integer>> addRecords(Map<String,Map<String,Integer>> mapRecords ,Map<String,Map<String,Integer>> oldMapRecords,
                                                             Opportunity cm,string act,String res1){
        string res = res1;
        System.debug('^^^Res'+ res);
        Map<string,Map<String,Integer>> resMap = mapRecords;
                                                                
        Integer count=0;
        if(resMap.containsKey(cm.AccountId) && resMap.get(cm.AccountId).containsKey(res)) 
            count =resMap.get(cm.AccountId).get(res);            
        else if(oldMapRecords.containsKey(cm.AccountId) && oldMapRecords.get(cm.AccountId).containsKey(res))
         count =oldMapRecords.get(cm.AccountId).get(res);
         
        count = (act=='add'? count+1:(count>0?count-1:0)) ;
          System.debug('^^^count'+ count);
        if(!resMap.containsKey(cm.AccountId))
            resMap.put(cm.AccountId, new Map<string,Integer>{res => count});
        else{            
            resMap.get(cm.AccountId).put (res,count); 
        }
           
        System.debug(resMap);
        return resMap;
    }    
    
    public static string getCampaignCode(Opportunity op){
        Set<Id> CampaignEmailType = new Set<Id>((List<Id>)Label.Campaign_Email_Type.split(','));
        Set<Id> CampaignTextId = new Set<Id>((List<Id>)Label.Campaign_Text_Id.split(','));
        String  res='';
        if( op.Produced_By__c=='Righters Group' ) {
            res ='2';
        }else if( op.Produced_By__c=='HSP Direct'){ 
            res ='3';
        }else if(op.Produced_By__c=='Marketing Staff' && (CampaignEmailType.contains(op.campaignId)||  CampaignEmailType.contains(op.Parent_Campaign__c)) ){
            res ='4';
        }else if( op.Produced_By__c=='Marketing Staff' && (CampaignTextId.contains(op.campaignId)|| CampaignTextId.contains(op.Parent_Campaign__c))){
            res ='5';
        }else if(op.Produced_By__c=='ForthRight Strategy'  ) res = '7';
        else if(op.Produced_By__c=='Marketing Staff'  )res= '8';else if(op.Campaign_Record_Type_Name2__c =='Email Campaign' )res= '9';else if(op.Campaign_Record_Type_Name2__c =='Text Campaign' )res= '12';
        else if(op.Campaign_Record_Type_Name2__c =='Other Event' )res= '13';else if(op.Campaign_Record_Type_Name2__c =='Restore Liberty Campaign' )res= '14';else if(op.Campaign_Record_Type_Name2__c =='Trip/Meeting' )res= '15';else if(op.Campaign_Record_Type_Name2__c == 'Direct Mail Campaign' ) res= '16';else if(op.Campaign_Record_Type_Name2__c =='Marketing Segment' )res= '17';
        

        return res;
    }
    
    public static void DonationTask(List<Opportunity> opps, Map<id,Opportunity> OldMap){
        SearchForExistingTask(opps);
    }
    
    public static void SearchForExistingTask(List<Opportunity> opps){
    
    List<Task> taskList = new List<Task>();

    set<id> oppIds = new set<id>();
        for(Opportunity op:  opps){

            oppIds.add(op.Id); 
        }

                                
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select id,amount, Designated_Organization__c,Account.OwnerId,
        AccountId,Account.Owner.Name,Account.recordType.Name,
                                Account.npo02__NumberOfClosedOpps__c,Account.owner.CaseLoad__c,Account.npe01__One2OneContact__c,
        (Select id,dummy_TaskType__c from Tasks) from Opportunity where id=:oppIds]);   
        
        for(Opportunity op:  oppMap.values() ) {
            Boolean CreateNote = true;
            Boolean  CreateCall = true;
            Boolean  CreateResearch = true;
            Boolean caseLoadNote = true;
            Boolean caseLoadCall = true;
            for(Task t: op.Tasks){
            if(t.dummy_TaskType__c =='Call'){
                CreateCall = false;
            }else if(t.dummy_TaskType__c =='Note'){
                CreateNote  = false;
            }else if(t.dummy_TaskType__c =='Research'){
                CreateResearch  = false;
            }else if(t.dummy_TaskType__c =='Caseload Call'){
                caseLoadNote = false;
            }else if(t.dummy_TaskType__c =='Caseload Note'){
                caseLoadCall = false;
            }
            }// end of task forloop. 
            
            

            if(caseLoadNote && op.Account.owner.CaseLoad__c)
            {
                String taskType = 'Thank You Note';
                String ContactedBy = op.Account.Owner.Name;
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = op.Account.OwnerId;
                string sub;
                
                if(op.Account.RecordType.Name =='Household')
                sub = 'Caseload Donation Thank You Note Task';
                if(op.Account.RecordType.Name =='Foundation')
                sub = 'Caseload Foundation Donation Thank You Note Task';
                if(op.Account.RecordType.Name =='Corporation')
                sub= 'Caseload Corporation Donation Thank You Note Task';               
                taskList.add(createTask('Caseload Note',3,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));             
            }
                                  
            else if(CreateNote){
                String taskType = 'Thank You Note';
                                
                if(op.amount>=500 && op.Account.recordType.Name=='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c==0 && !op.Account.owner.CaseLoad__c ){
                String ContactedBy = 'Matt Carnovale';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = '0050b000005fykUAAQ';
                string sub= 'New individual Donor Thank You Note Task';
                taskList.add(createTask('Note',3,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                 
                }
                
                else if(op.amount>=500 && op.Account.recordType.Name=='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c>=1 && !op.Account.owner.CaseLoad__c ){
                String ContactedBy = 'Marie Brown';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = '0050b000005C2vAAAS';
                string sub= 'Non-Caseload Donation Thank You Note Task';
                taskList.add(createTask('Note',3,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                 
                }  
                
                else if(op.amount>=500 && op.Account.recordType.Name!='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c==0 && !op.Account.owner.CaseLoad__c ){
                String ContactedBy = op.Account.RecordType.Name =='Foundation'?'Phil Bell':'Stacey Chamberlin';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = op.Account.RecordType.Name =='Foundation'?'0050b000005C2v0AAC':'0050b0000077QykAAE';
                string sub= op.Account.RecordType.Name =='Foundation'?'New Foundation Donor Thank You Note Task':'New Corporation Donor Thank You Note Task';
                taskList.add(createTask('Note',3,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                  
                }  
                                
                else if(op.amount>=500 && op.Account.recordType.Name!='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c>=1 && !op.Account.owner.CaseLoad__c ){
                String ContactedBy = op.Account.RecordType.Name =='Foundation'?'Phil Bell':'Stacey Chamberlin';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = op.Account.RecordType.Name =='Foundation'?'0050b000005C2v0AAC':'0050b0000077QykAAE';
                string sub= op.Account.RecordType.Name =='Foundation'?'Non-Caseload Foundation Donation Thank You Note Task':'Non-Caseload Corporation Donation Thank You Note Task';
                taskList.add(createTask('Note',3,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                  
                } 
                 
                                                              
            } // create note

            if(caseLoadCall && op.Account.owner.CaseLoad__c)
            {
                String taskType = 'Thank You Call';
                String ContactedBy = op.Account.Owner.Name;
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = op.Account.OwnerId;
                string sub;
                if(op.Account.RecordType.Name =='Household')
                sub = 'Caseload Donation Thank You Call Task';
                if(op.Account.RecordType.Name =='Foundation')
                sub = 'Caseload Foundation Donation Thank You Call Task';
                if(op.Account.RecordType.Name =='Corporation')
                sub= 'Caseload Corporation Donation Thank You Call Task'; 
                taskList.add(createTask('Caseload Call',3,ContactedBy,Description,OwnerId,sub.trim(),'Call',taskType,op.id,whoId ));            
            }              
            else if(CreateCall){
                String taskType = 'Thank You Call';
                
                if(op.amount>=500  && op.Account.recordType.Name=='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c==0 && !op.Account.owner.CaseLoad__c ){
                String ContactedBy = 'Matt Carnovale';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = '0050b000005fykUAAQ';
                string sub= 'New Individual Donor Thank You Call Task';
                taskList.add(createTask('Call',3,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                  
                }
                
                else if(op.amount>=500  && op.Account.recordType.Name=='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c>=1 && !op.Account.owner.CaseLoad__c ){
                String ContactedBy = 'Marie Brown';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = '0050b000005C2vAAAS';
                string sub= 'Non-Caseload Donation Thank You Call Task';
                taskList.add(createTask('Call',3,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId) );                 
                }  
                
                else if(op.amount>=500  && op.Account.recordType.Name!='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c==0 && !op.Account.owner.CaseLoad__c ){
                String ContactedBy = op.Account.RecordType.Name =='Foundation'?'Phil Bell':'Stacey Chamberlin';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = op.Account.RecordType.Name =='Foundation'?'0050b000005C2v0AAC':'0050b0000077QykAAE';
                string sub= op.Account.RecordType.Name =='Foundation'?'New Foundation Donation Thank You Call Task':'New Corporation Donation Thank You Call Task';
                taskList.add(createTask('Call',3,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                 
                }  
                                
                else if(op.amount>=500 && op.Account.recordType.Name!='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c>=1 && !op.Account.owner.CaseLoad__c ){
                String ContactedBy = op.Account.RecordType.Name =='Foundation'?'Phil Bell':'Stacey Chamberlin';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = op.Account.RecordType.Name =='Foundation'?'0050b000005C2v0AAC':'0050b0000077QykAAE';
                string sub= op.Account.RecordType.Name =='Foundation'?'Non-Caseload Foundation Donation Thank You Call Task':'Non-Caseload Corporation Donation Thank You Call Task';
                taskList.add(createTask('Call',3,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                 
                } 
                 
                                                              
            } // create call   
            
            if(CreateResearch){
                String taskType = 'Research';
 
                if(op.amount>= 5000  && op.Account.recordType.Name=='Household' && op.Account.npo02__NumberOfClosedOpps__c==0 && !op.Account.owner.CaseLoad__c){
                String ContactedBy = 'Marie Brown';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = '0050b000005C2vAAAS';
                string sub= 'New Major Donor Research Task';
                taskList.add(createTask('Research',5,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                    
                } 
                
                else if( op.amount>= 5000  && op.Account.recordType.Name !='Household' && !op.Account.owner.CaseLoad__c && op.Account.npo02__NumberOfClosedOpps__c==0){
                String ContactedBy = 'Parissa Sedghi';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = '0050b0000047kXRAAY';
                string sub= op.Account.RecordType.Name =='Foundation'?'New Major Foundation Donor Research Task':'New Corporation Foundation Donor Research Task';
                taskList.add(createTask('Research',5,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                
                }
                
                else if(op.amount>=250 && op.Account.recordType.Name=='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c==0  ){
                String ContactedBy = 'Marie Brown';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = '0050b000005C2vAAAS';
                string sub= 'New Donor Research Task';
                taskList.add(createTask('Research',5,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                 
                }
                
                else if(op.amount>=250 && op.Account.recordType.Name=='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c>=1  ){
                String ContactedBy = 'Marie Brown';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = '0050b000005C2vAAAS';
                string sub= 'Non-Caseload Research Task';
                taskList.add(createTask('Research',5,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));                
                }   
                else if(op.amount>=250  && op.Account.recordType.Name!='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c==0  ){
                String ContactedBy = op.Account.RecordType.Name =='Foundation'?'Phil Bell':'Stacey Chamberlin';
                String Description = op.Designated_Organization__c;
                String whoId = op.Account.npe01__One2OneContact__c;
                String ownerId = op.Account.RecordType.Name =='Foundation'?'0050b000005C2v0AAC':'0050b0000077QykAAE';
                string sub= op.Account.RecordType.Name =='Foundation'?'New Foundation Donor Research Task':'New Corporation Donor Research Task';
                taskList.add(createTask('Research',5,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));               
                }  
                            
                else if(op.amount>=250 && op.Account.recordType.Name!='Household' 
                && op.Account.npo02__NumberOfClosedOpps__c>=1 ){
                 String ContactedBy = op.Account.RecordType.Name =='Foundation'?'Phil Bell':'Stacey Chamberlin';
                 String Description = op.Designated_Organization__c;
                 String whoId = op.Account.npe01__One2OneContact__c;
                 String ownerId = op.Account.RecordType.Name =='Foundation'?'0050b000005C2v0AAC':'0050b0000077QykAAE';
                 string sub= op.Account.RecordType.Name =='Foundation'?'Non-Caseload Foundation Donor Research Task':'Non-Caseload Corporation Donor Research Task';
                taskList.add(createTask('Research',5,ContactedBy,Description,OwnerId,sub.trim(),'',taskType,op.id,whoId ));
                }              
            } // research task       
        }// opp lopp  
        if(taskList.size()>0)
            Insert taskList;                 
    }  
    
    public static Task createTask(String dummyTaskType,Integer days,String ContactedBy,String Description,String ownerId,String sub, String subTyp,String ty,
    String whatId,String whoId){
       return new Task(ActivityDate =getDate(days).date(),Contacted_By__c=ContactedBy ,Description =Description,OwnerId=ownerId,
        Priority='High',Status='Planned',Subject=sub,TaskSubtype=subTyp,type=ty,whatId=whatId,whoId=whoId,
        dummy_TaskType__c =dummyTaskType );
    }
    
    public static DateTime getDate(Integer days){
            List<Businesshours > bh= [Select id,name from Businesshours where name ='DonationTasks'];
            DateTime pointer = system.Now();    
            Integer elapsed = 1;
            while (elapsed < days)
            {
            pointer = pointer.addDays(1);
            if (BusinessHours.isWithin(bh[0].Id, pointer)) elapsed++;
            else pointer = BusinessHours.nextStartDate(bh[0].Id,pointer );
            }
            return pointer;
    }
}