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
    static void test_memberTextChanged() {
        Integer familiesAmount = 500;
        Integer familyMembersAmount = 3;
        String fieldChanges = 'Field was changed';
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = makeData(familiesAmount, familyMembersAmount);

        //startAssert----------------
        List<TestObjectParent__c> familiesBeforeUpdate = [
            SELECT Id, TextField__c, (SELECT Id, Name, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c
        ];

        for (TestObjectParent__c family : familiesBeforeUpdate) {
            System.debug('-----family.TextField: ' + family.TextField__c);
            Assert.isNull(family.TextField__c);
            for (TestObject__c member : family.TestObjects__r) {
                System.debug('-----member.TextField: ' + member.TextField__c);
                Assert.isNull(member.TextField__c);
            }
        }
        //endAssert----------------

        List<TestObject__c> membersForUpdate = new List<TestObject__c>();
        for (TestObjectParent__c family : membersByFamily.keySet()) {
            TestObject__c firstFamilyMember = membersByFamily.get(family).get(0);
            firstFamilyMember.TextField__c = fieldChanges;
            membersForUpdate.add(firstFamilyMember);
        }

        update membersForUpdate;

        //startAssert----------------
        List<TestObjectParent__c> familiesAfterUpdate = [
            SELECT Id, TextField__c, (SELECT Id, Name, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c
        ];

        for (TestObjectParent__c family : familiesAfterUpdate) {
            System.debug('-----family.TextField: ' + family.TextField__c);
            Assert.areEqual(fieldChanges, family.TextField__c);
            for (TestObject__c member : family.TestObjects__r) {
                System.debug('-----member.TextField: ' + member.TextField__c);
                Assert.areEqual(fieldChanges, member.TextField__c);
            }
        }
        //endAssert----------------
    }

    @IsTest
    static void test_familyTextChanged() {
        Integer familiesAmount = 1;
        Integer familyMembersAmount = 3;
        String fieldChanges = 'Field was changed';
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = makeData(familiesAmount, familyMembersAmount);

        //startAssert----------------
        List<TestObjectParent__c> familiesBeforeUpdate = [
            SELECT Id, TextField__c, (SELECT Id, Name, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c
        ];

        for (TestObjectParent__c family : familiesBeforeUpdate) {
            System.debug('-----family.TextField: ' + family.TextField__c);
            Assert.isNull(family.TextField__c);
            for (TestObject__c member : family.TestObjects__r) {
                System.debug('-----member.TextField: ' + member.TextField__c);
                Assert.isNull(member.TextField__c);
            }
        }
        //endAssert----------------

        List<TestObjectParent__c> familiesForUpdate = new List<TestObjectParent__c>();
        for (TestObjectParent__c family : membersByFamily.keySet()) {
            family.TextField__c = fieldChanges;
            familiesForUpdate.add(family);
        }

        update familiesForUpdate;

        //startAssert----------------
        List<TestObjectParent__c> familiesAfterUpdate = [
            SELECT Id, TextField__c, (SELECT Id, Name, TextField__c FROM TestObjects__r)
            FROM TestObjectParent__c
        ];

        for (TestObjectParent__c family : familiesAfterUpdate) {
            System.debug('-----family.TextField: ' + family.TextField__c);
            Assert.areEqual(fieldChanges, family.TextField__c);
            for (TestObject__c member : family.TestObjects__r) {
                System.debug('-----member.TextField: ' + member.TextField__c);
                Assert.areEqual(fieldChanges, member.TextField__c);
            }
        }
        //endAssert----------------
    }

    @IsTest
    static void test_memberTextChanged_Scenario1() {
        // После обновления TextField__c у дочернего объекта обновляется поле TextField__c у всех 
        // дочерних объектов того же родителя. Сам родитель не обновляется.
        TestObjectTriggerHandler.scenario = TestScenario.SCENARIO_1;
        TestObjectParentTriggerHandler.scenario = TestScenario.SCENARIO_1;
        Integer familiesAmount = 25;
        Integer familyMembersAmount = 3;
        String fieldChanges = 'Field was changed';
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = makeData(familiesAmount, familyMembersAmount);

        //startAssert----------------
        List<TestObjectParent__c> familiesBeforeUpdate = [
            SELECT Id, TextField__c, (SELECT Id, Name, TextField__c, NumberField__c FROM TestObjects__r)
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
            System.debug('-----Start Update-------------------------------------------');
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