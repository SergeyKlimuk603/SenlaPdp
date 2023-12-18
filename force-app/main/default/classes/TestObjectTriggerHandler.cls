public with sharing class TestObjectTriggerHandler extends TriggerHandler {

    public TestObjectTriggerHandler() {
        System.debug('-----TestObjectTriggerHandler runs' + '   ' + Trigger.operationType);

        OBJEC_TYPE = TestObject__c.getSObjectType();
    }

    protected override void beforeUpdate() {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);

        List<TestObject__c> testObjects = Trigger.new;
        testObjects.get(0).NumberField__c = 666;

    }

    protected override void afterUpdate() {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);

        List<TestObject__c> testObjects = Trigger.new;

        Map<Id, TestObjectParent__c> parentsById = new Map<Id, TestObjectParent__c>([
            SELECT Id, TextField__c 
            FROM TestObjectParent__c 
            WHERE Id IN (SELECT TestObjectParent__c FROM TestObject__c WHERE Id IN :testObjects)
        ]);

        for(TestObject__c testObject : testObjects) {
            parentsById.get(testObject.TestObjectParent__c).TextField__c = testObject.TextField__c;
        }

        update parentsById.values();
    }
}