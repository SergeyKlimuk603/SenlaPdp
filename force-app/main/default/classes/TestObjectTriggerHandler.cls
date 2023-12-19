public with sharing class TestObjectTriggerHandler extends TriggerHandler {

    public static TestScenario scenario;

    public TestObjectTriggerHandler() {
        //System.debug('----TestObjectTriggerHandler runs' + '   ' + Trigger.operationType);
        //System.debug('----Trigger.new: ' + Trigger.new);
        //System.debug('----Trigger.old: ' + Trigger.old);

        OBJEC_TYPE = TestObject__c.getSObjectType();
    }

    protected override void beforeUpdate(List<SObject> newChangedObjects, Map<Id, SObject> oldChangedObjectsMap) {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
        // System.debug('-----records for update in before trigger: ' + newChangedObjects.size());

        List<TestObject__c> testObjectsNew = newChangedObjects;
        Map<Id, TestObject__c> testObjectsOldMap = 
            new Map<Id, TestObject__c>((List<TestObject__c>) oldChangedObjectsMap.values());

        switch on scenario {
            when SCENARIO_1 {
                beforeUpdate1(testObjectsNew, testObjectsOldMap);
            }
            when SCENARIO_2 {
                beforeUpdate2(testObjectsNew, testObjectsOldMap);
            }
        }

        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType + ' finish');
    }

    protected override void afterUpdate(List<SObject> newChangedObjects, Map<Id, SObject> oldChangedObjectsMap) {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);
        // System.debug('-----records for update in after trigger: ' + newChangedObjects.size());
        
        List<TestObject__c> testObjectsNew = newChangedObjects;
        Map<Id, TestObject__c> testObjectsOldMap = 
            new Map<Id, TestObject__c>((List<TestObject__c>) oldChangedObjectsMap.values());

        switch on scenario {
            when SCENARIO_1 {
                afterUpdate1(testObjectsNew, testObjectsOldMap);
            }
            when SCENARIO_2 {
                afterUpdate2(testObjectsNew, testObjectsOldMap);
            }

        }

        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType + ' finish');

        // List<TestObject__c> testObjects = newChangedObjects;
        // System.debug('-----testObjects Ids: ' + getIdsFromList(testObjects));
        // System.debug('-----testObjects.size(): ' + testObjects.size());

        // Map<Id, TestObjectParent__c> parentsById = new Map<Id, TestObjectParent__c>([
        //     SELECT Id, TextField__c, (SELECT Id, Name FROM TestObjects__r)
        //     FROM TestObjectParent__c 
        //     WHERE Id IN (SELECT TestObjectParent__c FROM TestObject__c WHERE Id IN :testObjects)
        // ]);

        // Map<Id, TestObject__c> testObgectByParentId = getTestObgectByParentId(testObjects);

        // List<TestObject__c> testObjectsForUpdate = new List<TestObject__c>();
        // for(TestObjectParent__c parent : parentsById.values()) {
        //     for (TestObject__c testObjectForUpdate : parent.TestObjects__r) {
        //         // не обновляем запись которая инициировала триггер, можно попробовать удалить
        //         // if (testObjectForUpdate.Id == testObgectByParentId.get(parent.Id).Id) {
        //         //     continue;
        //         // }

        //         testObjectForUpdate.TextField__c = testObgectByParentId.get(parent.Id).TextField__c;
        //         testObjectsForUpdate.add(testObjectForUpdate);
        //     }
        // }

        // System.debug('-----testObjectsForUpdate Ids: ' + getIdsFromList(testObjectsForUpdate));
        // System.debug('-----testObjectsForUpdate.size(): ' + testObjectsForUpdate.size());

        // update testObjectsForUpdate;

        // List<TestObject__c> testObjects = Trigger.new;

        // Map<Id, TestObjectParent__c> parentsById = new Map<Id, TestObjectParent__c>([
        //     SELECT Id, TextField__c, (SELECT Id, Name FROM TestObjects__r)
        //     FROM TestObjectParent__c 
        //     WHERE Id IN (SELECT TestObjectParent__c FROM TestObject__c WHERE Id IN :testObjects)
        // ]);

        // List<TestObject__c> testObjectsForUpdate = new List<TestObject__c>();
        // for(TestObject__c testObject : testObjects) {
        //     for (TestObject__c testObjectForUpdate : parentsById.get(testObject.TestObjectParent__c).TestObjects__r) {
        //         // не обновляем запись которая инициировала триггер, можно попробовать удалить
        //         if (testObjectForUpdate.Id == testObject.Id) {
        //             continue;
        //         }

        //         testObjectForUpdate.TextField__c = testObject.TextField__c;
        //         testObjectsForUpdate.add(testObjectForUpdate);
        //     }
        // }

        // update testObjectsForUpdate;
    }

    // Версия где обновление номера происходит через родительский объект
    // protected override void afterUpdate() {
    //     System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);

    //     List<TestObject__c> testObjects = Trigger.new;

    //     Map<Id, TestObjectParent__c> parentsById = new Map<Id, TestObjectParent__c>([
    //         SELECT Id, TextField__c 
    //         FROM TestObjectParent__c 
    //         WHERE Id IN (SELECT TestObjectParent__c FROM TestObject__c WHERE Id IN :testObjects)
    //     ]);

    //     for(TestObject__c testObject : testObjects) {
    //         parentsById.get(testObject.TestObjectParent__c).TextField__c = testObject.TextField__c;
    //     }

    //     update parentsById.values();
    // }


    private void beforeUpdate1(List<TestObject__c> testObjectsNew, Map<Id, TestObject__c> testObjectsOldMap) {
        // После обновления TextField__c у дочернего объекта обновляется поле TextField__c у всех 
        // дочерних объектов того же родителя.

        for (TestObject__c testObject : testObjectsNew) {
            testObject.NumberField__c = testObject.TextField__c.length();
        }
    }

    private void afterUpdate1(List<TestObject__c> testObjectsNew, Map<Id, TestObject__c> testObjectsOldMap) {
        // После обновления TextField__c у дочернего объекта обновляется поле TextField__c у всех 
        // дочерних объектов того же родителя.

        // System.debug('-----testObjectsNew Ids: ' + getIdsFromList(testObjectsNew));
        // System.debug('-----testObjectsNew.size(): ' + testObjectsNew.size());

        Map<Id, TestObjectParent__c> parentsById = new Map<Id, TestObjectParent__c>([
            SELECT Id, TextField__c, (SELECT Id, Name FROM TestObjects__r)
            FROM TestObjectParent__c 
            WHERE Id IN (SELECT TestObjectParent__c FROM TestObject__c WHERE Id IN :testObjectsNew)
        ]);

        Map<Id, TestObject__c> testObgectByParentId = getTestObgectByParentId(testObjectsNew);

        List<TestObject__c> testObjectsForUpdate = new List<TestObject__c>();
        for(TestObjectParent__c parent : parentsById.values()) {
            for (TestObject__c testObjectForUpdate : parent.TestObjects__r) {
                // удаляем запись которая инициировала триггер
                // if (testObjectForUpdate.Id == testObgectByParentId.get(parent.Id).Id) {
                //     continue;
                // }

                testObjectForUpdate.TextField__c = testObgectByParentId.get(parent.Id).TextField__c;
                testObjectsForUpdate.add(testObjectForUpdate);
            }
        }

        // System.debug('-----testObjectsForUpdate Ids: ' + getIdsFromList(testObjectsForUpdate));
        System.debug('-----testObjectsForUpdate.size(): ' + testObjectsForUpdate.size());

        update testObjectsForUpdate;
    }

    private void beforeUpdate2(List<TestObject__c> testObjectsNew, Map<Id, TestObject__c> testObjectsOldMap) {
        // После обновления TextField__c у дочернего объекта обновляется TextField__c у родителя и
        // затем у всех его дочерних объектов.

    }

    private void afterUpdate2(List<TestObject__c> testObjectsNew, Map<Id, TestObject__c> testObjectsOldMap) {
        // После обновления TextField__c у дочернего объекта обновляется TextField__c у родителя и
        // затем у всех его дочерних объектов.
        

    }

    private List<Id> getIdsFromList(List<SObject> records) {
        List<Id> ids = new List<Id>();

        for (SObject record : records) {
            ids.add(record.Id);
        }

        return ids;
    }

    private Map<Id, TestObject__c> getTestObgectByParentId(List<TestObject__c> records) {
        Map<Id, TestObject__c> testObgectByParentId = new Map<Id, TestObject__c>();

        for (TestObject__c record : records) {
            testObgectByParentId.put(record.TestObjectParent__c, record);
        }

        return testObgectByParentId;
    }
}