//---------------------------------------------------------------------------------------------
// Delete All record
List<TestObject__c> testObjectsForDelete = [SELECT Id FROM TestObject__c WHERE Name LIKE 'ProcessName_%'];
delete testObjectsForDelete;

//---------------------------------------------------------------------------------------------
// Create records
Integer TESTOBJECT_AMOUNT = 500;
List<TestObject__c> testObjectsForCreate = new List<TestObject__c>();
for(Integer i = 0; i < TESTOBJECT_AMOUNT; i++) {
    testObjectsForCreate.add(new TestObject__c(Name = 'ProcessName_' + i));
}
insert testObjectsForCreate;

//---------------------------------------------------------------------------------------------
// Update records


//---------------------------------------------------------------------------------------------