public with sharing class TestObjectTriggerHandler extends TriggerHandler {
    public static Boolean isDisabled = false;
    private static Integer maxBeforeUpdate = 3;
    private static Integer countBeforeUpdate = 0;
    private static Integer maxAfterUpdate = 3;
    private static Integer countAfterUpdate = 0;

    protected override void beforeUpdate() {
        if (isDisabled) {
            return;
        }
     
        if(countBeforeUpdate >= maxBeforeUpdate || countAfterUpdate >= maxAfterUpdate) {
            return;
        }

        countBeforeUpdate++;

        List<TestObject__c> testObjects = Trigger.new;

        for(TestObject__c testObject : testObjects) {
            testObject.TextAreaField__c += '<p> beforeUpdateTrigger </p>';
        }

        countBeforeUpdate--;
    }

    protected override void afterUpdate() {
        if (isDisabled) {
            return;
        }

        if(countAfterUpdate >= maxAfterUpdate) {
            return;
        }

        countAfterUpdate++;

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

        // Этот блок необходим для записи статистики в объект и на логику не влияет
        isDisabled = true;
        update testObjectsForUpdate;
        isDisabled = false;

        update testObjectsForUpdate;
        
        countAfterUpdate--;
    }
}