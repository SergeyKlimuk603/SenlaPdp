public with sharing class TestObjectParentTriggerHandler extends TriggerHandler {
    public TestObjectParentTriggerHandler() {
        OBJEC_TYPE = TestObjectParent__c.getSObjectType();
        System.debug('-----TestObjectParentTriggerHandler runs' + '   ' + Trigger.operationType);
    }

    protected override void beforeUpdate() {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
        // List<TestObjectParent__c> testObjectParents = Trigger.new;

        // for(TestObjectParent__c testObjectParent : testObjectParents) {
        //     testObjectParent.TextField__c += ' beforeUpdate Trigger ';
        // }
    }

    protected override void afterUpdate() {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
        List<TestObjectParent__c> testObjectParents = Trigger.new;
        
        List<TestObjectParent__c> parentsById = new List<TestObjectParent__c>([
            SELECT Id, TextField__c, (SELECT Id, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c 
            WHERE Id IN :testObjectParents
        ]);
        // System.debug('-----after Trigger.old: ' + Trigger.old);
        // System.debug('-----after Trigger.new: ' + Trigger.new);
        //System.debug('-----parents: ' + parents);
        System.debug('-----parentsById1: ' + parentsById);
        System.debug('-----parentsById1.get(0).TestObjects: ' + parentsById.get(0).TestObjects__r);

        List<TestObject__c> testObjectForUpdate = new List<TestObject__c>();
        for (TestObjectParent__c testObjectParent : parentsById) {
            for (TestObject__c testObject : testObjectParent.TestObjects__r) {
                testObject.TextField__c = testObjectParent.TextField__c;
                testObjectForUpdate.add(testObject);
            }
        }

        update testObjectForUpdate;
        // for(TestObject__c testObject : testObjects) {
        //     parentsById.get(testObject.TestObjectParent__c).TextField__c = testObject.TextField__c;
        // }

        // update parentsById.values();







        // List<TestObjectParent__c> testObjectParents = Trigger.new;
        // List<TestObjectParent__c> testObjectParentsForUpdate = new List<TestObjectParent__c>();

        // for(TestObjectParent__c testObjectParent : testObjectParents) {
        //     testObjectParentsForUpdate.add(
        //         new TestObjectParent__c(
        //             Id = testObjectParent.Id, 
        //             TextField__c = testObjectParent.TextField__c + ' afterUpdate Trigger '
        //         )
        //     );
        // }

        // disabledTriggers.add(OBJEC_TYPE);
        // update testObjectParentsForUpdate;
        // disabledTriggers.remove(OBJEC_TYPE);

        // update testObjectParentsForUpdate;
    }
}