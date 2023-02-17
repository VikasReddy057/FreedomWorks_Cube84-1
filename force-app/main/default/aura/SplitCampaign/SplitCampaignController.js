({
	myAction : function(component, event, helper) {

        
        var params = {'RecordTypes': component.get('v.recordTypeNames') , 'contactId': component.get('v.recordId'),'strFieldSet':component.get('v.fieldSet'),'cmpType':component.get('v.type')};
        helper.callServer(component,"c.getData",params);
        
	},
})