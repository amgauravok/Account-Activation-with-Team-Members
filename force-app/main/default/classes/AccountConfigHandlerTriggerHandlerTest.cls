/*
*********************************************************
Apex Class Name    : AccountConfigHandlerTriggerHandlerTest
Created Date       : 29-04-2023
@description       : This class is a test class for AccountConfigHandlerTriggerHandler .
@author            : Gaurav Gupta
Modification Log:
Ver   Date         Author                               Modification
1.0   29-04-2023   Gaurav Gupta                         Initial Version
*********************************************************
*/
@isTest
public class AccountConfigHandlerTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        User u = new User(
                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                    LastName = 'last',
                    Email = 'ggOrg@testsf.com',
                    Username = 'ggOrg@testsf.com' + System.currentTimeMillis(),
                    CompanyName = 'TEST',
                    Title = 'title',
                    Alias = 'alias',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US'
                );
        insert u;
        Id pSetId = [SELECT ID FROM PermissionSet WHERE Name ='Account_Admin'][0].Id;
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = pSetId, AssigneeId = u.Id);
        insert psa; 

        System.runAs(u){
            Account acc = new Account();
            acc.Name = 'Team Member Account';
            insert acc;
        }    
        
    }

    @isTest
    static void createTeamMembersTest(){
        System.runAs([SELECT Id FROM User WHERE Email = 'ggOrg@testsf.com'][0]){
            System.Test.startTest();
            Integer numberOfTeamMebers = 0;
            List<Account> accList = [SELECT Id, (SELECT Id FROM Team_Members__r) FROM ACCOUNT LIMIT 1];
            if(!accList.isEmpty()){
                numberOfTeamMebers = !accList[0].Team_Members__r.isEmpty() ? accList[0].Team_Members__r.size() : 0;
            }

            System.assert(numberOfTeamMebers == AccountConfigHandlerTriggerHandler.NUMBER_OF_TEAM_MEMBERS, numberOfTeamMebers + 'Team Member Created');
            System.Test.stopTest();
        }
    }

    @isTest
    static void validateAccountActivationPositiveTest(){
        System.runAs([SELECT Id FROM User WHERE Email = 'ggOrg@testsf.com'][0]){
            System.Test.startTest();
            List<SQX_Team_Members__c> tmMemberToUpdate = new List<SQX_Team_Members__c>();
            Account acc = [SELECT Id, Active__c FROM Account LIMIT 1];

            List<String> MemberTypes = new List<String> {AccountConfigHandlerTriggerHandler.MEMEBER_TYPE_ADMIN, AccountConfigHandlerTriggerHandler.MEMEBER_TYPE_HR};
            Integer count = 0;
            for(SQX_Team_Members__c tmc : [SELECT Id, Member_Type__c FROM SQX_Team_Members__c WHERE Account__c =:acc.Id]){
                SQX_Team_Members__c tm = new SQX_Team_Members__c();
                tm.Id = tmc.Id;
                tm.Member_Type__c = MemberTypes[count];
                tmMemberToUpdate.add(tm);
                count++;
            }
            update tmMemberToUpdate;

            acc.Active__c = true;
            update acc;
            
            System.Test.stopTest();
         }
    }

    @isTest
    static void validateAccountActivationNegativeTest(){
        System.runAs([SELECT Id FROM User WHERE Email = 'ggOrg@testsf.com'][0]){
            System.Test.startTest();
            List<SQX_Team_Members__c> tmMemberToUpdate = new List<SQX_Team_Members__c>();
            Account acc = [SELECT Id, Active__c FROM Account LIMIT 1];
            try{
                acc.Active__c = true;
                update acc;
            }
            catch(Exception e){
                Boolean flag = (e.getMessage().contains(AccountConfigHandlerTriggerHandler.ACTIVATION_ERR_MSG)) ? true : false;
                System.AssertEquals(flag, true);
            }
        
            
            System.Test.stopTest();
        }
    }
}