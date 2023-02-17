public class GetBrandIdsJsonToApex {

	public Integer brandId;
	public String title;
	public String externalId;
	public String channel;
	public Boolean active;
	
	public static List<GetBrandIdsJsonToApex> parse(String json) {
        System.debug('GetBrandIdsJsonToApex : parse');
		return (List<GetBrandIdsJsonToApex>) System.JSON.deserialize(json, List<GetBrandIdsJsonToApex>.class);
	}
}