({
	init : function(component, event, helper) {
		helper.fetchRoles(component);
	},
    handleSelect: function (component, event, helper) {
        component.set("v.selectedID", event.getParam('name'));
    }
})