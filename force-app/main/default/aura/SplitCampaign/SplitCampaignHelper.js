({
callServer : function(component,method,params) {
        var action = component.get(method);
        if (params) {        
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {            
            var state = response.getState();
            
            if (state === "SUCCESS") { 
                
                console.log('##'+JSON.stringify(response.getReturnValue()));
  
                component.set("v.columns", response.getReturnValue().lstDataTableColumns);
      
                var data = response.getReturnValue().lstDataTableData;
                data.forEach(function(record){
                    //alert(JSON.stringify(record));
                    if(record.Campaign!=null){
                        record.cpName ='/'+ record.CampaignId;
                        record.CName =  record.Campaign.Name;
                    }
                    record.cmpName = '/'+record.Id;
                    
                    //record.cpName = '/'+record.
                });
                
        		component.set("v.data", data);
               
            }else if (state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            } 
        });
        
        $A.enqueueAction(action);
    },
})