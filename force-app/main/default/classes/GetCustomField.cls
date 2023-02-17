/*
 * Get PostUp Custom Fields
 */ 
public class GetCustomField {
    
    public static void getCustomField() {
        System.debug('GetCustomField : getCustomField');
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:PostUp/customfield');
        Http http = new Http();
        HttpResponse res = http.send(req);
        GetCustomFieldJson[] jsonValue = GetCustomFieldJson.parse(res.getBody());
        for(GetCustomFieldJson customFieldValue : jsonValue) {
            PostUpFieldMap__c[] postUpFieldList =[Select Name, FieldName__c, PostUp_Field_Type__c, PostUp_Table__c from PostUpFieldMap__c where FieldName__c = :customFieldValue.title];
            if(!postUpFieldList.isEmpty()) {
                for(PostUpFieldMap__c postUpField : postUpFieldList) {
                    if(postUpField.FieldName__c == customFieldValue.title) {
                        postUpField.Name = customFieldValue.title;
                        postUpField.FieldName__c = customFieldValue.title;
                        postUpField.PostUp_Table__c = 'Custom Field';
                        postUpField.PostUp_Field_Type__c = customFieldValue.type_Z;
                        update postUpField;
                    }
                }
            }
            else {
                PostUpFieldMap__c newPostUpField = new PostUpFieldMap__c();
                newPostUpField.Name = customFieldValue.title;
                newPostUpField.FieldName__c = customFieldValue.title;
                newPostUpField.PostUp_Table__c = 'Custom Field';
                newPostUpField.PostUp_Field_Type__c = customFieldValue.type_Z;
                insert newPostUpField;
            }
        }
    }
    
}