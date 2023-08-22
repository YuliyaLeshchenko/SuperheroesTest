public with sharing class AllMissionsController {

    /**
     * description      get all Superhero Missions which are Public or have the same Guild as curren Hero
     * @return          List of Superhero Missions
     */
    @AuraEnabled
    public static List<MissionWrapper> getAllMissions() {

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

        List<Hero__c> heroes = [
            SELECT Id, Contact__c
            FROM Hero__c
            WHERE Contact__c IN :contactIds
        ];

        List<Id> heroIds = new List<Id>();
        for (Hero__c hero : heroes) {
            heroIds.add(hero.Id);
        }

        List<SuperheroMission__c> missions = new List<SuperheroMission__c>([
            SELECT Id, ComplexityRank__c, Subject__c, Guild__r.Name,
                (
                    SELECT Status__c, Hero__c
                    FROM MissionAssignments__r
                    WHERE Hero__c IN :heroIds
                    LIMIT 1
                )
            FROM SuperheroMission__c
            ORDER BY CreatedDate DESC
        ]);
        
        List<MissionWrapper> missionsWrapper = new List<MissionWrapper>();
        for (SuperheroMission__c sm : missions) {
            MissionWrapper missionWrapper = new MissionWrapper();
            missionWrapper.id = sm.Id;
            missionWrapper.rank = sm.ComplexityRank__c;
            missionWrapper.subject = sm.Subject__c;
            missionWrapper.guildName = sm.Guild__r.Name;
            missionWrapper.status = !sm?.MissionAssignments__r.isEmpty() ? sm.MissionAssignments__r[0].Status__c : null;
            missionsWrapper.add(missionWrapper);
        }

        return missionsWrapper;
    }

    public class MissionWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String rank;
        @AuraEnabled public String subject;
        @AuraEnabled public String guildName;
        @AuraEnabled public String status;
    }
}