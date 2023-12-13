public with sharing class TestObjectTriggerHandler extends TriggerHandler {
    private static Boolean isRecursionBeforeUpdate = false;
    private static Boolean isRecursionAfterUpdate = false;

    protected override void beforeUpdate() {
        if(isRecursionBeforeUpdate) {
            return;
        }

        isRecursionBeforeUpdate = true;

        List<TestObject__c> testObjects = Trigger.new;

        for(TestObject__c testObject : testObjects) {
            testObject.TextAreaField__c += '<p> beforeUpdateTrigger </p>';
        }
    }

    protected override void afterUpdate() {
        if(isRecursionAfterUpdate) {
            return;
        }

        isRecursionAfterUpdate = true;

        List<TestObject__c> testObjects = Trigger.new;
        List<TestObject__c> testObjectsForUpdate = new List<TestObject__c>();

        for(TestObject__c testObject : testObjects) {
            testObjectsForUpdate.add(
                new TestObject__c(
                    Id = testObject.Id, 
                    TextAreaField__c = testObject.TextAreaField__c + '<p> afterUpdateTrigger </p>'
                )
            );
        }    

        update testObjectsForUpdate;

        isRecursionBeforeUpdate = false;
        isRecursionAfterUpdate = false;
    }
}