/*
 * 1. Retrive the PostUp Fields(Custom, Standard and Recipient fields) from PostUpFieldMap__c Custom object/From API(after clicking sync button first time) 
 * 2. After save the PostUp mapped fields insert the mapped field values with corresponding Salesforce Field along the PostUp field type and table name
 * 3. Show the Mapped PostUp fields alsong the Salesforce Field, Data type in PostUp and Table Name
 * 4. Save the Cron Frequency (time interval to run the schedule job) in custom object
 * 5. Stop the Running Schedule job by a button Click
*/
public with sharing class PostUpSalesforceFieldMapping {
    
    public Integer frequencyTime {get;set;}
    public Integer frequencyTimehr {get;set;}
    public Boolean viewFlag {get;set;}
    public Boolean editFlag {get;set;}
    public SelectOption[] address { get;set; }
    Map<String, Schema.SObjectField> objectFields
                        = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
	
    //Retrieve Values to UI(VFP)
    public PostUpSalesforceFieldMapping() {
        System.debug('PostUpSalesforceFieldMapping : PostUpSalesforceFieldMapping');
        editFlag= false;
        viewFlag = true;
        Schema.DescribeSObjectResult oppDescribe = Contact.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = oppDescribe.fields.getMap();
        this.address = new SelectOption[]{};
        this.address.add(new SelectOption('', '--None--'));
        for (Schema.SObjectField field: fields.Values())
        {
            this.address.add(new SelectOption(''+field,''+field));
        }
        PostUpFieldMap__c[] postUpCronRecordList = [select PostUp_Cron_Time__c, name from PostUpFieldMap__c where PostUp_Cron_Time__c !=: null AND Name = 'Cron Time'];
        if(!postUpCronRecordList.isEmpty()) {
            for(PostUpFieldMap__c postUpCronRecord : postUpCronRecordList) {
                frequencyTime = (Integer) postUpCronRecord.PostUp_Cron_Time__c;
            } 
        }
        PostUpFieldMap__c[] postUpCronHrRecordList = [select PostUp_Cron_Time__c, name from PostUpFieldMap__c where PostUp_Cron_Time__c !=: null AND Name = 'Cron Time Hr'];
        if(!postUpCronHrRecordList.isEmpty()) {
            for(PostUpFieldMap__c postUpCronRecord : postUpCronHrRecordList) {
                frequencyTimehr = (Integer) postUpCronRecord.PostUp_Cron_Time__c;
            } 
        }
    }

	//Retrieve the all SF fields from SF custom object except CronJob time to map with PostUp
    public PostUpFieldMap__c[] listPostUpField = [Select Name, FieldName__c, SfField__c, PostUp_Field_Type__c, PostUp_Table__c, SalesforceField__c From PostUpFieldMap__c Where Name != 'Cron Time' AND Name != 'Cron Time Hr'];
    
    //Method is called from VFP To show all the fields in UI
    public List<PostUpFieldMap__c> getFields() {
	 	return sortFieldOrder(listPostUpField);
    }
    
    //Save the mapped field names(PostUp and SF fields)
    public void saveFieldMap() {
        System.debug('PostUpSalesforceFieldMapping : saveFieldMap');
        Boolean renderFlag = true;
        for(PostUpFieldMap__c field : listPostUpField) {
            for(Schema.SObjectField fld :objectFields.values()){
                schema.describeFieldResult dfield = fld.getDescribe();
                string fldType = string.valueOf(dfield.getType()); 
                if(dfield.Name == field.SfField__c) {
                    if(fldType == 'REFERENCE') field.SalesforceField__c = dfield.getRelationshipName()+'.Name';
                    else field.SalesforceField__c = field.SfField__c;
                }
                if(field.SfField__c == null) field.SalesforceField__c = field.SfField__c;
            }
             
            if(field.Name ==  'Address' || field.Name ==  'ExternalId') {
                if(field.SfField__c == null) {
                    renderFlag = false;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Choose Salesforce field for required PostUP field'));
                }
                else {
                    update field;
                }
            }
            else{
                update field;
            }
        } 
        if(renderFlag) {
            editFlag= false;
        	viewFlag = true;
        }
    }
    
    //Retrive the fields from PostUp API and Salesforce Custom object after clicking sync button
    public void sync() {
        System.debug('PostUpSalesforceFieldMapping : sync');
        GetCustomField.getCustomField(); //Store Custom Fields initially.
        storePostUpStandardFields();
        storePostUpRecipientFields();
    }
    
    public List<PostUpFieldMap__c> getMappedFields() {
        System.debug('PostUpSalesforceFieldMapping : getMappedFields');
        return sortFieldOrder([Select Name, FieldName__c, SfField__c, PostUp_Field_Type__c, PostUp_Table__c From PostUpFieldMap__c where SfField__c !=: '']);
    }
    
    public void editFieldMap() {
        System.debug('PostUpSalesforceFieldMapping : editFieldMap');
        editFlag = true;
        viewFlag = false;
    }
    
    public void storePostUpRecipientFields() {
        System.debug('PostUpSalesforceFieldMapping : storePostUpRecipientFields');
        Boolean recipientFieldflag = true;
        PostUpFieldMap__c[] PostUpFieldMaps = [Select Name, FieldName__c, SfField__c From PostUpFieldMap__c];
        for(PostUpFieldMap__c postUpField : PostUpFieldMaps) {
            if(postUpField.FieldName__c == 'address') {
                recipientFieldflag = false;
            }
        }
        if(recipientFieldflag) {
            List<StorePostUpRecipientFieldJson> recipientFieldsMaps = StorePostUpStandardFields.storePostUpRecipientFields();
            for(StorePostUpRecipientFieldJson recipientFieldsMap : recipientFieldsMaps) {
                PostUpFieldMap__c postUpField = new PostUpFieldMap__c(Name = recipientFieldsMap.Name, FieldName__c = recipientFieldsMap.FieldName, PostUp_Field_Type__c = recipientFieldsMap.PostUpFieldType, PostUp_Table__c = 'Recipients');
                insert postUpField;
            }
        }
    }
    
    public void storePostUpStandardFields() {
        System.debug('PostUpSalesforceFieldMapping : storePostUpStandardFields');
        Boolean standardFieldflag = true;
        PostUpFieldMap__c[] PostUpFieldMaps = [Select Name, FieldName__c, SfField__c From PostUpFieldMap__c];
        for(PostUpFieldMap__c postUpField : PostUpFieldMaps) {
            if(postUpField.FieldName__c == 'FirstName') {
                standardFieldflag = false;
            }
        }
         
        if(standardFieldflag) {
            List<StorePostUpStandardFieldJson> standardFieldsMaps = StorePostUpStandardFields.storePostUpStandardFields();
            for(StorePostUpStandardFieldJson standardFieldsMap : standardFieldsMaps) {
                PostUpFieldMap__c postUpField = new PostUpFieldMap__c(Name = standardFieldsMap.FieldName, FieldName__c = standardFieldsMap.FieldName, PostUp_Field_Type__c = standardFieldsMap.PostUpFieldType, PostUp_Table__c = 'Standard Field');
                insert postUpField;
            }
        }
    }
    
    public static void stopCronJob() {
        System.debug('PostUpSalesforceFieldMapping : stopCronJob');
       /* List<CronTrigger> cronJobs = [SELECT Id FROM CronTrigger];
        new CronStopper(cronJobs);*/
        Database.executeBatch(new CronStopperBatch(), 150);
    }
    
    public void saveCronFrequency() {
        System.debug('PostUpSalesforceFieldMapping : saveCronFrequency');
        PostUpFieldMap__c[] postUpCronRecordList = [select PostUp_Cron_Time__c, name from PostUpFieldMap__c where PostUp_Cron_Time__c !=: null AND Name = 'Cron Time'];
        PostUpFieldMap__c[] postUpCronHrRecordList = [select PostUp_Cron_Time__c, name from PostUpFieldMap__c where PostUp_Cron_Time__c !=: null AND Name = 'Cron Time Hr'];
        if(postUpCronRecordList.isEmpty()) {
            PostUpFieldMap__c postUpCronRecord = new PostUpFieldMap__c();
            postUpCronRecord.Name = 'Cron Time';
            postUpCronRecord.PostUp_Cron_Time__c = frequencyTime;
            insert postUpCronRecord;
        }
        else {
            for(PostUpFieldMap__c postUpCronRecord : postUpCronRecordList) {
                if(postUpCronRecord.Name == 'Cron Time') {
                    postUpCronRecord.PostUp_Cron_Time__c = frequencyTime;
                    update postUpCronRecord;
                }
            }
        }
        if(postUpCronHrRecordList.isEmpty()) {
            PostUpFieldMap__c postUpCronRecord = new PostUpFieldMap__c();
            postUpCronRecord.Name = 'Cron Time Hr';
            postUpCronRecord.PostUp_Cron_Time__c = frequencyTimehr;
            insert postUpCronRecord;
        }
        else {
            for(PostUpFieldMap__c postUpCronRecord : postUpCronHrRecordList) {
                if(postUpCronRecord.Name == 'Cron Time Hr') {
                    postUpCronRecord.PostUp_Cron_Time__c = frequencyTimehr;
                    update postUpCronRecord;
                }
            }
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'CronJob will run for every '+frequencyTime + ' hour (GetPostUpSubscriptionDetail) And CronJob will run for every '+ frequencyTimehr+' hour (GetPostUpRecipientDetail)'));
    }
    
    public PostUpFieldMap__c[] sortFieldOrder(PostUpFieldMap__c[] customObjectFieldList) {
        Map<String, PostUpFieldMap__c> contactMap = new Map<String, PostUpFieldMap__c>();
        List<String> sortThis = new List<String>();
        for(PostUpFieldMap__c c : customObjectFieldList)
        {
            contactMap.put(c.Name, c); 
            sortThis.add(c.Name);
        }
        sortThis.sort(); // Sort by Name in this case    
        List<PostUpFieldMap__c> nameSortedContacts = new List<PostUpFieldMap__c>();
        
        for(String s : sortThis)
        {
            nameSortedContacts.add(contactMap.get(s));
        }
        System.debug(nameSortedContacts);
        return nameSortedContacts;
    }
}