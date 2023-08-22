public with sharing class MissionAssignmentDAO {

    /**
     * description              get Mission Assignments by Hero and Mission Ids with In Progress status
     * @param  heroId           Hero Id
     * @param  missionId        Mission Id
     * @return                  List of Mission Assignments
     */
    public List<MissionAssignment__c> getByMissionAndHeroIds(List<Id> heroIds, List<Id> missionIds) {
        return [
            SELECT Id, Status__c, Hero__c, Mission__c
            FROM MissionAssignment__c
            WHERE Hero__c NOT IN :heroIds
            AND Mission__c IN :missionIds
            AND Status__c = :Constant.MISSION_ASSIGNMENT_STATUS_IN_PROGRESS
        ];
    }
}