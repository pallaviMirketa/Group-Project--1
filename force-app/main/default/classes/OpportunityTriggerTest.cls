@isTest
private class OpportunityTriggerTest {

    @isTest static void testOpenOpportunity() {
        
        // Creating a test account
        Test.startTest();
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Creating an open opportunity for the test account
        Opportunity openOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today() + 30,
            AccountId = testAccount.Id
        );
        insert openOpp;

        //Trying to create another open opportunity for the same account
        Opportunity anotherOpenOpp = new Opportunity(
            Name = 'Another Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today() + 30,
            AccountId = testAccount.Id
        );
        
        insert anotherOpenOpp;
        Test.stopTest();

        // Verifying that the error message is thrown
        System.assertEquals(1, Limits.getDmlRows());
        System.assertEquals('Another open opportunity already exists for this account.', anotherOpenOpp.getErrors()[0].getMessage());
        List<Opportunity> opList = [Select Name, AccountId,CloseDate,StageName from Opportunity];
        System.assertEquals(1, opList.size());
    }
}