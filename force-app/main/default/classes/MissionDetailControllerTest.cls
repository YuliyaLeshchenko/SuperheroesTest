@IsTest
private class MissionDetailControllerTest {

    @testSetup
    static void setup() {

        Account account = TestDataService.createAccount('Test Account');
        insert account;

        Contact contact = TestDataService.createContact('Test Contact', 'test@gmail.com', account.Id);
        insert contact;

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus User'].Id;
        User communityUser = TestDataService.createCommunityUser(contact.Id, profileId, 'Test', 'CommunityUser');
        insert communityUser;

        Hero__c hero = TestDataService.createHero('Test hero', contact.Id);
        insert hero;

        Guild__c guild = TestDataService.createGuild('Test guild');
        insert guild;

        SuperheroMission__c superheroMission = TestDataService.createSuperheroMission('Test subject', guild.Id);
        insert superheroMission;

        MissionAssignment__c missionAssignment = TestDataService.createMissionAssignment(hero.Id, superheroMission.Id);
        insert missionAssignment;
    }
 
    @IsTest
    static void getHeroDetailsTest() {
        User user = [SELECT Id, ContactId FROM User WHERE LastName = 'CommunityUser' LIMIT 1];
        System.debug('User test ' + user);
        System.runAs(user) {
            MissionDetailController.HeroDetailsWrapper heroResult = MissionDetailController.getHeroDetails();
            System.assert(heroResult != null, 'Hero record should be found');
        }
    }

    @IsTest
    static void getMissionDetailsTest() {
        User user = [SELECT Id, ContactId FROM User WHERE LastName = 'CommunityUser' LIMIT 1];
        SuperheroMission__c superheroMission = [SELECT Id FROM SuperheroMission__c LIMIT 1];

        System.runAs(user) {
            MissionDetailController.MissionDetailsWrapper superheroMissionResult = 
                MissionDetailController.getMissionDetails(superheroMission.Id);
            System.assert(superheroMissionResult != null, 'Superhero Mission should be found by Id');
        }
    }
    
    @IsTest
    static void checkHeroMissionAssignmentsTest() {
        User user = [SELECT Id, ContactId FROM User WHERE LastName = 'CommunityUser' LIMIT 1];
        System.runAs(user) {
            Boolean missionAssignmentsResult = MissionDetailController.checkHeroMissionAssignments();
            System.assertEquals(true, missionAssignmentsResult, 'Should be found less than 3 unfinished Mission Assignments');
        }
    }
            
    @IsTest
    static void createMissionAssignmentTest() {
        Hero__c hero = [SELECT Id FROM Hero__c LIMIT 1];
        SuperheroMission__c mission = [SELECT Id FROM SuperheroMission__c LIMIT 1];

        Id newSuperheroMissionId = MissionDetailController.createMissionAssignment(hero.Id, mission.Id);
        System.assert(newSuperheroMissionId != null, 'New Superhero Mission should be created');
    }
                
    @IsTest
    static void updateMissionAssignmentTest() {
        User user = [SELECT Id, ContactId FROM User WHERE LastName = 'CommunityUser' LIMIT 1];
        System.runAs(user) {
            MissionAssignment__c missionAssignment = [SELECT Id, Status__c, Mission__c FROM MissionAssignment__c LIMIT 1];

            Id updatedMissionAssignmentId = MissionDetailController.updateMissionAssignment(missionAssignment.Mission__c);
            MissionAssignment__c updatedMissionAssignment = [
                SELECT Id, Status__c 
                FROM MissionAssignment__c 
                WHERE Id = :updatedMissionAssignmentId
                LIMIT 1
            ];

            System.assertNotEquals(missionAssignment.Status__c, updatedMissionAssignment.Status__c, 
                'Status of the Mission Assignment should be updated');
        }
    }
}