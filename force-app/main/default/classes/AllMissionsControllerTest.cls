@IsTest
private class AllMissionsControllerTest {

    @testSetup
    static void setup() {
        Guild__c guild = TestDataService.createGuild('Test guild');
        insert guild;

        SuperheroMission__c superheroMission = TestDataService.createSuperheroMission('Test subject', guild.Id);
        SuperheroMission__c publicSuperheroMission = TestDataService.createSuperheroMission('Test subject2', guild.Id);
        insert new List<SuperheroMission__c>{ superheroMission, publicSuperheroMission };
    }

    @IsTest
    static void getAllMissionsTest() {
        List<AllMissionsController.MissionWrapper> superheroMissions = AllMissionsController.getAllMissions();
            System.assert(superheroMissions.size() == 2, 'Should be found two missions');
    }
}