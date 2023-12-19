public with sharing class TestObjectParentTriggerHandler extends TriggerHandler {
    public TestObjectParentTriggerHandler() {
        System.debug('----TestObjectParentTriggerHandler runs' + '   ' + Trigger.operationType);

        OBJEC_TYPE = TestObjectParent__c.getSObjectType();
    }

    protected override void beforeUpdate() {
        System.debug('----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
    }

    protected override void afterUpdate() {
        System.debug('----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
        
        List<TestObjectParent__c> testObjectParents = Trigger.new;
        
        List<TestObjectParent__c> parentsById = new List<TestObjectParent__c>([
            SELECT Id, TextField__c, (SELECT Id, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c 
            WHERE Id IN :testObjectParents
        ]);

        List<TestObject__c> testObjectForUpdate = new List<TestObject__c>();
        for (TestObjectParent__c testObjectParent : parentsById) {
            for (TestObject__c testObject : testObjectParent.TestObjects__r) {
                testObject.TextField__c = testObjectParent.TextField__c;
                testObjectForUpdate.add(testObject);
            }
        }

        update testObjectForUpdate;
    }
}