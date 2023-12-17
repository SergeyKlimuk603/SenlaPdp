//---------------------------------------------------------------------------------------------
// Delete All record
List<TestObject__c> testObjectsForDelete = [SELECT Id FROM TestObject__c WHERE Name LIKE 'TestTriggerRecursion_%'];
delete testObjectsForDelete;

//---------------------------------------------------------------------------------------------
// Create records
List<TestObject__c> testObjectsForCreate = new List<TestObject__c>();
Integer TESTOBJECT_AMOUNT = 500;
for(Integer i = 0; i < TESTOBJECT_AMOUNT; i++) {
    testObjectsForCreate.add(new TestObject__c(Name = 'TestTriggerRecursion_' + i));
}
insert testObjectsForCreate;

//---------------------------------------------------------------------------------------------
// Update records
List<TestObject__c> testObjectsForUpdate = [SELECT Id, Name, TextAreaField__c FROM TestObject__c WHERE Name LIKE 'TestTriggerRecursion_%'];
for(TestObject__c testObject : testObjectsForUpdate) {
    testObject.TextAreaField__c += '<p> updated </p>';
}
update testObjectsForUpdate;

//---------------------------------------------------------------------------------------------
// Update records several times
Integer UPDATE_TIMES = 3;
for(Integer i = 0; i < UPDATE_TIMES; i++) {
    List<TestObject__c> testObjectsForUpdate = [SELECT Id, Name, TextAreaField__c FROM TestObject__c WHERE Name LIKE 'TestTriggerRecursion'];
    for(TestObject__c testObject : testObjectsForUpdate) {
        if(i == 0) {
            testObject.TextAreaField__c = '';
        }
        testObject.TextAreaField__c += '<p> updated_' + i + ' </p>';
    }

    update testObjectsForUpdate;
}

//---------------------------------------------------------------------------------------------
// get sObjectType
System.debug('-----TestObject__c.getSObjectType(): ' + TestObject__c.getSObjectType());

//---------------------------------------------------------------------------------------------
Set<String> strings = new Set<String>{'1', '2', '3'};
strings.remove('1');
System.debug('-----strings: ' + strings);