/*
 * 1. Create New List in PostUp for the Syncing Campaign and also to avoid calling the method from Future callout method is called with System.isFuture check
 * 2. If list is already exists with the same name then retrive ListId of the list with that campaign name
 * 3. Update the List with ListId that is retrived from #2
 * 4. Getting BrandIds for List creation and Updation from PostUp
 * 5. Update the Campaign with ListId for Syncing Campaign in SF
 */ 
public class PostUpListController {
    
    public String status;
    public Data data;
    class Data {
        public String message;
    }    
    public static Http http = new Http();
    
    //Create a new PostUp List for Syncing Campaign in SF
    public static void createList(String title, String id, String status) {
        System.debug('PostUpListController : createList');
        if(!System.isFuture()) {
            createListFuture(title, id, status); 
        }
    }
    
    //Only call from trigger
  //  @future(callout=true)
    public static Integer createListFuture(String title, String id, String status) {
        System.debug('PostUpListController : createListFuture');
        Map<String, object> reqJson = new Map<String, object>();
        reqJson.put('title', title);
        reqJson.put('populated', true);
        reqJson.put('publicSignup', false);
        reqJson.put('globalUnsub', false);
        reqJson.put('channel', 'E');
        reqJson.put('countRecips', true);
        reqJson.put('friendlyTitle', title);
        reqJson.put('description', title);
        reqJson.put('brandIds', getBrandIds());
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setBody(JSON.serialize(reqJson));
        req.setEndpoint('callout:PostUp/list');
        HttpResponse res = http.send(req);
        Integer listId;
        if(checkResponse(res.getBody())) {
            System.debug('List is created Successfully');
            PostUpListJson listResponse = PostUpListJson.parsePostUpListJson(res.getBody());
            listId = listResponse.listId;
            updateListId(listResponse.listId, id);
        }
        else {
            System.debug(parse(res.getBody()).data.message);
            if('A list with this title already exists. Please select a new title.' == parse(res.getBody()).data.message) {
                listId = getAllPostUpList(title);
                updatePostUpList(listId, title, id, status);
            }
        }
        return listId;
    }
    
    //Get all List from PostUp based on the title
    public static Integer getAllPostUpList(String title) {
        System.debug('PostUpListController : getAllPostUpList');
        Integer listId;
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:PostUp/list');
        HttpResponse res = http.send(req);
        PostUpListJson[] postUpListJson = PostUpListJson.parse(res.getBody());
        for(PostUpListJson postUpList : postUpListJson) {
            if(postUpList.title == title) {
                listId = postUpList.listId;
            }
        }
        return listId;
    }
    
    //To avoid updating the the campaign after insert
 /*   public static void updatePostUpListFuture(Integer listId, String title, String id, String status) { 
        System.debug('PostUpListController : updatePostUpListFuture');
        if(!System.isFuture()) {
            updatePostUpListFutureImpl(listId, title, id, status);
        }
    }
    
    @future(callout=true)
    public static void updatePostUpListFutureImpl(Integer listId, String title, String id, String status) {
        System.debug('PostUpListController : updatePostUpListFutureImpl');
        if(!System.isQueueable() || !System.isBatch()) {
        	updatePostUpListImplementation(listId, title, id, status);    
        }
    }  */
    
    //To update PostUp List from Future methods
    public static void updatePostUpList(Integer listId, String title, String id, String status) {
        System.debug('PostUpListController : updatePostUpList');
        updatePostUpListImplementation(listId, title, id, status);
    }
    
    //Implementation of Update PostUp List
    public static void updatePostUpListImplementation(Integer listId, String title, String id, String status) {
        System.debug('PostUpListController : updatePostUpListImplementation');
        Map<String, object> reqJson = new Map<String, object>();
        reqJson.put('title', title);
        reqJson.put('friendlyTitle', title);
        reqJson.put('description', title);
        reqJson.put('brandIds', getBrandIds());
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setBody(JSON.serialize(reqJson));
        req.setEndpoint('callout:PostUp/list/'+listId);
        HttpResponse res = http.send(req);
        PostUpListJson listResponse = PostUpListJson.parsePostUpListJson(res.getBody());
        System.debug('List is Updated Successfully');
        updateListId(listResponse.listId, id);
    }
    
    //Get PostUp BrandIds for List Creation/Updation
    public static List<Integer> getBrandIds() {
        System.debug('PostUpListController : getBrandIds');
        List<Integer> brandIds = new List<Integer>();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:PostUp/brand');
        HttpResponse res = http.send(req);
        GetBrandIdsJsonToApex[] brandIdsResponseList = GetBrandIdsJsonToApex.parse(res.getBody());
        for(GetBrandIdsJsonToApex brandIdsResponse : brandIdsResponseList) {
            brandIds.add(brandIdsResponse.brandId);
        }
        return brandIds;
    }
    
    //Checking the PostUp List Create Response to Update List for particular error response
    public static Boolean checkResponse(String response) {
        System.debug('PostUpListController : checkResponse');
        Boolean flag = true;
        try{
            if(parse(response).status == 'error'){
                System.debug('Error Response from Create List API');
            }
            if('A list with this title already exists. Please select a new title.' == parse(response).data.message) {
                System.debug('A list with this title already exists');
            }
            else if(parse(response).data.message != null) {
                System.debug('Error is '+parse(response).data.message);
            }
            flag = false;
        }
        catch(JSONException e) {
            System.debug('JSONException');
        } catch(Exception e) {
            System.debug('A list with this title already exists & Exception is ' + e);
        }
        return flag;
    }
    
    //Update ListId in the Campaign of Salesforce
    public static void updateListId(Integer listId, String campaignId) {
        System.debug('PostUpListController : updateListId');
        Campaign[] campaign = [select Id,ListId__c, Name from Campaign where Id=:campaignId];
        if(!campaign.isEmpty()) {
            campaign[0].ListId__c = listId;
            update campaign[0]; 
        }
    }
    
    //Parse the List Creation/Updation response
    public static PostUpListController parse(String json) {
        System.debug('PostUpListController : parse');
        return (PostUpListController) System.JSON.deserialize(json,PostUpListController.class);
    }
}