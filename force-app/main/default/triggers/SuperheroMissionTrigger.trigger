trigger SuperheroMissionTrigger on SuperheroMission__c (after insert) {
    SuperheroMissionTriggerHandler handler = new SuperheroMissionTriggerHandler(Trigger.oldMap, Trigger.newMap, Trigger.new);
    
    if (Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert();
    }
}