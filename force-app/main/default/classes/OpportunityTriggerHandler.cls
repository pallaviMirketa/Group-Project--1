public class OpportunityTriggerHandler {

    public static void onBeforeInsertUpdate(List<Opportunity> newList) {
        
        // Create a set to store account IDs of the opportunities being created/updated
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : newList) {
            accountIds.add(opp.AccountId); // Adding the account ID to the set
        }
        
        // Create a map to store the opportunities associated with each account
        Map<Id, List<Opportunity>> accountToOppMap = new Map<Id, List<Opportunity>>();
        // Query all open opportunities associated with the accounts in the set
        for (Opportunity opp : [SELECT Id, AccountId,IsClosed, StageName FROM Opportunity WHERE AccountId IN :accountIds]) {
            // If the account is not in the map, create a new list for its associated opportunities
            if (!accountToOppMap.containsKey(opp.AccountId)) {
                accountToOppMap.put(opp.AccountId, new List<Opportunity>());
            }
            // Add the opportunity to the list of associated opportunities for the account
            accountToOppMap.get(opp.AccountId).add(opp);
        }
        
        
        // Check if any other open opportunities exist for the same account, and if they do, throw an error
        for (Opportunity opp : newList) {
            if (opp.IsClosed == false && accountToOppMap.containsKey(opp.AccountId)) {
                // Iterate over the list of associated opportunities for the account
                for (Opportunity otherOpp : accountToOppMap.get(opp.AccountId)) {
                    // If there is another open opportunity for the same account, throw an error and break out of the loop
                    if (otherOpp.IsClosed == false && otherOpp.Id != opp.Id) {
                        opp.addError('Another open opportunity already exists for this account.');
                        break;
                    }
                }
            }
        }
    }
}