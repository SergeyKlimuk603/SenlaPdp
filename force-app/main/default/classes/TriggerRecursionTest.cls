@IsTest
private class TriggerRecursionTest {
    /*
    Исходная ситуация.
    Есть семья - родительский объект (для наглядности Account). Члены семьи - дочерние объекты
    (для наглядности Contact). У этой семьи есть домашний телефон, телефон прописан и в Account
    и в Contacts.
    Условие
    Если в семье Account изменился номер телефона, он должен быть автоматически изменен и у
    членов семьи Contacts. Если номер телефона изменился у Contact, он автоматически должен
    поменяться и у семьи Acount и у остальных членов семьи.
    */


    @IsTest
    static void test_makingData() {
        Integer familiesAmount = 1;
        Integer familyMembersAmount = 3;
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = makeData(familiesAmount, familyMembersAmount);

        List<TestObjectParent__c> createdFamilies = [SELECT Id FROM TestObjectParent__c];
        List<TestObject__c> createdMembers = [SELECT Id FROM TestObject__c];

        Assert.areEqual(familiesAmount, createdFamilies.size());
        Assert.areEqual(familiesAmount * familyMembersAmount, createdMembers.size());
    }

    @IsTest
    static void test_memberTextChanged_Scenario0_1() {
        Integer membersAmount = 1;

        test_memberTextChanged_Scenario0(membersAmount, ' Scenario0 1 members');
    }

    @IsTest
    static void test_memberTextChanged_Scenario0_201() {
        Integer membersAmount = 201;

        test_memberTextChanged_Scenario0(membersAmount, ' Scenario0 201 members');
    }

    @IsTest
    static void test_memberTextChanged_Scenario0_1001() {
        Integer membersAmount = 1001;

        test_memberTextChanged_Scenario0(membersAmount, ' Scenario0 1001 members');
    }

    static void test_memberTextChanged_Scenario0(Integer membersAmount, String details) {
        // Запись объекта TestObject__c обновляет поле TextField__c самой себя.
        TestObjectTriggerHandler.scenario = TestScenario.SCENARIO_0;
        
        String fieldChanges = 'Field was changed';
        TestObjectTriggerHandler.textFieldValueForTests = fieldChanges;
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = makeData(1, membersAmount);

        //startAssert----------------
        List<TestObject__c> membersBeforeUpdate = [
            SELECT Id, Name, TextField__c, NumberField__c, TextAreaField__c
            FROM TestObject__c
        ];

        for (TestObject__c member : membersBeforeUpdate) {
            // System.debug('-----member.TextField: ' + member.TextField__c);
            Assert.isNull(member.TextField__c);
            Assert.isNull(member.NumberField__c);
            Assert.isNull(member.TextAreaField__c);
        }
        //endAssert----------------

        List<TestObject__c> membersForUpdate = new List<TestObject__c>();
        for (TestObjectParent__c family : membersByFamily.keySet()) {
            for (TestObject__c testObject : membersByFamily.get(family)) {
                testObject.TextField__c = fieldChanges;
                membersForUpdate.add(testObject);
            }
        }

        Test.startTest();
            System.debug('-----Start Update ' + details + ' -------------------------------------------');
            update membersForUpdate;
            System.debug('-----End Update-------------------------------------------');
        Test.stopTest();

        //startAssert----------------
        List<TestObject__c> membersAfterUpdate = [
            SELECT Id, Name, TextField__c, NumberField__c, TextAreaField__c 
            FROM TestObject__c
        ];

        for (TestObject__c member : membersAfterUpdate) {
             System.debug('-----member.TextField: ' + member.TextField__c);
             System.debug('-----member.NumberField__c: ' + member.NumberField__c);
             System.debug('-----member.TextAreaField__c: ' + member.TextAreaField__c);
            Assert.areEqual(fieldChanges, member.TextField__c);
            Assert.areEqual(fieldChanges, member.TextAreaField__c);
            Assert.areEqual((fieldChanges).length(), member.NumberField__c);
        }
        //endAssert----------------
    }
    
