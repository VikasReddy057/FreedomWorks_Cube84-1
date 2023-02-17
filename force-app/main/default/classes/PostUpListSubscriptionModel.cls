public class PostUpListSubscriptionModel {
	
    public Integer recipientId;
    public String modifiedTime;
    public String status;
    
    public PostUpListSubscriptionModel(Integer recipientId, String status, String modifiedTime) {
        this.recipientId = recipientId;
        this.status = status;
        this.modifiedTime = modifiedTime;
    }
}