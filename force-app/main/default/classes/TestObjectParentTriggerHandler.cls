public with sharing class TestObjectParentTriggerHandler extends TriggerHandler {

    public static TestScenario scenario;

    public TestObjectParentTriggerHandler() {
        System.debug('----TestObjectParentTriggerHandler runs' + '   ' + Trigger.operationType);

        OBJEC_TYPE = TestObjectParent__c.getSObjectType();
    }

    protected override void beforeUpdate(List<SObject> newChangedObjects, Map<Id, SObject> oldChangedObjectsMap) {
        System.debug('----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);

    }

    protected override void afterUpdate(List<SObject> newChangedObjects, Map<Id, SObject> oldChangedObjectsMap) {
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

    private void beforeUpdate2() {
        // После обновления TextField__c у дочернего объекта обновляется TextField__c у родителя и
        // затем у всех его дочерних объектов.

    }

    private void afterUpdate2() {
        // После обновления TextField__c у дочернего объекта обновляется TextField__c у родителя и
        // затем у всех его дочерних объектов.


    }
}