@IsTest
private class MissionAssignmentDAOTest {

    @testSetup
    static void setup() {
        Contact contact = TestDataService.createContact('Test contact');
        insert contact;

        Hero__c hero = TestDataService.createHero('Test hero', contact.Id);
        Hero__c hero2 = TestDataService.createHero('Test hero2', contact.Id);
        insert new List<Hero__c>{ hero, hero2 };
        
        Guild__c guild = TestDataService.createGuild('Test guild');
        insert guild;

        SuperheroMission__c superheroMission = TestDataService.createSuperheroMission('Test subject', guild.Id);
        insert superheroMission;

        MissionAssignment__c missionAssignment = TestDataService.createMissionAssignment(hero.Id, superheroMission.Id);
        MissionAssignment__c missionAssignment2 = TestDataService.createMissionAssignment(hero2.Id, superheroMission.Id);
        insert new List<MissionAssignment__c>{ missionAssignment, missionAssignment2 };
    }

    @IsTest
    static void getByMissionAndHeroIdsTest() {
        Hero__c hero = [SELECT Id FROM Hero__c LIMIT 1];
        SuperheroMission__c sMission = [SELECT Id FROM SuperheroMission__c LIMIT 1];

        List<MissionAssignment__c> missionAssignmentResult = 
            new MissionAssignmentDAO().getByMissionAndHeroIds(new List<Id>{ hero.Id }, new List<Id>{ sMission.Id });
        System.assert(!missionAssignmentResult.isEmpty(), 'Mission Assignments should be found by Hero and Mission Ids');
    }
}