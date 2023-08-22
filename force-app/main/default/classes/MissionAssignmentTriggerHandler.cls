public without sharing class MissionAssignmentTriggerHandler {
    private Map<Id, MissionAssignment__c> oldMap;
    private Map<Id, MissionAssignment__c> newMap;
    private List<MissionAssignment__c> newRecords;

    public MissionAssignmentTriggerHandler(Map<Id, MissionAssignment__c> oldMap, Map<Id, MissionAssignment__c> newMap, List<MissionAssignment__c> newRecords) {
        this.oldMap = oldMap;
        this.newMap = newMap;
        this.newRecords = newRecords;
    }

    public void afterUpdate() {
        setFailedStatus();
        sendEmailToMissionCreator();
    }

    /**
     * description      set Failed status to Missions of other Heroes when the Hero finished his Mission
     */
    private void setFailedStatus() {
        List<Id> heroIds = new List<Id>();
        List<Id> missionIds = new List<Id>();

        for (MissionAssignment__c mAssignment : this.newRecords) {
            if (this.oldMap.get(mAssignment.Id).Status__c != mAssignment.Status__c && 
                mAssignment.Status__c == Constant.MISSION_ASSIGNMENT_STATUS_COMPLETED) 
            {
                heroIds.add(mAssignment.Hero__c);
                missionIds.add(mAssignment.Mission__c);
            }
        }
        
        List<MissionAssignment__c> mAssignmentsToUpdate = new MissionAssignmentDAO().getByMissionAndHeroIds(heroIds, missionIds);
        if (!mAssignmentsToUpdate.isEmpty()) {
            for(MissionAssignment__c mAssignment : mAssignmentsToUpdate) {
                mAssignment.Status__c = Constant.MISSION_ASSIGNMENT_STATUS_FAILED;
            }

            update mAssignmentsToUpdate;
        }
    }

    /**
     * description      send Email to Mission creator once the Mission is Completed
     */
    private void sendEmailToMissionCreator() {
        List<Id> missionIds = new List<Id>();

        for (MissionAssignment__c mAssignment : this.newRecords) {
            if (this.oldMap.get(mAssignment.Id).Status__c != mAssignment.Status__c && 
                mAssignment.Status__c == Constant.MISSION_ASSIGNMENT_STATUS_COMPLETED) 
            {
                missionIds.add(mAssignment.Mission__c);
            }
        }

        if (!missionIds.isEmpty()) {
            List<String> emails = new List<String>();
            List<SuperheroMission__c> missions = new SuperheroMissionDAO().getByIds(missionIds);
            for (SuperheroMission__c mission : missions) {
                if (mission.Owner.Email != null) {
                    emails.add(mission.Owner.Email);
                }
            }
    
            if (!emails.isEmpty()) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = emails;
                message.subject = 'Mission is Completed';
                message.plainTextBody = 'The one of the Missions you have created is Completed!';

                List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage> { message };
                List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(messages);

                if (!sendEmailResults[0].success) {
                    throw new EmailServiceException(sendEmailResults[0].errors[0].message);
                }
            }
        }
    }

    public class EmailServiceException extends Exception {
    }
}