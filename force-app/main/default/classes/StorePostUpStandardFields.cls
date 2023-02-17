public class StorePostUpStandardFields {
    
    public static List<StorePostUpRecipientFieldJson> storePostUpRecipientFields() {
        String json = '[{\"Name\":\"Address\",\"FieldName__c\":\"address\",\"PostUpFieldType\":\"String\"},{\"Name\":\"ExternalId\",\"FieldName__c\":\"externalId\",\"PostUpFieldType\":\"String\"},{\"Name\":\"Status\",\"FieldName__c\":\"status\",\"PostUpFieldType\":\"String\"},{\"Name\":\"SourceDescription\",\"FieldName__c\":\"sourceDescription\",\"PostUpFieldType\":\"String\"},{\"Name\":\"SignupIP\",\"FieldName__c\":\"signupIP\",\"PostUpFieldType\":\"String\"},{\"Name\":\"ThirdPartySource\",\"FieldName__c\":\"thirdPartySource\",\"PostUpFieldType\":\"String\"},{\"Name\":\"ThirdPartySignupDate\",\"FieldName__c\":\"thirdPartySignupDate\",\"PostUpFieldType\":\"DateTime\"}]';
        System.debug(StorePostUpRecipientFieldJson.parse(json));
        return StorePostUpRecipientFieldJson.parse(json);
    }
    
    public static List<StorePostUpStandardFieldJson> storePostUpStandardFields() {
        String json = '[{\"FieldName\": \"FirstName\", \"PostUpFieldType\": \"nvarchar(255)\"},{\"FieldName\": \"LastName\", \"PostUpFieldType\": \"nvarchar(255)\"},{\"FieldName\": \"_Address1\", \"PostUpFieldType\": \"nvarchar(100)\"},{\"FieldName\": \"_Address2\", \"PostUpFieldType\": \"nvarchar(100)\"},{\"FieldName\": \"_City\", \"PostUpFieldType\": \"nvarchar(100)\"},{\"FieldName\": \"_State\", \"PostUpFieldType\": \"nvarchar(100)\"},{\"FieldName\": \"_PostalCode\", \"PostUpFieldType\": \"nvarchar(100)\"},{\"FieldName\": \"_Country\", \"PostUpFieldType\": \"nvarchar(100)\"},{\"FieldName\": \"_Gender\", \"PostUpFieldType\": \"nvarchar(50)\"},{\"FieldName\": \"_DateOfBirth\", \"PostUpFieldType\": \"nvarchar(100)\"},{\"FieldName\": \"_MaritalStatus\", \"PostUpFieldType\": \"nvarchar(100)\"},{\"FieldName\": \"_HouseHoldSize\", \"PostUpFieldType\": \"Integer\"},{\"FieldName\": \"_HouseHoldIncome\", \"PostUpFieldType\": \"nvarchar(50)\"},{\"FieldName\": \"_Salutation\", \"PostUpFieldType\": \"nvarchar(10)\"},{\"FieldName\": \"_HomePhone\", \"PostUpFieldType\": \"nvarchar(50)\"},{\"FieldName\": \"_WorkPhone\", \"PostUpFieldType\": \"nvarchar(50)\"},{\"FieldName\": \"_Profession\", \"PostUpFieldType\": \"nvarchar(50)\"},{\"FieldName\": \"_Education\", \"PostUpFieldType\": \"nvarchar(50)\"}]';
        System.debug(StorePostUpStandardFieldJson.parse(json));
        return StorePostUpStandardFieldJson.parse(json);
    }
}