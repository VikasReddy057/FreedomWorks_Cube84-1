({
        showSuccess : function(tt,msg,type,mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : tt,//'Success',
            message: msg,
            duration:'5000',
            type: type ,
            mode: mode
        });
        toastEvent.fire();
    },
})