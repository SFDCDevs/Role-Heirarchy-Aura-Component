({
	fetchRoles : function(component) {
		var action = component.get('c.getTreeJSON'); 
        action.setCallback(this, function(ret){
            var state = ret.getState(); // get the response state
            if(state == 'SUCCESS') {
                let items = JSON.parse(ret.getReturnValue());
                component.set("v.items", items);
            }
            else{
                alert('Error occured while querying roles');
            }
        });
        $A.enqueueAction(action);
	}
})