global class ContactDeletionBatch implements Database.Batchable<Contact>, Database.AllowsCallouts{
	List<Contact> contacts;
    global ContactDeletionBatch(List<Contact> contacts) {
        this.contacts = contacts;
    }
	global Iterable<Contact> start(Database.BatchableContext bc){
        System.debug('Start');
        return contacts;
    }
     
    global void execute(Database.BatchableContext bc, List<Contact> scope){
        System.debug('execute');
        for(Contact contact: scope){
			PostUpSubscriptionController.updateGlobalUnSub((Integer)contact.recipientId__c);
        } 
    }
     
    Public void finish(Database.BatchableContext bc){ 
    }
}