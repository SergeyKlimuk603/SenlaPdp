public with sharing class TestObjectTriggerHandler extends TriggerHandler {
    private static Set<Id> precessedId = new Set<Id>();
    public static Boolean isDisabled = false;
    // private static Integer maxBeforeUpdate = 3;
    // private static Integer countBeforeUpdate = 0;
    // private static Integer maxAfterUpdate = 3;
    // private static Integer countAfterUpdate = 0;
    private List<TestObject__c> testObjectsNew;

    public TestObjectTriggerHandler() {
        testObjectsNew = Trigger.new;
    }

    protected override void beforeUpdate() {
        List<TestObject__c> testObjectsForPrecess = getNotPrecessedRecords(testObjectsNew);

        if(testObjectsForPrecess.isEmpty()) {
            return;
        }

        for(TestObject__c testObject : testObjectsForPrecess) {
            testObject.TextAreaField__c += '<p> beforeUpdateTrigger </p>';
        }









        // if (isDisabled) {
        //     return;
        // }
     
        // if(countBeforeUpdate >= maxBeforeUpdate || countAfterUpdate >= maxAfterUpdate) {
        //     return;
        // }

        // countBeforeUpdate++;

        // List<TestObject__c> testObjects = Trigger.new;

        // for(TestObject__c testObject : testObjects) {
        //     testObject.TextAreaField__c += '<p> beforeUpdateTrigger </p>';
        // }

        // countBeforeUpdate--;
    }

    // protected override void afterUpdate() {
    //     if (isDisabled) {
    //         return;
    //     }

    //     if(countAfterUpdate >= maxAfterUpdate) {
    //         return;
    //     }

    //     countAfterUpdate++;

    //     List<TestObject__c> testObjects = Trigger.new;
    //     List<TestObject__c> testObjectsForUpdate = new List<TestObject__c>();

    //     for(TestObject__c testObject : testObjects) {
    //         testObjectsForUpdate.add(
    //             new TestObject__c(
    //                 Id = testObject.Id, 
    //                 TextAreaField__c = testObject.TextAreaField__c + '<p> afterUpdateTrigger </p>'
    //             )
    //         );
    //     }

    //     // Этот блок необходим для записи статистики в объект и на логику не влияет
    //     isDisabled = true;
    //     update testObjectsForUpdate;
    //     isDisabled = false;

    //     update testObjectsForUpdate;
        
    //     countAfterUpdate--;
    // }

    private List<TestObject__c> getNotPrecessedRecords(List<TestObject__c> allIncomingNewRecords) {
        List<TestObject__c> testObjectsForProcess = new List<TestObject__c>();

        for(TestObject__c incomingNewTestObject : allIncomingNewRecords) {
            if(!precessedId.contains(incomingNewTestObject.Id)) {
                testObjectsForProcess.add(incomingNewTestObject);
            }
        }

        return testObjectsForProcess;
    }
}