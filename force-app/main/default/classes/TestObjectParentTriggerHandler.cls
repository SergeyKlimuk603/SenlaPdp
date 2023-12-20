public with sharing class TestObjectParentTriggerHandler extends TriggerHandler {

    public static TestScenario scenario;

    public TestObjectParentTriggerHandler() {
        System.debug('----TestObjectParentTriggerHandler runs' + '   ' + Trigger.operationType);

        OBJEC_TYPE = TestObjectParent__c.getSObjectType();
    }

    protected override void beforeUpdate(List<SObject> newChangedObjects, Map<Id, SObject> oldChangedObjectsMap) {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
        // System.debug('-----records for update in before trigger: ' + newChangedObjects.size());

        List<TestObjectParent__c> testObjectParentsNew = newChangedObjects;
        Map<Id, TestObjectParent__c> testObjectParentsOldMap = 
            new Map<Id, TestObjectParent__c>((List<TestObjectParent__c>) oldChangedObjectsMap.values());

        switch on scenario {
            when SCENARIO_1 {
                beforeUpdate1(testObjectParentsNew, testObjectParentsOldMap);
            }
            when SCENARIO_2 {
                beforeUpdate2(testObjectParentsNew, testObjectParentsOldMap);
            }
        }

        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType + ' finish');

    }

    protected override void afterUpdate(List<SObject> newChangedObjects, Map<Id, SObject> oldChangedObjectsMap) {
        System.debug('----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
        
        List<TestObjectParent__c> testObjectParentsNew = newChangedObjects;
        Map<Id, TestObjectParent__c> testObjectParentsOldMap = 
            new Map<Id, TestObjectParent__c>((List<TestObjectParent__c>) oldChangedObjectsMap.values());

        switch on scenario {
            when SCENARIO_1 {
                afterUpdate1(testObjectParentsNew, testObjectParentsOldMap);
            }
            when SCENARIO_2 {
                afterUpdate2(testObjectParentsNew, testObjectParentsOldMap);
            }
        }

        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType + ' finish');
    }

    private void beforeUpdate1(List<TestObjectParent__c> testObjectParentsNew, Map<Id, TestObjectParent__c> testObjectParentsOldMap) {
        // После обновления TextField__c у дочернего объекта обновляется поле TextField__c у всех 
        // дочерних объектов того же родителя.
    }

    private void afterUpdate1(List<TestObjectParent__c> testObjectParentsNew, Map<Id, TestObjectParent__c> testObjectParentsOldMap) {
        // После обновления TextField__c у дочернего объекта обновляется поле TextField__c у всех 
        // дочерних объектов того же родителя.
    }

    private void beforeUpdate2(List<TestObjectParent__c> testObjectParentsNew, Map<Id, TestObjectParent__c> testObjectParentsOldMap) {
        // После обновления TextField__c у дочернего объекта обновляется TextField__c у родителя и
        // затем у всех его дочерних объектов.

    }

    private void afterUpdate2(List<TestObjectParent__c> testObjectParentsNew, Map<Id, TestObjectParent__c> testObjectParentsOldMap) {
        // После обновления TextField__c у дочернего объекта обновляется TextField__c у родителя и
        // затем у всех его дочерних объектов.
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
     
        List<TestObjectParent__c> parentsById = new List<TestObjectParent__c>([
            SELECT Id, TextField__c, (SELECT Id, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c
            WHERE Id IN :testObjectParentsNew
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