({
	doInitHandler : function(component, event, helper) {
		var one = component.get('v.section1');
        var two = component.get('v.section2');

        if(one!=null && one!='' && two!='' && two !=null){
        component.set('v.section1', one+'99'+two);
        component.set('v.isLabelSet', true);
            
        }
	}
})