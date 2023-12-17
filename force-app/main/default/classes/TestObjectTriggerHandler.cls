public with sharing class TestObjectTriggerHandler extends TriggerHandler {
    //private static Boolean isUpdateRecursion = false;
    //protected static final Type OBJEC_TYPE = getSObjectType.getObjectType();

    public TestObjectTriggerHandler() {
        //super();
        OBJEC_TYPE = TestObject__c.getSObjectType();
        System.debug('-----TestObjectTriggerHandler runs' + '   ' + Trigger.operationType);
    }

    protected override void beforeUpdate() {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
        // System.debug('-----before Trigger.old: ' + Trigger.old);
        // System.debug('-----before Trigger.new: ' + Trigger.new);
        List<TestObject__c> testObjects = Trigger.new;
        testObjects.get(0).NumberField__c = 666;
        // List<TestObject__c> testObjects = Trigger.new;

        // for(TestObject__c testObject : testObjects) {
        //     testObject.TextAreaField__c += '<p> beforeUpdate Trigger </p>';
        // }
    }

    protected override void afterUpdate() {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
        List<TestObject__c> testObjects = Trigger.new;
        // List<TestObjectParent__c> parents = [
        //     SELECT Id, TextField__c 
        //     FROM TestObjectParent__c 
        //     WHERE Id IN (SELECT TestObjectParent__c FROM TestObject__c WHERE Id IN :testObjects)
        // ];
        Map<Id, TestObjectParent__c> parentsById = new Map<Id, TestObjectParent__c>([
            SELECT Id, TextField__c 
            FROM TestObjectParent__c 
            WHERE Id IN (SELECT TestObjectParent__c FROM TestObject__c WHERE Id IN :testObjects)
        ]);
        // System.debug('-----after Trigger.old: ' + Trigger.old);
        // System.debug('-----after Trigger.new: ' + Trigger.new);
        //System.debug('-----parents: ' + parents);
        System.debug('-----parentsById: ' + parentsById);
        for(TestObject__c testObject : testObjects) {
            parentsById.get(testObject.TestObjectParent__c).TextField__c = testObject.TextField__c;
        }

        update parentsById.values();





        // List<TestObject__c> testObjects = Trigger.new;
        // List<TestObject__c> testObjectsForUpdate = new List<TestObject__c>();

        // for(TestObject__c testObject : testObjects) {
        //     testObjectsForUpdate.add(
        //         new TestObject__c(
        //             Id = testObject.Id, 
        //             TextAreaField__c = testObject.TextAreaField__c + '<p> afterUpdate Trigger </p>'
        //         )
        //     );
        // }
        
        // disabledTriggers.add(OBJEC_TYPE);
        // update testObjectsForUpdate;
        // disabledTriggers.remove(OBJEC_TYPE);

        // update testObjectsForUpdate;
    }
}