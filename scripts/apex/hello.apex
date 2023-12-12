List<TestObject__c> testObjects = [SELECT Id FROM TestObject__c WHERE Name LIKE 'TestTriggerRecursion_%'];
delete testObjects;

Integer TEST_OBJECT_ANOUNT = 4000;
List<TestObject__c> testObjects = new List<TestObject__c>();
for(Integer i = 0; i < TEST_OBJECT_ANOUNT; i++) {
    testObjects.add(new TestObject__c(Name = 'TestTriggerRecursion_' + i));
}
insert testObjects;





