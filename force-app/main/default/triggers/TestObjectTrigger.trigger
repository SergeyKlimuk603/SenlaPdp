trigger TestObjectTrigger on TestObject__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    // private static Integer TRIGGER_RUN_COUNT = 0;
    // System.debug('-----TestObjectTrigger runs!!! Count: ' + TRIGGER_RUN_COUNT++);
    new TestObjectTriggerHandler().run();
}
