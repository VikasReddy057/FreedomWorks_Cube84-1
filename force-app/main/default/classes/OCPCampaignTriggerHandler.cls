public class OCPCampaignTriggerHandler {
    @future(callout=true)
    public static void isAfterInsert(String campString){
        List<Campaign> campList = (List<Campaign>)JSON.deserialize(campString, List<Campaign>.class);
        
        for(Campaign cam :campList){
            HttpRequest req = new HttpRequest();
            String endpoint = 'https://oneclickpolitics.com/api/v1/message/create/';
            endpoint+=cam.OCP_Campaign_Id__c;
            endpoint+='.json';
            endpoint+='?name='+cam.Name;
            endpoint+='&prefix=Mr';
            endpoint+='&email=sveta@oneclickpolitics.com';
            endpoint+='&address=95 Rodeo Drive';
            endpoint+='&zip=90210';
            endpoint+='&city=Beverly Hills';
            endpoint+='&phone=6175555555';
            endpoint+='&opt_in=true';
            endpoint+='&custom_field_557=F';
            endpoint+='&custom_field_558=East Side';
            System.debug('@@Endpoint::::'+endpoint);
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Authorization', 'b56a7d5e0702f72b3d475f72e4905c2e');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            System.debug('@@res Status::::'+res.getStatus());
            System.debug('@@res Status Code::::'+res.getStatusCode());
            System.debug('@@res Body::::'+res.getBody());
        }
    }
}