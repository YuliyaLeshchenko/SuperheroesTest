({
    getMissions : function(component) {
        var action = component.get("c.getAllMissions");
        var self = this;
        action.setCallback(this, function(actionResult) {
            component.set('v.missions', actionResult.getReturnValue());
         });
          $A.enqueueAction(action);
    }
})