    @IsTest
    static void test_memberTextChanged_Scenario1_1_3() {
        Integer familiesAmount = 1;
        Integer familyMembersAmount = 3;

        test_memberTextChanged_Scenario1(familiesAmount, familyMembersAmount, ' Scenario1 1 family 3 members. Member changes');

    }

    @IsTest
    static void test_memberTextChanged_Scenario1_201_3() {
        Integer familiesAmount = 201;
        Integer familyMembersAmount = 3;

        test_memberTextChanged_Scenario1(familiesAmount, familyMembersAmount, ' Scenario1 201 family 300 members. Member changes');

    }

    @IsTest
    static void test_memberTextChanged_Scenario1_1001_3() {
        Integer familiesAmount = 1001;
        Integer familyMembersAmount = 3;

        test_memberTextChanged_Scenario1(familiesAmount, familyMembersAmount, ' Scenario1 1001 family 3 members. Member changes');

    }

    @IsTest
    static void test_memberTextChanged_Scenario1_1_300() {
        Integer familiesAmount = 1;
        Integer familyMembersAmount = 300;

        test_memberTextChanged_Scenario1(familiesAmount, familyMembersAmount, ' Scenario1 1 family 300 members');

    }

    static void test_memberTextChanged_Scenario1(Integer familiesAmount, Integer familyMembersAmount, String details) {
        // После обновления TextField__c у дочернего объекта обновляется поле TextField__c у всех 
        // дочерних объектов того же родителя. Сам родитель не обновляется.
        TestObjectTriggerHandler.scenario = TestScenario.SCENARIO_1;
        TestObjectParentTriggerHandler.scenario = TestScenario.SCENARIO_1;
        
        String fieldChanges = 'Field was changed';
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = makeData(familiesAmount, familyMembersAmount);

        //startAssert----------------
        List<TestObjectParent__c> familiesBeforeUpdate = [
            SELECT Id, Name, TextField__c, (SELECT Id, Name, TextField__c, NumberField__c FROM TestObjects__r)
            FROM TestObjectParent__c
        ];

        for (TestObjectParent__c family : familiesBeforeUpdate) {
            Assert.isNull(family.TextField__c);
            for (TestObject__c member : family.TestObjects__r) {
                // System.debug('-----member.TextField: ' + member.TextField__c);
                Assert.isNull(member.TextField__c);
            }
        }
        //endAssert----------------

        List<TestObject__c> membersForUpdate = new List<TestObject__c>();
        for (TestObjectParent__c family : membersByFamily.keySet()) {
            TestObject__c firstFamilyMember = membersByFamily.get(family).get(0);
            firstFamilyMember.TextField__c = fieldChanges + '   ' + family.Name;
            membersForUpdate.add(firstFamilyMember);
        }

        Test.startTest();
            System.debug('-----Start Update ' + details + ' -------------------------------------------');
            update membersForUpdate;
            System.debug('-----End Update-------------------------------------------');
        Test.stopTest();

        //startAssert----------------
        List<TestObjectParent__c> familiesAfterUpdate = [
            SELECT Id, Name, TextField__c, (SELECT Id, Name, TextField__c, NumberField__c FROM TestObjects__r)
            FROM TestObjectParent__c
        ];

        for (TestObjectParent__c family : familiesAfterUpdate) {
            for (TestObject__c member : family.TestObjects__r) {
                // System.debug('-----member.TextField: ' + member.TextField__c);
                // System.debug('-----member.NumberField__c: ' + member.NumberField__c);
                Assert.areEqual(fieldChanges + '   ' + family.Name, member.TextField__c);
                Assert.areEqual((fieldChanges + '   ' + family.Name).length(), member.NumberField__c);
            }
        }
        //endAssert----------------
    }

