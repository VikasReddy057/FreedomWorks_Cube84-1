/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Primary_Channel_MembersTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Primary_Channel_MembersTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Primary_Channel_Members__c());
    }
}