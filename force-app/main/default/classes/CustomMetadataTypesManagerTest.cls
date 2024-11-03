@isTest
private class CustomMetadataTypesManagerTest {

    @isTest
    static void test_getTestCmtByField_v1_ExistCmt() {
        Map<String, List<TestCmt__mdt>> testCmtByField_v1 = 
            CustomMetadataTypesManager.getTestCmtByField_v1('DeveloperName');

        Assert.areEqual('Test 1', testCmtByField_v1.get('Test_1').get(0).TextField__c);      
    }

    @isTest
    static void test_getTestCmtByField_v1_MockCmt() {
        CustomMetadataTypesManager.testCmtByField_v1 = new Map<String, List<TestCmt__mdt>>{
            'TestMock_1' => new List<TestCmt__mdt>{
                new TestCmt__mdt(DeveloperName = 'TestMock_1', TextField__c = 'TestMock 1')
            }
        };
        Map<String, List<TestCmt__mdt>> testCmtByField_v1 = 
            CustomMetadataTypesManager.getTestCmtByField_v1('DeveloperName');

        Assert.areEqual('TestMock 1', testCmtByField_v1.get('TestMock_1').get(0).TextField__c);      
    }
}