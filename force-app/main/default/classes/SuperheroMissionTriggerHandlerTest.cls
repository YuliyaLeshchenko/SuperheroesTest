@IsTest
private class SuperheroMissionTriggerHandlerTest {

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
    }

    @IsTest
    static void sendEmailAlertNewMissionTest() {
        Guild__c guild = [SELECT Id FROM Guild__c LIMIT 1];

        SuperheroMission__c superheroMission = TestDataService.createSuperheroMission('Test subject', guild.Id);
        superheroMission.IsPublic__c = true;

        Boolean isException = false;

		Test.startTest();
		try {
            insert superheroMission;
		} catch (Exception e) {
			isException = true;
		}
		Test.stopTest();

		System.assert(!isException, 'Email message should be sent without exeptions');
    }
}