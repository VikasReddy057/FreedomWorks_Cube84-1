public class MassUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    private String strId;
    Set<Id> successRecord = new Set<Id>();
    Set<Id> failureRecord = new Set<Id>();
    
    public MassUpdateBatch(String recordId) {
        strId = recordId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Account WHERE RecordType.Name=\'Household\' AND Id < \''+strId+'\' ORDER BY Id DESC LIMIT 100000';
        system.debug('query>>> '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        system.debug('scope>>> '+scope);
        Database.SaveResult[] srList = Database.update(scope, false);
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                successRecord.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error Message>>> '+err.getMessage());
                }
                failureRecord.add(sr.getId());
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        String csvBody = '';
        for(String recordId : failureRecord) {
            csvBody += recordId+'\n';
        }
        String csvHeader = 'Id\n';
        String csvContent = csvHeader+csvBody;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new String[] {'sfdcdev@cube84.com'});
		mail.setSubject('Batch Result');
        mail.setPlainTextBody('The Batch Apex job processed ' + a.TotalJobItems +
         ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.EmailFileAttachment failureAtt = new Messaging.EmailFileAttachment();
        failureAtt.setFileName('Errors.csv');
        failureAtt.setBody(Blob.valueOf(csvContent));
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{failureAtt});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}