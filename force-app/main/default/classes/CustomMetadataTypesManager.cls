public with sharing class CustomMetadataTypesManager {
    @TestVisible
    private static Map<String, List<TestCmt__mdt>> testCmtByField_v1;
    @TestVisible
    private static Map<String, TestCmt__mdt> testCmtByName_v2;

    public static Map<String, List<TestCmt__mdt>> getTestCmtByField_v1(String field) {
        if (testCmtByField_v1 != null) {
            return testCmtByField_v1;
        }

        List<SObject> testCmts = [SELECT Id, DeveloperName, TextField__c FROM TestCmt__mdt];
        testCmtByField_v1 = mapByField(testCmts, field);

        return testCmtByField_v1;
    }

    public static TestCmt__mdt getTestCmt_v2(String developerName) {
        if (String.isBlank(developerName)) {
            return null;
        }

        TestCmt__mdt testCmt = testCmtByName_v2.get(developerName);

        if (testCmt != null) {
            return testCmt;
        }

        testCmt = TestCmt__mdt.getInstance(developerName);
        testCmtByName_v2.put(testCmt.DeveloperName, testCmt);

        return testCmt;
    }

    private static Map<String, List<SObject>> mapByField(List<SObject> records, String field) {
        Map<String, List<SObject>> recordsByField = new Map<String, List<SObject>>();

        if (isBlank(records)) {
            return recordsByField;
        }

        for (SObject record : records) {
            List<SObject> recs = recordsByField.get(field);

            if (recs == null) {
                recs = new List<SObject>();
                recordsByField.put((String) record.get(field), recs);
            }

            recs.add(record);
        }

        return recordsByField;
    }

    private static Boolean isBlank(List<SObject> records) {
        return records == null || records.isEmpty();
    }
}