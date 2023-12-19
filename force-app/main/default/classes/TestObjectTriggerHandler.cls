public with sharing class TestObjectTriggerHandler extends TriggerHandler {

    public TestObjectTriggerHandler() {
        System.debug('-----TestObjectTriggerHandler runs' + '   ' + Trigger.operationType);

        OBJEC_TYPE = TestObject__c.getSObjectType();
    }

    protected override void beforeUpdate() {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);

        List<TestObject__c> testObjects = Trigger.new;
        for (TestObject__c testObject : testObjects) {
            testObject.NumberField__c = testObject.TextField__c.length();
        }
    }

    protected override void afterUpdate() {
        System.debug('-----TRIGGER: ' + OBJEC_TYPE + '   ' + Trigger.operationType);

        List<TestObject__c> testObjects = Trigger.new;

        Map<Id, TestObjectParent__c> parentsById = new Map<Id, TestObjectParent__c>([
            SELECT Id, TextField__c, (SELECT Id, Name FROM TestObjects__r)
            FROM TestObjectParent__c 
            WHERE Id IN (SELECT TestObjectParent__c FROM TestObject__c WHERE Id IN :testObjects)
        ]);

        List<TestObject__c> testObjectsForUpdate = new List<TestObject__c>();
        for(TestObject__c testObject : testObjects) {
            for (TestObject__c testObjectForUpdate : parentsById.get(testObject.TestObjectParent__c).TestObjects__r) {
                // не обновляем запись которая инициировала триггер, можно попробовать удалить
                if (testObjectForUpdate.Id == testObject.Id) {
                    continue;
                }

                testObjectForUpdate.TextField__c = testObject.TextField__c;
                testObjectsForUpdate.add(testObjectForUpdate);
            }
        }

        update testObjectsForUpdate;
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
}