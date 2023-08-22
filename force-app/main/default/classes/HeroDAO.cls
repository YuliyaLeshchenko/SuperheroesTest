public with sharing class HeroDAO {

    /**
     * description      get Heroes with Contact Emails
     * @return          List Heroes
     */
    public List<Hero__c> getWithContactEmails() {
        return [
            SELECT Id, Contact__r.Email
            FROM Hero__c
            WHERE Contact__r.Email != null
        ];
    }

    /**
     * description          get Heroes with Contact Emails
     * @param  guilds       List of Guild Ids
     * @return              List Heroes
     */
    public List<Hero__c> getWithContactEmailsByGuilds(List<Id> guilds) {
        return [
            SELECT Id, Contact__r.Email
            FROM Hero__c
            WHERE Contact__r.Email != null
            AND Guild__c IN :guilds
        ];
    }
}