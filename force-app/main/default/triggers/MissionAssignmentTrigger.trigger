trigger MissionAssignmentTrigger on MissionAssignment__c (after update) {
    MissionAssignmentTriggerHandler handler = new MissionAssignmentTriggerHandler(Trigger.oldMap, Trigger.newMap, Trigger.new);
  
    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate();
    }
}