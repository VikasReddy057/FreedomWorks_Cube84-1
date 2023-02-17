global class SetP2AContactEmail implements Database.Batchable<sObject>, Database.Stateful {
    @InvocableMethod(label='Execute the batch SetP2AContactEmail' description='This method will be execute SetP2AContactEmail')
  public static void executeBatchMethod(List<String> lst) {
    Database.executeBatch(new SetP2AContactEmail(), 200);
  }
	global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String IntegrationUser = '0050b0000060Uys';
        String query = 'SELECT Id, OwnerId, Integration_Email__c, Integration_Email_Status__c, ' + 
            'npe01__HomeEmail__c, Personal_Email_Status__c, npe01__WorkEmail__c, Work_Email_Status__c, ' +
            'npe01__AlternateEmail__c, Alternate_Email_Status__c, HomePhone, ' +
            'MobilePhone, Mobile_Phone_Status__c, npe01__WorkPhone__c, npe01__PreferredPhone__c, ' +
            'P2A__Advocate_ID__c, Phone2Action_Email__c, Phone2Action_Email_Bad__c, ' +
            'P2A__Phone2Action_Email_Optin__c, Phone2Action_Email2__c, Phone2Action_Email2_Bad__c, ' +
            'Phone2Action_Email2_Optin__c, Phone2Action_Email3__c, Phone2Action_Email3_Bad__c, ' +
            'Phone2Action_Email3_Optin__c, Phone2Action_Email4__c, Phone2Action_Email4_Bad__c, ' +
            'Phone2Action_Email4_Optin__c, Phone2Action_Phone__c, Phone2Action_Phone_Bad__c, ' +
            'Phone2Action_Phone_Optin__c, Phone2Action_Phone_Type__c, Phone2Action_Phone2__c, ' +
            'Phone2Action_Phone2_bad__c, Phone2Action_Phone2_Optin__c, Phone2Action_Phone2_Type__c, ' +
            'Phone2Action_Phone3__c, Phone2Action_Phone3_Bad__c, Phone2Action_Phone3_Optin__c, ' +
            'Phone2Action_Phone3_Type__c, Phone2Action_Phone4__c, Phone2Action_Phone4_Bad__c, ' +
            'Phone2Action_Phone4_Optin__c, Phone2Action_Phone4_Type__c FROM Contact ' +
            'WHERE OwnerId = :IntegrationUser AND P2A__Advocate_ID__c != NULL';
            return Database.getQueryLocator(query);}
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        List<Contact> contacts = new List<Contact>();
        for (Contact contact : scope) {
            if (!contact.Phone2Action_Email4_Bad__c && contact.Phone2Action_Email4_Optin__c) {
                	contact.npe01__HomeEmail__c = contact.Phone2Action_Email4__c;
                	contact.Personal_Email_Status__c = 'Opted In';
            	} else if (!contact.Phone2Action_Email3_Bad__c && contact.Phone2Action_Email3_Optin__c) {
                	contact.npe01__HomeEmail__c = contact.Phone2Action_Email3__c;
                	contact.Personal_Email_Status__c = 'Opted In';
            	} else if (!contact.Phone2Action_Email2_Bad__c && contact.Phone2Action_Email2_Optin__c) {
                	contact.npe01__HomeEmail__c = contact.Phone2Action_Email2__c;
                	contact.Personal_Email_Status__c = 'Opted In';
            	} else if (!contact.Phone2Action_Email_Bad__c && contact.P2A__Phone2Action_Email_Optin__c) {
                	contact.npe01__HomeEmail__c = contact.Phone2Action_Email__c;
                	contact.Personal_Email_Status__c = 'Opted In';
                } else {contact.npe01__HomeEmail__c = NULL;
                    contact.Personal_Email_Status__c = NULL;}
            contacts.add(contact);
            recordsProcessed = recordsProcessed + 1;
			}
        update contacts;
        }
    global void finish(Database.BatchableContext BC){
        //Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob apexJob = [Select Id, Status, NumberOfErrors,
                           JobItemsProcessed,TotalJobItems,
                           CreatedBy.Email FROM AsyncApexJob
                           WHERE Id = :bc.getJobId()];
        //Send an email to the Apex job's submitter notifying of job completion
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {apexJob.CreatedBy.Email};
            system.Debug('apexJob.CreatedBy.Email: '+apexJob.CreatedBy.Email);
        mail.setToAddresses(toAddresses);
        mail.setSubject('P2A Contact Update Job is ' + apexJob.Status);
        mail.setPlainTextBody('The batch Apex Job processed ' + apexJob.TotalJobItems + 
                              ' batches with '+ apexJob.NumberOfErrors + ' failures.');
    }
    
}