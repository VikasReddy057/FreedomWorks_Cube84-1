@isTest
public class ContactDeletionBatchTest {
    public static TestMethod void test() {
        Contact contact = new Contact(LastName='abc', recipientId__c=123);
        insert contact;
        Contact[] contactList = new List<Contact>();
        contactList.add(contact);
        Test.startTest();
        Database.executeBatch(new ContactDeletionBatch(contactList), 20);
        Test.stopTest();
    }
}