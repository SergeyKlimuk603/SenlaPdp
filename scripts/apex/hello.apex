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

//---------------------------------------------------------------------------------------------
// Trigger upsert

List<TestObject__c> existObjects = new List<TestObject__c>{
    new TestObject__c(Name = 'Exist 1 upsert test delete this'),
    new TestObject__c(Name = 'Exist 2 upsert test delete this'),
    new TestObject__c(Name = 'Exist 3 upsert test delete this'),
    new TestObject__c(Name = 'Exist 4 upsert test delete this')
};

insert existObjects;

List<TestObject__c> forUpsertObjects = new List<TestObject__c>{
    existObjects.get(0),
    new TestObject__c(Name = 'New 1 upsert test delete this'),
    existObjects.get(1),
    new TestObject__c(Name = 'New 2 upsert test delete this'),
    existObjects.get(2),
    new TestObject__c(Name = 'New 3 upsert test delete this'),
    existObjects.get(3),
    new TestObject__c(Name = 'New 4 upsert test delete this')
};

System.debug('-----Start Upsert--------------------------------------------------------------------');

upsert forUpsertObjects;

System.debug('-----End Upsert--------------------------------------------------------------------');

List<TestObject__c> forDeleteObjects = [
    SELECT Id 
    FROM TestObject__c
    WHERE Name LIKE '%delete this'
];

delete forDeleteObjects;

//---------------------------------------------------------------------------------------------
// Map comparing
Map<String, Object> map1 = new Map<String, Object>{
    '1' => 1,
    '2' => '2'
};

Map<String, Object> map2 = new Map<String, Object>{
    '1' => 1,
    '2' => '3'
};

System.debug('-----map1.equals(map2): ' + map1.equals(map2));

//---------------------------------------------------------------------------------------------
List<SObject> objects = Database.query('SELECT Id, Name FROM TestObject__c WHERE Name = \'triggerRecursionTest1\'');
System.debug('-----objects: ' + objects);

List<SObject> objects1 = Database.query('SELECT Id, Name, TextField__c FROM TestObject__c WHERE Name = \'triggerRecursionTest1\'');
System.debug('-----objects1: ' + objects1);

Map<String, Object> conditions = new Map<String, Object>{
    'objectName' => 'triggerRecursionTest1'
};
List<String> fields = new List<String> {
    'Id',
    'Name',
    'TextField__c'
};
String query = 'SELECT ' + String.join(fields, ', ') + ' FROM TestObject__c WHERE Name = :objectName';
System.debug('-----query: ' + query);
List<SObject> objects2 = Database.queryWithBinds(query, conditions, AccessLevel.USER_MODE);

System.debug('-----objects2: ' + objects2);

//---------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------