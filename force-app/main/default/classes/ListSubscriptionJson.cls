public class ListSubscriptionJson{
    
	public Integer mailingId;	
	public Integer listId;	
	public Integer recipientId;	
	public String status;	
	public boolean confirmed;
	public String sourceId;
	public String dateUnsub;	
	public String dateJoined;	
	public String address;	
    
	public static ListSubscriptionJson parse(String json){ 
        System.debug('ListSubscriptionJson : parse');
		return (ListSubscriptionJson) System.JSON.deserialize(json, ListSubscriptionJson.class);
	}
    
    public static ListSubscriptionJson[] parseList(String json){
        System.debug('ListSubscriptionJson : parseList');
		return (ListSubscriptionJson[]) System.JSON.deserialize(json, ListSubscriptionJson[].class);
	}
}