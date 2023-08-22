public without sharing class SuperheroMissionTriggerHandler {
    private Map<Id, SuperheroMission__c> oldMap;
    private Map<Id, SuperheroMission__c> newMap;
    private List<SuperheroMission__c> newRecords;

    public SuperheroMissionTriggerHandler(Map<Id, SuperheroMission__c> oldMap, Map<Id, SuperheroMission__c> newMap, List<SuperheroMission__c> newRecords) {
        this.oldMap = oldMap;
        this.newMap = newMap;
        this.newRecords = newRecords;
    }

    public void afterInsert() {
        sendEmailAlertNewMission();
    }

    /**
     * description      send Email to Heroes once a new Mission is created
     */
    private void sendEmailAlertNewMission() {
        List<SuperheroMission__c> publicMissions = new List<SuperheroMission__c>();
        List<SuperheroMission__c> notPublicMissions = new List<SuperheroMission__c>();
        List<Id> guilds = new List<Id>();
        List<String> allEmails = new List<String>();

        for (SuperheroMission__c mission : this.newRecords) {
            if (mission.IsPublic__c == true) {
                publicMissions.add(mission);
            } else {
                notPublicMissions.add(mission);
                guilds.add(mission.Guild__c);
            }
        }

        if (!publicMissions.isEmpty()) {
            List<Hero__c> heroesForNotice = new HeroDAO().getWithContactEmails();

            List<String> emails = new List<String>();
            for (Hero__c hero : heroesForNotice) {
                if (hero.Contact__r.Email != null) {
                    emails.add(hero.Contact__r.Email);
                }
            }

            if (!emails.isEmpty()) {
                allEmails.addAll(emails);
            }
        }

        if (!notPublicMissions.isEmpty()) {
            List<Hero__c> heroesForNotice = new HeroDAO().getWithContactEmailsByGuilds(guilds);

            List<String> emails = new List<String>();
            for (Hero__c hero : heroesForNotice) {
                if (hero.Contact__r.Email != null) {
                    emails.add(hero.Contact__r.Email);
                }
            }

            if (!emails.isEmpty()) {
                allEmails.addAll(emails);
            }
        }
        
        if(!allEmails.isEmpty()) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = allEmails;
            message.subject = 'New Mission!';
            message.plainTextBody = 'We have a new mission for you! Come to us and try to do!';
    
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage> { message };
            List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(messages);
    
            if (!sendEmailResults[0].success) {
                throw new EmailServiceException(sendEmailResults[0].errors[0].message);
            }
        }
    }

    public class EmailServiceException extends Exception {
    }
}