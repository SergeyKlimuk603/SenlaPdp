public with sharing class TestObjectTriggerHandler extends TriggerHandler {

    protected override void beforeInsert(List<SObject> newObjectsList) {
        System.debug('-----beforeInsert');
    }

    protected override void afterInsert(Map<Id, SObject> newObjectsMap) {
        System.debug('-----afterInsert');
    }

    protected override void beforeUpdate(List<SObject> newObjectsList, Map<Id, SObject> oldObjectsMap) {
        System.debug('-----beforeUpdate');
        List<TestObject__c> newList = newObjectsList;

        for (TestObject__c testObject : newList) {
            if (testObject.Name == 'TestTriggerRecursion') {
                //testObject.TextAreaField__c += '<p>beforeApdate Trigger' + count + '</p>';
            }
        }
    }

    protected override void afterUpdate(List<SObject> newObjectsList, Map<Id, SObject> oldObjectsMap) {
        System.debug('-----afterUpdate');
    }

    protected override void beforeDelete(Map<Id, SObject> oldObjectsMap) {
        System.debug('-----beforeDelete');
    }

    protected override void afterDelete(Map<Id, SObject> oldObjectsMap) {
        System.debug('-----afterDelete');
    }
}
