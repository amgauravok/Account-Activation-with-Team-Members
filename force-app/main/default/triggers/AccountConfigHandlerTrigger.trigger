trigger AccountConfigHandlerTrigger on Account (before insert, after insert, before update, after update) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            AccountConfigHandlerTriggerHandler.createTeamMembers((List<Account>) Trigger.new);
        }
    
        when BEFORE_UPDATE {
            AccountConfigHandlerTriggerHandler.validateAccountActivation((List<Account>) Trigger.new, (Map<Id,Account>) Trigger.newMap, (Map<Id,Account>) Trigger.oldMap);
        }
    
    }
}