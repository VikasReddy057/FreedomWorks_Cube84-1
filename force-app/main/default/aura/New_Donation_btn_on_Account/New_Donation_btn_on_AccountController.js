({
	onSave : function(component, event, helper) {
        var action = component.get("c.createDonation");
        var name = component.find("one").get('v.value');
        var dt = component.find("four").get('v.value');
        var  chk = component.find("three").get('v.value');
        var  org = component.find("ten").get('v.value');
        var  amt = component.find("eleven").get('v.value').toString();
        var dsource = component.find("five").get('v.value');
        var checkNo = component.find("six").get('v.value');
        var bNo = component.find("seven").get('v.value');
        var oFEC = component.find("eight").get('v.value');
        var EFEC = component.find("nine").get('v.value');

       
        action.setParams({name:name,clsdt:dt,checkname:chk,org:org,amt:amt,dsource:dsource,checkNo:checkNo, bNo:bNo, oFEC:oFEC,EFEC:EFEC, accId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                helper.showSuccess('Success','Record has been created.','success','pester');
                $A.get("e.force:closeQuickAction").fire();  
            }
            else if (state === "INCOMPLETE") {
                console.log("Unknown error");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        helper.showSuccess('Error',errors[0].message,'error','pester');
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);        		

        
	},
    
    handleCreateLoad : function(component, event, helper) {
        var action = component.get("c.getAccount");
        action.setParams({ accountId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var obj = response.getReturnValue();
                //alert(obj.Name);
                //hasRecord
                var today = new Date();
                var dd = String(today.getDate()).padStart(2, '0');
                var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                var yyyy = today.getFullYear();
                
                today = yyyy + '-' + mm + '-' + dd   ;
                var name = component.find("one");
                var closeDate = component.find("four");
                component.set("v.hasRecord", true);
                name.set("v.value", obj.Name); 
                closeDate.set("v.value",today ); 
                
            }
            else if (state === "INCOMPLETE") {
                console.log("Unknown error");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);             
    },
    onclose: function(component, event, helper) {
    	$A.get("e.force:closeQuickAction").fire();  
    },

})