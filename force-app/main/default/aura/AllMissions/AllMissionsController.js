({
    doinit : function(component, event, helper) {
        helper.getMissions(component);
    },
    handleClick: function(component, event, helper) {
        var selectedId = event.currentTarget.dataset.id;
        var payload = {
            recordId: selectedId
        };

        component.find("MissionDetailsMessageChannel").publish(payload);
    },
})