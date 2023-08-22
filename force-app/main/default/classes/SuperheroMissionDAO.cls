public with sharing class SuperheroMissionDAO {

    /**
     * description                  get Superhero Missions by Ids
     * @param  superheroMissionIds  List of Superhero Mission Ids
     * @return                      List of uperhero Missions
     */
    public List<SuperheroMission__c> getByIds(List<Id> superheroMissionIds) {
        return [
            SELECT Id, Owner.Email
            FROM SuperheroMission__c
            WHERE Id IN :superheroMissionIds
        ];
    }
}