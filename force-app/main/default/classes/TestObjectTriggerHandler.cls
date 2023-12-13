public with sharing class TestObjectTriggerHandler extends TriggerHandler {
    private static Boolean isRecursionBeforeUpdate = false;
    private static Boolean isRecursionAfterUpdate = false;

    protected override void beforeUpdate() {
        if(isRecursionBeforeUpdate) {
            return;
        }

        isRecursionBeforeUpdate = true;

        TestObject__c testObject = (TestObject__c) Trigger.new.get(0);

        testObject.TextAreaField__c += '<p> beforeUpdateTrigger </p>';
    }

    protected override void afterUpdate() {
        if(isRecursionAfterUpdate) {
            return;
        }

        isRecursionAfterUpdate = true;

        TestObject__c testObject = (TestObject__c) Trigger.new.get(0);

        update new TestObject__c(
            Id = testObject.Id, 
            TextAreaField__c = testObject.TextAreaField__c + '<p> afterUpdateTrigger </p>'
        );

        isRecursionBeforeUpdate = false;
        isRecursionAfterUpdate = false;
    }
}