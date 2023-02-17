@isTest
public class MassUpdateBatchTest {

    @isTest
    static void testmethod1() {
        RecordType rType = [Select Id FROM RecordType WHERE sObjectType='Account' and Name = 'Household'];
        
        Account acc = new Account(Name='Test',RecordTypeId=rType.Id);
        insert acc;
        
        Test.startTest();
        MassUpdateBatch mub = new MassUpdateBatch(acc.Id);
        database.executeBatch(mub);
        Test.stopTest();
    }
}