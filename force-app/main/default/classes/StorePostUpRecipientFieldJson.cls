public class StorePostUpRecipientFieldJson {
    
    public String Name;
    public String FieldName;
    public String PostUpFieldType;
    
    public static List<StorePostUpRecipientFieldJson> parse(String json) {
        System.debug('StorePostUpRecipientFieldJson : parse');
        return (List<StorePostUpRecipientFieldJson>) System.JSON.deserialize(json.replaceAll('FieldName__c','FieldName'), List<StorePostUpRecipientFieldJson>.class);
    }
}