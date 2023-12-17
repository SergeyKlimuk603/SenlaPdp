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
    static Integer FAMILIES_AMOUNT = 1;
    static Integer FAMILY_MEMBERS_AMOUNT = 3;
    
    static Map<TestObjectParent__c, List<TestObject__c>> makeData(Integer familiesAmount, Integer familyMembersAmount){
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = new Map<TestObjectParent__c, List<TestObject__c>>();
        List<TestObjectParent__c> families = new List<TestObjectParent__c>();
        for (Integer i = 0; i < familiesAmount; i++) {
            TestObjectParent__c family = new TestObjectParent__c();
            families.add(family);
        }
        insert families;

        List<TestObject__c> members = new List<TestObject__c>();
        for (TestObjectParent__c family : families) {
            membersByFamily.put(family, new List<TestObject__c>());
            for (Integer i = 0; i < familyMembersAmount; i++) {
                TestObject__c member = new TestObject__c(TestObjectParent__c = family.Id);
                membersByFamily.get(family).add(member);
                members.add(member);
            }
        }
        insert members;

        System.debug('-----membersByFamily: ' + membersByFamily);
        
        return membersByFamily;
    }

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
        Integer familiesAmount = 1;
        Integer familyMembersAmount = 3;
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = makeData(familiesAmount, familyMembersAmount);

        List<TestObject__c> membersForUpdate = new List<TestObject__c>();
        for (List<TestObject__c> members : membersByFamily.values()) {
            members.get(0).TextField__c = 'a2';
            membersForUpdate.add(members.get(0));
        }

        System.debug('-----Start');

        update membersForUpdate;

        TestObjectParent__c family = [SELECT Id, TextField__c FROM TestObjectParent__c];
        List<TestObject__c> members = [SELECT Id, TextField__c FROM TestObject__c];

        System.debug('-----family1: ' + family);
        System.debug('-----members: ' + members);
    }

    @IsTest
    static void test_familyTextChanged() {
        Integer familiesAmount = 1;
        Integer familyMembersAmount = 3;
        Map<TestObjectParent__c, List<TestObject__c>> membersByFamily = makeData(familiesAmount, familyMembersAmount);

        List<TestObjectParent__c> familiesForUpdate = new List<TestObjectParent__c>();
        for (TestObjectParent__c family : membersByFamily.keySet()) {
            family.TextField__c = 'a2';
            familiesForUpdate.add(family);
        }

        System.debug('-----Start');

        update familiesForUpdate;

        TestObjectParent__c family = [SELECT Id, TextField__c FROM TestObjectParent__c];
        List<TestObject__c> members = [SELECT Id, TextField__c FROM TestObject__c];

        System.debug('-----family1: ' + family);
        System.debug('-----members: ' + members);
    }


}