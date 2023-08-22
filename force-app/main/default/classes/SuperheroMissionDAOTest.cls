@IsTest
private class SuperheroMissionDAOTest {

    @testSetup
    static void setup() {
        Guild__c guild = TestDataService.createGuild('Test guild');
        insert guild;

        SuperheroMission__c superheroMission = TestDataService.createSuperheroMission('Test subject', guild.Id);
        insert superheroMission;
    }

    @IsTest
    static void getByIdsTest() {
        SuperheroMission__c mission = [SELECT Id FROM SuperheroMission__c LIMIT 1];
        List<SuperheroMission__c> missionsResult = new SuperheroMissionDAO().getByIds(new List<Id>{ mission.Id });
        System.assert(!missionsResult.isEmpty(), 'Superhero Missions should be found');
    }
}