trigger mailInvoiceTrigger on Sales_Invoice__c (after insert) {
     try{
        mailInvoiceHandlerClass.sendInvoiceMail(trigger.new);
     }
     catch(Exception e){
        System.debug(e.getMessage());
     }
}