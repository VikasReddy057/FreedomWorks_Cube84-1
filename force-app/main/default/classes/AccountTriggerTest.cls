@isTest

public class AccountTriggerTest{


@isTest

Static void method1(){
Account acc = new Account( name = 'test',npo02__LargestAmount__c=10);
insert acc;
acc.npo02__LargestAmount__c  = 100;
update acc;

}
}