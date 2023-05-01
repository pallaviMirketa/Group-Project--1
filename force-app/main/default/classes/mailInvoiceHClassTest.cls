@isTest
private class mailInvoiceHClassTest {
    @isTest
    static void setUpData(){
            Account testAccount = new Account(
            Name= 'Test Account',
            AccountNumber='123456'
        );
        insert testAccount;
        
         Contact testContact = new Contact(
            FirstName= 'Test',
            LastName= 'Contact',
            Email= 'pallavi.1923cs1189@kiet.edu',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        testAccount.Contact__c=testContact.Id;
		update testAccount; 
        Id standardbookPrice = Test.getStandardPricebookId();
        
        Opportunity testOpportunity = new Opportunity(
            Name= 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Pricebook2Id = standardbookPrice,
            Amount= 10000,
            AccountId = testAccount.Id
        );
        insert testOpportunity;
        
        Product2 testProduct= new Product2(
            Name= 'Test Product',
            IsActive= true
        );
        insert testProduct;
        
        
        
        PricebookEntry testPriceBookEntry = new PricebookEntry(
          IsActive = true,
          Product2Id = testProduct.Id,
          Pricebook2Id = standardbookPrice,
          UnitPrice = 5000
        );
        insert testPriceBookEntry;

        OpportunityLineItem testOpportunityLineItem =new OpportunityLineItem(
            Product2Id= testProduct.Id,
            OpportunityId= testOpportunity.Id,
            Quantity= 2,
            UnitPrice= 5000
        );
        insert testOpportunityLineItem;
        Sales_Invoice__c testCustomInvoice= new Sales_Invoice__c(
            Opportunity__c= testOpportunity.Id,
            Account__c= testAccount.Id,
            Invoice_Date__c= Datetime.now(),
            Due_Date__c = testOpportunity.CloseDate.addDays(30)
        );
        Test.startTest();
        insert testCustomInvoice;
        List<Sales_Invoice__c> newRecordList = new List<Sales_Invoice__c>{testCustomInvoice};
            Test.stopTest();
        System.assertEquals(1,Limits.getEmailInvocations());
        
    }
}