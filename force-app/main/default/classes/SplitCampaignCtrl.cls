public class SplitCampaignCtrl {
    @AuraEnabled
    public static DataTableResponse getData(String RecordTypes, String contactId, String strFieldSet,String cmpType ){
        List<CampaignMember> cmList = new List<CampaignMember>();
        String strObjectName = 'CampaignMember';
        String strFieldSetName = 'Split';
		System.debug('cmpType:'+ cmpType);   
        System.debug('strFieldSet:'+ strFieldSet); 
        System.debug('RecordTypes:'+ RecordTypes); 
        System.debug('contactId:'+ contactId);
        
		/*Map<String,String> sectionMap = new Map<string,String>();
        sectionMap.put('active', 'Trip/Meeting,Other Event,Advocacy Campaign,Advocacy Segment');
        sectionMap.put('historical', 'Direct Mail Campaign,Email Campaign,Text campaign,Marketing Segment');  
        SectionMap.put('maketingList','Marketing List');
        SectionMap.put('restro','Restore Liberty Campaign');*/
        
         //Get the fields from FieldSet
        Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();            
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSet);
        
        //To hold the table hearders 
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        
        //Field to be queried - fetched from fieldset
        List<String> lstFieldsToQuery = new List<String>();
        
        //The final wrapper response to return to component
        DataTableResponse response = new DataTableResponse();
        Map<String,String> relatedfields = new Map<string,String>();
        System.debug(fieldSetObj.getFields());
        Integer count = 0;
        for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
            String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
            //This way we can set the type of a column
            if(dataType == 'datetime'){
                dataType = 'date';
            }
            if(dataType == 'textarea'){
                dataType = 'text';
            }
            DataTableColumns datacolumns ;
            if(String.valueOf(eachFieldSetMember.getFieldPath())== 'CampaignId'){
				System.debug('###'+String.valueOf(eachFieldSetMember.getFieldPath()));
             datacolumns = new DataTableColumns( 
            String.valueOf(eachFieldSetMember.getFieldPath()) == 'CampaignId' ?'Name' :String.valueOf(eachFieldSetMember.getLabel()) , 
            String.valueOf(eachFieldSetMember.getFieldPath()) == 'CampaignId' ?'cpName': String.valueOf(eachFieldSetMember.getFieldPath()), 
            String.valueOf(eachFieldSetMember.getFieldPath()) == 'CampaignId' ? 'url': dataType,
            String.valueOf(eachFieldSetMember.getFieldPath()) == 'CampaignId'? new attibutes(new fieldnamecls('CName'),'_blank'):null );                
            }
            else if(String.valueOf(eachFieldSetMember.getFieldPath()).contains('Campaign.')){
                count = count+1;
                relatedfields.put(String.valueOf(eachFieldSetMember.getFieldPath()), 'Campaign'+string.valueof(count));
                datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()),'Campaign'+string.valueof(count),  
                 									dataType,
                   								    null );
                            
            }
            
            else if(String.valueOf(eachFieldSetMember.getFieldPath()).contains('Contact.')){count = count+1;relatedfields.put(String.valueOf(eachFieldSetMember.getFieldPath()), 'Contact'+string.valueof(count));datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()),'Contact'+string.valueof(count), dataType, null );               
            }
            else{
             datacolumns = new DataTableColumns( 
            String.valueOf(eachFieldSetMember.getFieldPath()) == 'Name' ?'CampaignMember Name' :String.valueOf(eachFieldSetMember.getLabel()) , 
            String.valueOf(eachFieldSetMember.getFieldPath()) == 'Name' ?'cmpName': String.valueOf(eachFieldSetMember.getFieldPath()), 
            String.valueOf(eachFieldSetMember.getFieldPath()) == 'Name' ? 'url': dataType,
            String.valueOf(eachFieldSetMember.getFieldPath()) == 'Name'? new attibutes(new fieldnamecls('Name'),'_blank'):null );
            }
			lstDataColumns.add(datacolumns);
            lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
        }

        //Form an SOQL to fetch the data - Set the wrapper instance and return as response
        if(! lstDataColumns.isEmpty()){
            response.lstDataTableColumns = lstDataColumns;
                          
            response.lstDataTableColumns = lstDataColumns;

            
            String queryString = 'select Id,ContactId';
            for(Schema.FieldSetMember fld :SObjectType.CampaignMember.FieldSets.getMap().get(strFieldSetName).getFields()) {
                queryString += ', ' + fld.getFieldPath();
            }
            System.debug('queryString:'+ queryString);  
            queryString += ' from CampaignMember ';
            String filters ='';
            if(String.isNotBlank(contactId)){
                filters   = filters + ' (ContactId =:contactId) ';
            }
            List<String> Names = new List<string>();
            List<String> additionalNames= new List<string>();
            System.debug(recordTypes.contains('99'));
            if(String.isNotBlank(recordTypes)){
                if(recordTypes.contains('99')){
                    for(String st1 : recordTypes.Split('99')[1].Split(';'))
                        additionalNames.add(st1);
                    for(String st2: recordTypes.Split('99')[0].Split(';'))           
                        Names.add(st2);
                }
                else if(recordTypes.contains(';')){
                    for(String st2: recordTypes.Split(';'))           
                       Names.add(st2);
                   }
				else
                    Names.add(RecordTypes);

                   
               System.debug('RecordTypes:'+ additionalNames);
               System.debug('RecordTypes:'+ Names); 
            }
            String additionalFilter ='';
            if(String.isNotBlank(cmpType) && cmpType == 'Historical Campaigns'){
                Date strDate = System.today();
                System.debug(strDate);
                //' Campaign.StartDate < '+ System.now().format('yyyy-MM-dd')
				additionalFilter = ' Campaign.StartDate <: strDate';

            }
            else if(String.isNotBlank(cmpType) && cmpType == 'Active Campaigns'){
                Date strDate = System.today();
                
				filters = filters+ ' AND Campaign.StartDate >='+ System.now().format('yyyy-MM-dd') ;
            }
            if(Names.size()>0 ||  additionalNames.size()>0){
                string loctemp ='';
                //
                if(Names.size()>0 && additionalNames.size()>0)
                    loctemp =  ' ((Campaign.RecordType.Name =:Names) OR ( Campaign.RecordType.Name =:additionalNames AND '+ additionalFilter+')) ';
                else if(Names.size()>0)
                    loctemp =  ' Campaign.RecordType.Name =:Names ' ;
                    else if (additionalNames.size()>0)
                    loctemp =  ' Campaign.RecordType.Name =:additionalNames AND '+ additionalFilter +' ';
                System.debug('loctemp'+ loctemp);
                filters   = filters==''? loctemp : filters+ ' AND '+ loctemp;
            }
 			System.debug('Final filters'+ filters);
            queryString = filters==''? queryString+ ' limit 1000': queryString+ ' Where '+ filters+ ' limit 1000';
            System.debug(queryString);
            System.debug(queryString.split('Where')[1]);
            List<CampaignMember> cmpList = Database.query(queryString);
            List<Object> genericMap = (List<Object> ) JSON.deserializeUntyped(JSON.serialize(cmpList));
            List<Object> genericMapFinal = new List<Object>();
            for(Object  sobj:  genericMap){
                Map<String,Object> obj = (Map<String,Object>) sobj;
                for(String apis: relatedfields.keySet())
                {
					System.debug(apis);
                    Map<String,Object> cmpObjLoc = (Map<String,Object>)obj.get('Campaign');
                    map<string,Object> conObjLoc = (Map<String,Object>) obj.get('Contact');
                    System.debug(conObjLoc);
                    System.debug(obj.get(apis));
                    if(apis.contains('Campaign.') && cmpObjLoc!=null && cmpObjLoc.get(apis.split('\\.')[1])!=null)
                        obj.put(relatedfields.get(apis),cmpObjLoc.get(apis.split('\\.')[1]));
                    else if(apis.contains('Contact.') && conObjLoc !=null && conObjLoc.get(apis.split('\\.')[1])!=null){
                        obj.put(relatedfields.get(apis),conObjLoc.get(apis.split('\\.')[1]));
                    }
                    
                }
                genericMapFinal.add(obj);
            }
            response.lstDataTableData = genericMapFinal;
            
        }
         return response;
    }

    

    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled 
        public attibutes typeAttributes {get;set;}
        
        public DataTableColumns(String label, String fieldName, String type,attibutes attStr){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
			this.typeAttributes= attStr;            
        }
    }
    
    public class attibutes{
        @AuraEnabled
        public fieldnamecls label;
        @AuraEnabled
        public String target;	
		
        public  attibutes( fieldnamecls fn,String tr){
            this.label = fn;
            this.target = tr;
        }
    } 
    public class fieldnamecls {
        @AuraEnabled
        public String fieldName;	
        public fieldnamecls(string fn){
            this.fieldName = fn;
        }
    }     
        
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<Object> lstDataTableData {get;set;}                
        
        public DataTableResponse(){
            lstDataTableColumns = new List<DataTableColumns>();
            lstDataTableData = new List<sObject>();
        }
    }

 
}