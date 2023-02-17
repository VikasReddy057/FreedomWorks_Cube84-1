@isTest
public class GetCustomFieldTest {
    @isTest static void testGetCustomFieldEmptyList() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetCustomFields');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        GetCustomField.getCustomField();
        Test.StopTest();
    }
    @isTest static void testGetCustomField() {
        PostUpFieldMap__c mapFieldStatus = new PostUpFieldMap__c(Name = 'County', FieldName__c = 'County', PostUp_Field_Type__c = 'TEXT_MEDIUM', PostUp_Table__c = 'Custom Field');
        insert mapFieldStatus;
        PostUpFieldMap__c[] postUpFieldList = [select Name, FieldName__c, PostUp_Field_Type__c, PostUp_Table__c from PostUpFieldMap__c];
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetCustomFields');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        HTTPResponse res =null;
        Test.StartTest();
        GetCustomField.getCustomField();
        Test.StopTest();
    }
}