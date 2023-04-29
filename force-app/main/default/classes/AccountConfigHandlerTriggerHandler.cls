/*
*********************************************************
Apex Class Name    : AccountConfigHandlerTriggerHandler
Created Date       : 29-04-2023
@description       : This class is a controller for AccountConfigHandlerTrigger trigger.
@author            : Gaurav Gupta
Modification Log:
Ver   Date         Author                               Modification
1.0   29-04-2023   Gaurav Gupta                         Initial Version
*********************************************************
*/
public with sharing class AccountConfigHandlerTriggerHandler {
    public static final Integer NUMBER_OF_TEAM_MEMBERS = 2;
    public static final String MEMEBER_TYPE_HR = 'HR';
    public static final String MEMEBER_TYPE_ADMIN = 'Admin';
    public static final String ACTIVATION_ERR_MSG = 'Accounts can not be activated without team members of HR and Admin member type'; 

    public static void createTeamMembers(List<Account> newAccountList){
        List<SQX_Team_Members__c> teamMembersToInsert = new List<SQX_Team_Members__c>();
        for(Account acc : newAccountList){
            for(Integer i = 1; i <= NUMBER_OF_TEAM_MEMBERS; i++){
                SQX_Team_Members__c tmMem = new SQX_Team_Members__c();
                tmMem.Account__c = acc.Id;
                tmMem.Name = 'Team Member ' + i;    
                teamMembersToInsert.add(tmMem);
            }
        }
        try{
            if(!teamMembersToInsert.isEmpty()){
                insert teamMembersToInsert;
            }
        }
        catch(Exception ex){
            System.debug('Exception occured while creating team members: ' + ex.getMessage() + ' Stack Trace ' + ex.getStackTraceString());
        }
       

    }

    public static void validateAccountActivation(List<Account> newAccountList, Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        set<Id> eligibleAccounts = new Set<Id>();
        for(Account acc : newAccountList){
            if(acc.Active__c && (acc.Active__c != oldAccountMap.get(acc.Id).Active__c)){
                eligibleAccounts.add(acc.Id);
            }
        }

        for(Account act : [SELECT Id, (SELECT Id, Member_Type__c FROM Team_Members__r WHERE ( Member_Type__c = :MEMEBER_TYPE_ADMIN OR  Member_Type__c = :MEMEBER_TYPE_HR)) FROM Account WHERE Id IN :eligibleAccounts]){
            if(!act.Team_Members__r.isEmpty() ){
                if(!hasRequiredTeamMembers(act.Team_Members__r)){
                    newAccountMap.get(act.Id).addError(ACTIVATION_ERR_MSG);
                }
            }
            else{
                newAccountMap.get(act.Id).addError(ACTIVATION_ERR_MSG);
            }

        }

    }

    public static Boolean hasRequiredTeamMembers(List<SQX_Team_Members__c> teamMemberList){
        Boolean hasRequiredTeamMembers = false;
        Set<String> memberTypeSet = new Set<String>();
        
        for(SQX_Team_Members__c tMem : teamMemberList){
            memberTypeSet.add(tMem.Member_Type__c);
            if(memberTypeSet.contains(MEMEBER_TYPE_ADMIN) && memberTypeSet.contains(MEMEBER_TYPE_HR)){
                hasRequiredTeamMembers = true;
                break;
            }
        }
        return hasRequiredTeamMembers;
    }
}