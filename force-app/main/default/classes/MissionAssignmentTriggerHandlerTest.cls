@IsTest
private class MissionAssignmentTriggerHandlerTest {

    @testSetup
    static void setup() {
        User user = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];
        user.Email = 'test.test@gmail.test';
        update user;

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
    static void setFailedStatusTest() {
        SuperheroMission__c superheroMission = [SELECT Id FROM SuperheroMission__c LIMIT 1];
        MissionAssignment__c missionAssignmentToUpdate = [SELECT Id, Status__c FROM MissionAssignment__c LIMIT 1];
        missionAssignmentToUpdate.Status__c = Constant.MISSION_ASSIGNMENT_STATUS_COMPLETED;
        update missionAssignmentToUpdate;

        MissionAssignment__c missionAssignment = [
            SELECT Id, Status__c
            FROM MissionAssignment__c 
            WHERE Mission__c = :superheroMission.Id
            AND Id != :missionAssignmentToUpdate.Id
        ];
        
        System.assert(missionAssignment.Status__c == Constant.MISSION_ASSIGNMENT_STATUS_FAILED, 
            'Mission Assignment Status should be updated to Failed');
    }

    @IsTest
    static void sendEmailToMissionCreatorTest() {
        SuperheroMission__c superheroMission = [SELECT Id FROM SuperheroMission__c LIMIT 1];
        MissionAssignment__c missionAssignmentToUpdate = [SELECT Id, Status__c FROM MissionAssignment__c LIMIT 1];
        missionAssignmentToUpdate.Status__c = Constant.MISSION_ASSIGNMENT_STATUS_COMPLETED;

        Boolean isException = false;

		Test.startTest();
		try {
            update missionAssignmentToUpdate;
		} catch (Exception e) {
			isException = true;
		}
		Test.stopTest();

		System.assert(!isException, 'Email message should be sent without exeptions');
    }
}