    @IsTest
    static void test_memberTextChanged_Scenario2_1_3() {
        Integer familiesAmount = 1;
        Integer familyMembersAmount = 3;

        test_memberTextChanged_Scenario2(familiesAmount, familyMembersAmount, ' Scenario2 1 family 3 members. Member changes');

    }

    @IsTest
    static void test_memberTextChanged_Scenario2_201_3() {
        Integer familiesAmount = 201;
        Integer familyMembersAmount = 3;

        test_memberTextChanged_Scenario2(familiesAmount, familyMembersAmount,  'Scenario2 201 family 300 members. Member changes');

    }

    @IsTest
    static void test_memberTextChanged_Scenario2_1001_3() {
        Integer familiesAmount = 1001;
        Integer familyMembersAmount = 3;

        test_memberTextChanged_Scenario2(familiesAmount, familyMembersAmount, ' Scenario2 1001 family 3 members. Member changes');

    }

    @IsTest
    static void test_memberTextChanged_Scenario2_1_300() {
        Integer familiesAmount = 1;
        Integer familyMembersAmount = 300;

        test_memberTextChanged_Scenario2(familiesAmount, familyMembersAmount, ' Scenario2 1 family 300 members. Member changes');

    }

    static void test_memberTextChanged_Scenario2(Integer familiesAmount, Integer familyMembersAmount, String details) {
        TestObjectTriggerHandler.scenario = TestScenario.SCENARIO_2;
        TestObjectParentTriggerHandler.scenario = TestScenario.SCENARIO_2;
        String fieldChanges = 'Field was changed';
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = makeData(familiesAmount, familyMembersAmount);

        //startAssert----------------
        List<TestObjectParent__c> familiesBeforeUpdate = [
            SELECT Id, Name, TextField__c, (SELECT Id, Name, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c
        ];

        for (TestObjectParent__c family : familiesBeforeUpdate) {
            // System.debug('-----family.TextField: ' + family.TextField__c);
            Assert.isNull(family.TextField__c);
            for (TestObject__c member : family.TestObjects__r) {
                // System.debug('-----member.TextField: ' + member.TextField__c);
                Assert.isNull(member.TextField__c);
            }
        }
        //endAssert----------------

        List<TestObject__c> membersForUpdate = new List<TestObject__c>();
        for (TestObjectParent__c family : membersByFamily.keySet()) {
            TestObject__c firstFamilyMember = membersByFamily.get(family).get(0);
            firstFamilyMember.TextField__c = fieldChanges + '   ' + family.Name;
            membersForUpdate.add(firstFamilyMember);
        }

        Test.startTest();
            System.debug('-----Start Update ' + details + ' -------------------------------------------');
            update membersForUpdate;
            System.debug('-----End Update-------------------------------------------');
        Test.stopTest();

        //startAssert----------------
        List<TestObjectParent__c> familiesAfterUpdate = [
            SELECT Id, Name, TextField__c, (SELECT Id, Name, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c
        ];

        for (TestObjectParent__c family : familiesAfterUpdate) {
            // System.debug('-----family.TextField: ' + family.TextField__c);
            Assert.areEqual(fieldChanges + '   ' + family.Name, family.TextField__c);
            for (TestObject__c member : family.TestObjects__r) {
                // System.debug('-----member.TextField: ' + member.TextField__c);
                Assert.areEqual(fieldChanges + '   ' + family.Name, member.TextField__c);
            }
        }
        //endAssert----------------
    }

    @IsTest
    static void test_familyTextChanged_Scenario2_1_3() {
        Integer familiesAmount = 1;
        Integer familyMembersAmount = 3;

        test_familyTextChanged_Scenario2(familiesAmount, familyMembersAmount, ' Scenario2 1 family 3 members. Family changes');

    }

    @IsTest
    static void test_familyTextChanged_Scenario2_201_3() {
        Integer familiesAmount = 201;
        Integer familyMembersAmount = 3;

        test_familyTextChanged_Scenario2(familiesAmount, familyMembersAmount,  'Scenario2 201 family 300 members. Family changes');

    }

    @IsTest
    static void test_familyTextChanged_Scenario2_1001_3() {
        Integer familiesAmount = 1001;
        Integer familyMembersAmount = 3;

        test_familyTextChanged_Scenario2(familiesAmount, familyMembersAmount, ' Scenario2 1001 family 3 members. Family changes');

    }

    @IsTest
    static void test_familyTextChanged_Scenario2_1_300() {
        Integer familiesAmount = 1;
        Integer familyMembersAmount = 300;

        test_familyTextChanged_Scenario2(familiesAmount, familyMembersAmount, ' Scenario2 1 family 300 members. Family changes');

    }

    static void test_familyTextChanged_Scenario2(Integer familiesAmount, Integer familyMembersAmount, String details) {
        TestObjectTriggerHandler.scenario = TestScenario.SCENARIO_2;
        TestObjectParentTriggerHandler.scenario = TestScenario.SCENARIO_2;
        String fieldChanges = 'Field was changed';
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = makeData(familiesAmount, familyMembersAmount);

        //startAssert----------------
        List<TestObjectParent__c> familiesBeforeUpdate = [
            SELECT Id, Name, TextField__c, (SELECT Id, Name, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c
        ];

        for (TestObjectParent__c family : familiesBeforeUpdate) {
            //System.debug('-----family.TextField: ' + family.TextField__c);
            Assert.isNull(family.TextField__c);
            for (TestObject__c member : family.TestObjects__r) {
                //System.debug('-----member.TextField: ' + member.TextField__c);
                Assert.isNull(member.TextField__c);
            }
        }
        //endAssert----------------

        List<TestObjectParent__c> familiesForUpdate = new List<TestObjectParent__c>();
        for (TestObjectParent__c family : membersByFamily.keySet()) {
            family.TextField__c = fieldChanges + '   ' + family.Name;
            familiesForUpdate.add(family);
        }

        Test.startTest();
            System.debug('-----Start Update ' + details + ' -------------------------------------------');
            update familiesForUpdate;
            System.debug('-----End Update-------------------------------------------');
        Test.stopTest();
        //startAssert----------------
        List<TestObjectParent__c> familiesAfterUpdate = [
            SELECT Id, Name, TextField__c, (SELECT Id, Name, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c
        ];

        for (TestObjectParent__c family : familiesAfterUpdate) {
            //System.debug('-----family.TextField: ' + family.TextField__c);
            Assert.areEqual(fieldChanges + '   ' + family.Name, family.TextField__c);
            for (TestObject__c member : family.TestObjects__r) {
                //System.debug('-----member.TextField: ' + member.TextField__c);
                Assert.areEqual(fieldChanges + '   ' + family.Name, member.TextField__c);
            }
        }
        //endAssert----------------
    }

    static Map<TestObjectParent__c, List<TestObject__c>> makeData(Integer familiesAmount, Integer familyMembersAmount){
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = new Map<TestObjectParent__c, List<TestObject__c>>();

        List<TestObjectParent__c> families = new List<TestObjectParent__c>();
        for (Integer i = 0; i < familiesAmount; i++) {
            TestObjectParent__c family = new TestObjectParent__c(Name = 'family_' + i);
            families.add(family);
        }
        insert families;

        List<TestObject__c> members = new List<TestObject__c>();
        for (TestObjectParent__c family : families) {
            membersByFamily.put(family, new List<TestObject__c>());
            for (Integer i = 0; i < familyMembersAmount; i++) {
                TestObject__c member = new TestObject__c(
                    Name = family.Name + '-' + 'member_' + i,
                    TestObjectParent__c = family.Id
                );
                membersByFamily.get(family).add(member);
                members.add(member);
            }
        }
        insert members;
        
        return membersByFamily;
    }
}