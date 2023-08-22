public without sharing class MissionDetailController {

    /**
     * description      get current Hero
     * @return          Hero record
     */
    @AuraEnabled
    public static HeroDetailsWrapper getHeroDetails() {
        List<User> users = [
            SELECT Id, ContactId
            FROM User
            WHERE ContactId != null
            AND Id = :UserInfo.getUserId()
        ];

        List<Id> contactIds = new List<Id>();
        for (User user : users) {
            contactIds.add(user.ContactId);
        }

        Hero__c hero = [
            SELECT Id, Guild__c, Contact__c, Rank__c
            FROM Hero__c
            WHERE Contact__c IN :contactIds
            LIMIT 1
        ];

        HeroDetailsWrapper heroDetailsWrapper = new HeroDetailsWrapper();
        heroDetailsWrapper.id = hero.Id;
        heroDetailsWrapper.guild = hero.Guild__c;
        heroDetailsWrapper.contact = hero.Contact__c;
        heroDetailsWrapper.rank = hero.Rank__c;

        return heroDetailsWrapper;
    }

    /**
     * description          get Superhero Mission w/o Mission Assignments by Id
     * @param  recordId     Superhero Mission Id
     * @return              Superhero Mission record
     */
    @AuraEnabled
    public static MissionDetailsWrapper getMissionDetails(String recordId) {
        heroDetailsWrapper hero = getHeroDetails();
        
        SuperheroMission__c mission = [
            SELECT Id, Subject__c, Details__c, ComplexityRank__c, Reward__c, Deadline__c, Guild__r.Name,
                (
                    SELECT Status__c
                    FROM MissionAssignments__r 
                    WHERE Hero__c = :hero.id
                    LIMIT 1
                )
            FROM SuperheroMission__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        MissionDetailsWrapper missionDetailsWrapper = new MissionDetailsWrapper();
        missionDetailsWrapper.id = mission.Id;
        missionDetailsWrapper.subject = mission.Subject__c;
        missionDetailsWrapper.details = mission.Details__c;
        missionDetailsWrapper.rank = mission.ComplexityRank__c;
        missionDetailsWrapper.reward = mission.Reward__c;
        missionDetailsWrapper.deadline = mission.Deadline__c;
        missionDetailsWrapper.guild = mission.Guild__r.Name;
        missionDetailsWrapper.status = !mission?.MissionAssignments__r.isEmpty() ? mission.MissionAssignments__r[0].Status__c : null;

        return missionDetailsWrapper;
    }

    /**
     * description      check if current Hero has less than 3 unfinished Mission Assignments
     * @return          Boolean value
     */
    @AuraEnabled
    public static Boolean checkHeroMissionAssignments() {
        heroDetailsWrapper hero = getHeroDetails();
        List<MissionAssignment__c> missionAssignments = [
            SELECT Id
            FROM MissionAssignment__c
            WHERE Hero__c = :hero.id
            AND Status__c = :Constant.MISSION_ASSIGNMENT_STATUS_IN_PROGRESS
        ];

        return missionAssignments.size() < 3;
    }

    /**
     * description              create a new Mission Assignment
     * @param  heroId           Hero Id
     * @param  missionId        Mission Id
     * @return                  Id of the newly created Mission Assignment record
     */
    @AuraEnabled
    public static Id createMissionAssignment(String heroId, String missionId) {
        MissionAssignment__c newMissionAssignment = new MissionAssignment__c();
        newMissionAssignment.Hero__c = heroId;
        newMissionAssignment.Mission__c = missionId;
        insert newMissionAssignment;

        return newMissionAssignment.Id;
    }

    /**
     * description              update of existing Mission Assignment
     * @param  missionId        Mission Id
     * @return                  Id of the updated Mission Assignment record
     */
    @AuraEnabled
    public static Id updateMissionAssignment(String missionId) {
        heroDetailsWrapper hero = getHeroDetails();
        MissionAssignment__c missionAssignment = [
            SELECT Id, Status__c
            FROM MissionAssignment__c
            WHERE Mission__c = :missionId
            AND Hero__c = :hero.id
            AND Status__c = :Constant.MISSION_ASSIGNMENT_STATUS_IN_PROGRESS
            LIMIT 1
        ];

        missionAssignment.Status__c = Constant.MISSION_ASSIGNMENT_STATUS_COMPLETED;
        update missionAssignment;

        return missionAssignment.Id;
    }

    /**
     * description      get All Possible values from Rank field on Superhero Mission object
     * @return          List of field values
     */
    @AuraEnabled
    public static List<String> getAllPossibleRanks() {
        List<String> rankFieldValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = SuperheroMission__c.ComplexityRank__c.getDescribe();
        for (Schema.PicklistEntry valueResult : fieldResult.getPicklistValues()) {
            rankFieldValues.add(valueResult.getValue());
        }
        return rankFieldValues;
    }
    
    public class MissionDetailsWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String subject;
        @AuraEnabled public String details;
        @AuraEnabled public String rank;
        @AuraEnabled public Decimal reward;
        @AuraEnabled public Date deadline;
        @AuraEnabled public String guild;
        @AuraEnabled public String status;
    }

    public class HeroDetailsWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String guild;
        @AuraEnabled public String contact;
        @AuraEnabled public String rank;
    }
}