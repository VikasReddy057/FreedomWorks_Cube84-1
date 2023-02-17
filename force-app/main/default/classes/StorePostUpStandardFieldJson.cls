public class StorePostUpStandardFieldJson {
    
    public String FieldName;
    public String PostUpFieldType;
    
    public static List<StorePostUpStandardFieldJson> parse(String json) {
        System.debug('StorePostUpStandardFieldJson : parse');
        return (List<StorePostUpStandardFieldJson>) System.JSON.deserialize(json, List<StorePostUpStandardFieldJson>.class);
    }
}