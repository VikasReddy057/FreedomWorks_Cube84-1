({
	handleClick : function(component, event, helper) {
      component.set('v.edit', true);
	},
	handleReset : function(component, event, helper) {
      component.set('v.edit', false);
	},  
    handleSubmit: function(component, event, helper) {
        component.set('v.showSpinner', true);
        
        event.preventDefault();   
        var fields = event.getParam('fields');
        component.find('recordEditForm').submit(fields);
    },
    handleSuccess : function(component,event,helper) {
        component.set('v.edit', false);
        component.set('v.showSpinner', false);
         //$A.get('e.force:refreshView').fire();
    },
    handleError : function(){
    component.set('v.showSpinner', false);    
    var error = event.getParam('detail');
    console.log(error);
    component.find("notifLib").showToast({ "variant":"error", "title": "Error", "message": error });
    },
    doInit : function(component, event, helper) {
        component.set('v.isReadonly', true);
        var action = component.get("c.getCaseLoadusers");
        action.setParams({ recId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isReadonly', response.getReturnValue());
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
    }
})