@isTest
public class TestDataService {

    /**
     * description      creation of Account
     * @param  name     Last name of Contact
     * @return          Account
     */
    public static Account createAccount(String name) {
        Account portalAccount = new Account();
        portalAccount.Name = name;
        return portalAccount;
    }

    /**
     * description              creation of Contact
     * @param  lastName         Last name of Contact
     * @param  email            Email of Contact
     * @param  accountId        Id of Account
     * @return                  Contact
     */
    public static Contact createContact(String lastName, String email, Id accountId) {
        Contact portalContact = new contact();
        portalContact.LastName = lastName;
        portalContact.Email = email;
        portalContact.AccountId = accountId;
        return portalContact;
    }
    
    /**
     * description              creation of Contact
     * @param  lastName         Last name of Contact
     * @return                  Contact
     */
    public static Contact createContact(String lastName) {
        Contact contact = new contact();
        contact.LastName = lastName;
        return contact;
    }

    /**
     * description              creation of Hero
     * @param  name             Name of Hero
     * @param  contactId        Contact Id
     * @return                  Hero__c
     */
    public static Hero__c createHero(String name, Id contactId) {
        Hero__c hero = new Hero__c();
        hero.Name = name;
        hero.Contact__c = contactId;
        return hero;
    }

    /**
     * description      creation of Guild
     * @param  name     Name of Guild
     * @return          Guild__c
     */
    public static Guild__c createGuild(String name) {
        Guild__c guild = new Guild__c();
        guild.Name = name;
        return guild;
    }

    /**
     * description          creation of Superhero Mission
     * @param  subject      Subject of Superhero Mission
     * @param  guildId      Guild Id
     * @return              SuperheroMission__c
     */
    public static SuperheroMission__c createSuperheroMission(String subject, Id guildId) {
        SuperheroMission__c superheroMission = new SuperheroMission__c();
        superheroMission.Guild__c = guildId;
        superheroMission.Subject__c = subject;
        superheroMission.IsPublic__c = true;
        return superheroMission;
    }

    /**
     * description              creation of Mission Assignment
     * @param  heroId           Hero Id
     * @param  missionId        Mission Id
     * @return                  MissionAssignment__c
     */
    public static MissionAssignment__c createMissionAssignment(Id heroId, Id missionId) {
        MissionAssignment__c missionAssignment = new MissionAssignment__c();
        missionAssignment.Hero__c = heroId;
        missionAssignment.Mission__c = missionId;
        return missionAssignment;
    }

    /**
     * description      creation of Community User
     * @return          User
     */
    public static User createCommunityUser(String contactId, String profileId, String firstName, String lastName) {
        User user = new User();
        user.ProfileId = profileId;
        user.FirstName = firstName + String.valueOf(System.today());
        user.LastName = lastName;
        user.Email = 'test@test.com';
        user.Username = String.valueOf(System.today()) + '@gmail.com.test';
        user.Alias = 'alias';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.ContactId = contactId;
        return user;
    }
}