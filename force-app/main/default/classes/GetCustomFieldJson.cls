public class GetCustomFieldJson{
    
	public Integer customFieldId;
	public String title;	
	public boolean active;
	public String type_Z;	
    
	public static GetCustomFieldJson[] parse(String json){
        System.debug('GetCustomFieldJson : parse');
		return (List<GetCustomFieldJson>) System.JSON.deserialize(json.replaceAll('type', 'type_Z'), List<GetCustomFieldJson>.class);
	}
}