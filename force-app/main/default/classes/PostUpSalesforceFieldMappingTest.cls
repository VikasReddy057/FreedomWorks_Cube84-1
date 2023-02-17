@isTest
public class PostUpSalesforceFieldMappingTest {
    
    @isTest static void testPostUpSalesforceFieldMappingt() {
        PostUpFieldMap__c postUpFieldMap = new PostUpFieldMap__c(PostUp_Cron_Time__c = 1, Name= 'Cron Time');
        insert postUpFieldMap;
        PostUpFieldMap__c postUpFieldMaphr = new PostUpFieldMap__c(PostUp_Cron_Time__c = 1, Name= 'Cron Time Hr');
        insert postUpFieldMaphr;
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
    }
    
    @isTest static void testSaveMapFlag() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        fieldmap.saveFieldMap();
    }
    @isTest static void testSaveMapLoop() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(Name = 'Address');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(Name = 'ExternalId');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        fieldmap.listPostUpField = [select Name, SfField__c from PostUpFieldMap__c where Name='Address' OR Name='ExternalId'];
        for(PostUpFieldMap__c postUpField : fieldmap.listPostUpField) {
            fieldmap.saveFieldMap(); 
        }
    }
    @isTest static void testSaveMapNotNull() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldAddress = new PostUpFieldMap__c(Name = 'Address', SfField__c = 'Email');
        PostUpFieldMap__c mapFieldExternalId = new PostUpFieldMap__c(Name = 'ExternalId', SfField__c = 'Id');
        insert mapFieldAddress;
        insert mapFieldExternalId;
        fieldmap.listPostUpField = [select Name, SfField__c from PostUpFieldMap__c where Name='Address' OR Name='ExternalId'];
        for(PostUpFieldMap__c postUpField : fieldmap.listPostUpField) {
            fieldmap.saveFieldMap(); 
        }
    }
    @isTest static void testSaveMapElse() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapFieldStatus = new PostUpFieldMap__c(Name = 'status', SfField__c = 'Email');
        insert mapFieldStatus;
        fieldmap.listPostUpField = [select Name, SfField__c from PostUpFieldMap__c];
        for(PostUpFieldMap__c postUpField : fieldmap.listPostUpField) {
            fieldmap.saveFieldMap(); 
        }
    }
    @isTest static void testgetFields() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        fieldmap.getFields();
    }
    @isTest static void testgetMappedFields() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        fieldmap.getMappedFields();
    }
    @isTest static void testeditFieldMap() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        fieldmap.editFieldMap();
    }
    @isTest static void teststorePostUpRecipientFields() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapField = new PostUpFieldMap__c(FieldName__c='address');
        insert mapField;
        fieldmap.storePostUpRecipientFields();
    }
    @isTest static void teststorePostUpStandardFields() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c mapField = new PostUpFieldMap__c(FieldName__c='FirstName');
        insert mapField;
        fieldmap.storePostUpStandardFields();
    }
    @isTest static void testsync() {
        PostUpSalesforceFieldMapping fieldmap = new PostUpSalesforceFieldMapping();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetCustomFields');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        fieldmap.sync();
        Test.StopTest();
    }
    @isTest static void testStopCronJob() {
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        Id jobId = System.schedule('GetPostUpSubscriptionDetail', CRON_EXP, new GetPostUpSubscriptionDetail());
        System.schedule('GetPostUpRecipientDetail', CRON_EXP, new GetPostUpRecipientDetail());
        PostUpSalesforceFieldMapping.stopCronJob();
        Test.stopTest();
    }
    @isTest static void testSaveCronFrequencyIf() {
        PostUpSalesforceFieldMapping postUpSalesforceFieldMapping = new PostUpSalesforceFieldMapping();
        postUpSalesforceFieldMapping.saveCronFrequency();
    }
    @isTest static void testSaveCronFrequencyElse() {
        PostUpSalesforceFieldMapping postUpSalesforceFieldMapping = new PostUpSalesforceFieldMapping();
        PostUpFieldMap__c postUpFieldMap = new PostUpFieldMap__c(PostUp_Cron_Time__c = 1, Name= 'Cron Time');
        insert postUpFieldMap;
        PostUpFieldMap__c postUpFieldMapHr = new PostUpFieldMap__c(PostUp_Cron_Time__c = 1, Name= 'Cron Time Hr');
        insert postUpFieldMapHr;
        postUpSalesforceFieldMapping.saveCronFrequency();
    }
}