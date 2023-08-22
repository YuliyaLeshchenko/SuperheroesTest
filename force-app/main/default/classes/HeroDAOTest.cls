@IsTest
private class HeroDAOTest {

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
    }

    @IsTest
    static void getWithContactEmailsTest() {
        List<Hero__c> heroes = new HeroDAO().getWithContactEmails();
        System.assert(!heroes.isEmpty(), 'Heroes should be found');
    }

    @IsTest
    static void getWithContactEmailsByGuildsTest() {
        Guild__c guild = TestDataService.createGuild('Test guild');
        insert guild;

        Hero__c hero = [SELECT Id FROM Hero__c LIMIT 1];
        hero.Guild__c = guild.Id;
        update hero;

        List<Hero__c> heroes = new HeroDAO().getWithContactEmailsByGuilds(new List<Id>{ guild.Id });
        System.assert(!heroes.isEmpty(), 'Heroes should be found');
    }
}