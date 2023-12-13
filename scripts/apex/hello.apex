//---------------------------------------------------------------------------------------------
// Delete All record
List<TestObject__c> testObjectsForDelete = [SELECT Id FROM TestObject__c WHERE Name LIKE 'TestTriggerRecursion_%'];
delete testObjectsForDelete;

//---------------------------------------------------------------------------------------------
// Create records
List<TestObject__c> testObjectsForCreate = new List<TestObject__c>();
Integer TESTOBJECT_AMOUNT = 250;
for(Integer i = 0; i < TESTOBJECT_AMOUNT; i++) {
    testObjectsForCreate.add(new TestObject__c(Name = 'TestTriggerRecursion_' + i));
}
insert testObjectsForCreate;

//---------------------------------------------------------------------------------------------
// Update records
List<TestObject__c> testObjectsForUpdate = [SELECT Id, Name, TextAreaField__c FROM TestObject__c WHERE Name LIKE 'TestTriggerRecursion_%'];
for(TestObject__c testObject : testObjectsForUpdate) {
    testObject.TextAreaField__c += '<p>updated</p>';
}
update testObjectsForUpdate;





