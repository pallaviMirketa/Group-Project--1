public class mailInvoiceHandlerClass {
   public static void sendInvoiceMail(List<Sales_Invoice__c> newRecordList){
       set<Id>invoiceIdset= new set<Id>();
  	   set<Id>opportunityIdset = new set<Id>();
       set<Id>accountIdset = new set<Id>();
       for(Sales_Invoice__c cinvoiceob:newRecordList){
           invoiceIdset.add(cinvoiceob.Id);
           opportunityIdset.add(cinvoiceob.Opportunity__c);
           accountIdset.add(cinvoiceob.Account__c);
       }
       Opportunity oppdetail=[SELECT Id,Amount,CloseDate FROM Opportunity WHERE Id in :opportunityIdset limit 1];
       System.debug('Opportunity = '+ oppdetail);
       Sales_Invoice__c invoicelist=[SELECT Id,Invoice_Date__c,Due_Date__c,Outstanding_Amount__c,Total_Payment__c FROM Sales_Invoice__c WHERE ID in :invoiceIdset];
       List<OpportunityLineItem> productList=[SELECT Product2.Name, Quantity, UnitPrice,TotalPrice FROM OpportunityLineItem WHERE opportunityId in:opportunityIdset];
       Map<Id,Account> accemailMap=new Map<Id,Account>([Select Id, Contact__r.Email,Contact__r.Name FROM Account WHERE Id in :accountIdset]);
       List<Messaging.SingleEmailMessage> mails=new List<Messaging.SingleEmailMessage>();
       for(Sales_Invoice__c cinvoiceob:newRecordList){
           
           Account acc= accemailMap.get(cinvoiceob.Account__c);
           Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        if(acc.Contact__r.Email != null) {
           mail.setToAddresses(new String[]{acc.Contact__r.Email});
           System.debug('Email of Recipient='+ acc.Contact__r.Email);
  		   String subject = 'Invoice for Products purchased.';
           mail.setSubject(subject);
           String body='Dear '+acc.Contact__r.Name+',';
           body+='<br><br>Thank you for your recent purchase.We are pleased to provide you with the following invoice for your records:';
           body+= '<br><br>Invoice Date: '+ cinvoiceob.Invoice_Date__c;
           body+= '<br>Due Date: '+ oppdetail.CloseDate.addDays(30);
           body+= '<br>Total Amount: '+ oppdetail.Amount;
           body += '<br><br><table style="border-collapse: collapse; width: 80%;"><thead><tr><th style="padding: 10px; border: 1px solid #000;">Product Name</th><th style="padding: 10px; border: 1px solid #000;">Quantity</th><th style="padding: 10px; border: 1px solid #000;">Unit Price</th><th style="padding: 10px; border: 1px solid #000;">Total Price</th></tr></thead><tbody>';
           for(OpportunityLineItem opp:productList){
               body += '<tr><td  style="padding: 10px; border: 1px solid #000;">'+opp.Product2.Name+'</td><td  style="padding: 10px; border: 1px solid #000;">'+opp.Quantity +'</td><td  style="padding: 10px; border: 1px solid #000;">'+opp.UnitPrice+'</td><td  style="padding: 10px; border: 1px solid #000;">'+opp.TotalPrice+ '</td></tr>';
           } 
           body += '</tbody><tfoot><tr><td colspan="3"  style="padding: 10px; border: 1px solid #000; text-align:right;">Total Amount:</td>';
           body +='<td  style="padding: 10px; border: 1px solid #000;">'+ oppdetail.Amount+'</td></tr><tfoot></table>';
           body += '<br><br>Please make payment by the due date to avoid any late fees or service disruptions. If you have any questions or concerns about this invoice, please do not hesitate to contact us.<br>Thank you!';           
           mail.setHtmlBody(body);
           mails.add(mail);
             if(mails.size() > 0) {
        List<Messaging.sendEmailResult> results= Messaging.sendEmail(mails,false);
           for(Messaging.sendEmailResult email:results){
               System.debug(email.isSuccess());
           }
       	 }
        }
        else{
            cinvoiceob.addError('Primary Contact Email is required to send an email. Please provide the details.');   
           }
      
       }
   }
}