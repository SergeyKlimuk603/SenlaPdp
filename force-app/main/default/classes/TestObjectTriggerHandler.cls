public with sharing class TestObjectTriggerHandler extends TriggerHandler {
    public static Boolean isDisabled = false;
    private static Integer maxBeforeUpdate = 2;
    private static Integer countBeforeUpdate = 0;
    private static Integer maxAfterUpdate = 2;
    private static Integer countAfterUpdate = 0;

    protected override void beforeUpdate() {
        if (isDisabled) {
            return;
        }
     
        if(countBeforeUpdate >= maxBeforeUpdate || countAfterUpdate >= maxAfterUpdate) {
            //countBeforeUpdate--;
            System.debug(getShift(countBeforeUpdate + 1, 'b') + '-----!!!!!!beforeUpdate was bloced income count: ' + countBeforeUpdate);
            return;
        }

        countBeforeUpdate++;

        //System.debug(getShift(countBeforeUpdate, 'b') + '----------------------------------------------------------beforeUpdate ---------------------------------------------------------------------------------------------------------------------------------');
        System.debug(getShift(countBeforeUpdate, 'b') + '-----beforeUpdate income count' + countBeforeUpdate);

        List<TestObject__c> testObjects = Trigger.new;

        for(TestObject__c testObject : testObjects) {
            testObject.TextAreaField__c += '<p> beforeUpdateTrigger </p>';
        }

        System.debug(getShift(countBeforeUpdate, 'b') + '-----beforeUpdate outcome count = ' + countBeforeUpdate);
        countBeforeUpdate--;
    }

    protected override void afterUpdate() {
        if (isDisabled) {
            return;
        }

        if(countAfterUpdate >= maxAfterUpdate) {
            //countAfterUpdate--;
            System.debug(getShift(countAfterUpdate + 1, 'a') + '-----!!!!!!afterUpdate was bloced income count: ' + countAfterUpdate);
            return;
        }

        countAfterUpdate++;

        //System.debug(getShift(countAfterUpdate, 'a') + '----------------------------------------------------------afterUpdate ----------------------------------------------------------------------------------------------------------------------------------');
        System.debug(getShift(countAfterUpdate, 'a') + '-----afterUpdate income count = ' + countAfterUpdate);

        List<TestObject__c> testObjects = Trigger.new;
        List<TestObject__c> testObjectsForUpdate = new List<TestObject__c>();

        System.debug(getShift(countAfterUpdate, 'a') + '-----before TextAreaField__c = ' + testObjects.get(0).TextAreaField__c);

        for(TestObject__c testObject : testObjects) {
            testObjectsForUpdate.add(
                new TestObject__c(
                    Id = testObject.Id, 
                    TextAreaField__c = testObject.TextAreaField__c + '<p> afterUpdateTrigger </p>'
                )
            );
        }

        System.debug(getShift(countAfterUpdate, 'a') + '-----after TextAreaField__c = ' + testObjectsForUpdate.get(0).TextAreaField__c);

        isDisabled = true;
        update testObjectsForUpdate;
        isDisabled = false;

        System.debug(getShift(countAfterUpdate, 'a') + '-----first inner update _____&&&&& before update count = ' + countAfterUpdate);
        update testObjectsForUpdate;
        System.debug(getShift(countAfterUpdate, 'a') + '-----second inner update _____????? count = ' + countAfterUpdate);
        update testObjectsForUpdate;
        update testObjectsForUpdate;
        update testObjectsForUpdate;
        update testObjectsForUpdate;
        update testObjectsForUpdate;
        update testObjectsForUpdate;
        update testObjectsForUpdate;
        update testObjectsForUpdate;

        

        System.debug(getShift(countAfterUpdate, 'a') + '-----afterUpdate outcome count = ' + countAfterUpdate);

        countAfterUpdate--;
        
    }

    private static String getShift(Integer length, String simbol) {
        String result = '';

        for(Integer i = 0; i < ((1 + length) * 20); i++) {
            result += simbol;
        }

        return result;
    }
}