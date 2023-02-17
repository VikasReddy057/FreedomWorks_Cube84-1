public class PostUpListJson {
    
        public Integer listId;	
        public String title;	
        public String friendlyTitle;	
        public String description;
        public boolean populated;
        public boolean publicSignup;
        public boolean globalUnsub;
        public String query;
        public Integer categoryId;
        public String blockDomains;
        public Integer seedListId;	
        public String createTime;	
        public String creator;	
        public String externalId;	
        public String custom1;	
        public String channel;	
        public boolean countRecips;
        public List<Integer> brandIds;
        public Integer listCount;	
        public boolean testMessageList;
    
    public static PostUpListJson[] parse(String json){
        System.debug('PostUpListJson : parse');
        return (List<PostUpListJson>) System.JSON.deserialize(json, List<PostUpListJson>.class);
    }
    
    public static PostUpListJson parsePostUpListJson(String json){
        System.debug('PostUpListJson : parsePostUpListJson');
        return (PostUpListJson) System.JSON.deserialize(json, PostUpListJson.class);
    }
}