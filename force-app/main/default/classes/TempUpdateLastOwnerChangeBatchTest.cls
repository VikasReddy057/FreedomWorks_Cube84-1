@isTest
public class TempUpdateLastOwnerChangeBatchTest {

    @isTest
    public static void method1(){
        
        Test.startTest();
        Database.executeBatch(new TempUpdateLastOwnerChangeBatch(),9);
        TempUpdateLastOwnerChangeBatch.DummyMethod();
        Test.stopTest();
    }
}