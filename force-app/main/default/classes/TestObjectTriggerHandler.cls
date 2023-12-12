public with sharing class TestObjectTriggerHandler extends TriggerHandler {

    protected override void beforeInsert() {
        System.debug('-----beforeInsert');
    }

    protected override void afterInsert() {
        System.debug('-----afterInsert');
    }

    protected override void beforeUpdate() {
        System.debug('-----beforeUpdate');
        List<TestObject__c> newList = Trigger.new;

        for (TestObject__c testObject : newList) {
            if (testObject.Name.startsWith('TestTriggerRecursion_')) {
                testObject.TextAreaField__c += '<p>beforeApdate Trigger' + '' + '</p>';
            }
        }
        update new TestObject__c(Id = newList.get(0).Id);
    }

    protected override void afterUpdate() {
        System.debug('-----afterUpdate');

        //update new TestObject__c(Id = Trigger.new.get(0).Id);
        //update Trigger.new;

    }

    protected override void beforeDelete() {
        System.debug('-----beforeDelete');
    }

    protected override void afterDelete() {
        System.debug('-----afterDelete');
    }
}
