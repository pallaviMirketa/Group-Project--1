trigger OpportunityTrigger on Opportunity (before insert, before update) {
	OpportunityTriggerHandler.onBeforeInsertUpdate(Trigger.new);
}