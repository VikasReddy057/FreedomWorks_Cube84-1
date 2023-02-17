global class SetP2AContactNameAddressPhone implements
Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    @InvocableMethod(label='execute the batch SetP2AContactNameAddressPhone' description='This method will be execute SetP2AContactNameAddressPhone')
  public static void executeBatchMethod(List<String> lst) {
    Database.executeBatch(new SetP2AContactNameAddressPhone(), 200);
  }global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records to be passed to execute
        String IntegrationUser = '0050b0000060Uys';
        String query = 'SELECT Id, OwnerId, Salutation, Firstname, MiddleName, ' +
            'LastName, Suffix, MailingStreet, MailingState, MailingPostalCode, ' +
            'Integration_Email__c, Integration_Email_Status__c, npe01__HomeEmail__c, ' +
            'Personal_Email_Status__c, npe01__WorkEmail__c, Work_Email_Status__c, ' +
            'npe01__AlternateEmail__c, Alternate_Email_Status__c, HomePhone, ' +
            'MobilePhone, Mobile_Phone_Status__c, npe01__WorkPhone__c, npe01__PreferredPhone__c, ' +
            'P2A__Advocate_ID__c, Phone2Action_Prefix__c, Phone2Action_First_Name__c,' +
            'Phone2Action_Middle_Name__c, Phone2Action_Last_Name__c, Phone2Action_Suffix__c,' +
            'Phone2Action_Mailing_Address1__c, Phone2Action_City__c, Phone2Action_Mailing_State__c,' + 
            'Phone2Action_Zip5__c, Phone2Action_Phone__c, Phone2Action_Phone_Bad__c, ' +
            'Phone2Action_Phone_Optin__c, Phone2Action_Phone_Type__c, Phone2Action_Phone2__c, ' +
            'Phone2Action_Phone2_bad__c, Phone2Action_Phone2_Optin__c, Phone2Action_Phone2_Type__c, ' +
            'Phone2Action_Phone3__c, Phone2Action_Phone3_Bad__c, Phone2Action_Phone3_Optin__c, ' +
            'Phone2Action_Phone3_Type__c, Phone2Action_Phone4__c, Phone2Action_Phone4_Bad__c, ' +
            'Phone2Action_Phone4_Optin__c, Phone2Action_Phone4_Type__c FROM Contact ' +
            'WHERE OwnerId = :IntegrationUser AND P2A__Advocate_ID__c != NULL';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        List<Contact> contacts = new List<Contact>();
        for (Contact contact : scope) {
           	contact.Salutation = contact.Phone2Action_Prefix__c;
			contact.FirstName = contact.Phone2Action_First_Name__c;
			contact.MiddleName = contact.Phone2Action_Middle_Name__c;
			contact.Phone2Action_Last_Name__c = contact.LastName;
			contact.Suffix = contact.Phone2Action_Suffix__c;
            contact.MailingStreet = contact.Phone2Action_Mailing_Address1__c;
            contact.MailingCity = contact.Phone2Action_City__c;
            contact.MailingState = contact.Phone2Action_Mailing_State__c;
            contact.MailingPostalCode = contact.Phone2Action_Zip5__c;
            if (contact.Phone2Action_First_Name__c != NULL){
                contact.Nickname__c = contact.Phone2Action_First_Name__c;
            }
            if (contact.Phone2Action_Phone4_Type__c == 'Mobile' && !contact.Phone2Action_Phone4_Bad__c && contact.Phone2Action_Phone4_Optin__c) {
                contact.MobilePhone = contact.Phone2Action_Phone4__c;
                contact.Mobile_Phone_Status__c = 'Opted In';
            	} else if (contact.Phone2Action_Phone3_Type__c == 'Mobile' && !contact.Phone2Action_Phone3_Bad__c && contact.Phone2Action_Phone3_Optin__c) {
                contact.MobilePhone = contact.Phone2Action_Phone3__c;
                contact.Mobile_Phone_Status__c = 'Opted In';
            	} else if (contact.Phone2Action_Phone2_Type__c == 'Mobile' && !contact.Phone2Action_Phone2_Bad__c && contact.Phone2Action_Phone2_Optin__c) {
                contact.MobilePhone = contact.Phone2Action_Phone2__c;
                contact.Mobile_Phone_Status__c = 'Opted In';
            	} else if (contact.Phone2Action_Phone_Type__c == 'Mobile' && !contact.Phone2Action_Phone_Bad__c && contact.Phone2Action_Phone_Optin__c) {
                contact.MobilePhone = contact.Phone2Action_Phone__c;
                contact.Mobile_Phone_Status__c = 'Opted In';
            	} else {
            	contact.MobilePhone = NULL;
            	}
            if (contact.Phone2Action_Phone4_Type__c == 'Landline' && !contact.Phone2Action_Phone4_Bad__c) {
                contact.HomePhone = contact.Phone2Action_Phone4__c;
            	} else if (contact.Phone2Action_Phone3_Type__c == 'Landline' && !contact.Phone2Action_Phone3_Bad__c) {
                contact.HomePhone = contact.Phone2Action_Phone3__c;
            	} else if (contact.Phone2Action_Phone2_Type__c == 'Landline' && !contact.Phone2Action_Phone2_Bad__c) {
                contact.HomePhone = contact.Phone2Action_Phone2__c;
            	} else if (contact.Phone2Action_Phone_Type__c == 'Landline' && !contact.Phone2Action_Phone_Bad__c) {
                contact.HomePhone = contact.Phone2Action_Phone__c;
            	} else {
            	contact.HomePhone = NULL;
            	}
            if (contact.Phone2Action_Phone4_Type__c == 'Voip' && !contact.Phone2Action_Phone4_Bad__c) {
                contact.npe01__WorkPhone__c = contact.Phone2Action_Phone4__c;
            	} else if (contact.Phone2Action_Phone3_Type__c == 'Voip' && !contact.Phone2Action_Phone3_Bad__c) {
				contact.npe01__WorkPhone__c = contact.Phone2Action_Phone3__c;
            	} else if (contact.Phone2Action_Phone2_Type__c == 'Voip' && !contact.Phone2Action_Phone2_Bad__c) {
                contact.npe01__WorkPhone__c = contact.Phone2Action_Phone2__c;
            	} else if (contact.Phone2Action_Phone_Type__c == 'Voip' && !contact.Phone2Action_Phone_Bad__c) {
                contact.npe01__WorkPhone__c = contact.Phone2Action_Phone__c;
            	} else {
            	contact.npe01__WorkPhone__c = NULL;
            	}
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