@isTest
private class CustomSettingTest {

    private static final String STANDART_USER_USERNAME = 'test_v238_hgsdqaqab@test.com';
    private static final String ORG_LEVEL_VALUE = 'Org Level Value';
    private static final String PROFILE_LEVEL_VALUE = 'Profile Level Value';
    private static final String USER_LEVEL_VALUE = 'User Level Value';

    @TestSetup
    static void setupData() {
        // Создаем уровень Custom Setting для всей организации
        TestSetting__c orgLevelSetting = new TestSetting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            TextField__c = ORG_LEVEL_VALUE
        );
        insert orgLevelSetting;

        // Создаем уровень Custom Setting для конкретного профиля
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        TestSetting__c profileLevelSetting = new TestSetting__c(
            SetupOwnerId = testProfile.Id,
            TextField__c = PROFILE_LEVEL_VALUE
        );
        insert profileLevelSetting;

        // Создаем уровень Custom Setting для конкретного пользователя
        User standardUser = createStandardUser(STANDART_USER_USERNAME, true);
        TestSetting__c userLevelSetting = new TestSetting__c(
            SetupOwnerId = standardUser.Id,
            TextField__c = USER_LEVEL_VALUE
        );
        insert userLevelSetting;
    }

    @isTest
    static void testSettings_StandartUser() {
        TestSetting__c settingOrg = TestSetting__c.getInstance();
        System.debug('-----settingOrg: ' + settingOrg);
        Assert.areEqual(ORG_LEVEL_VALUE, settingOrg.TextField__c);

        User testUser = createStandardUser('test_87_90r@test.ru', false);
        System.runAs(testUser) {
            TestSetting__c settingProfile = TestSetting__c.getInstance();
            System.debug('-----settingProfile: ' + settingProfile);
            Assert.areEqual(PROFILE_LEVEL_VALUE, settingProfile.TextField__c);
        }

        User standardUser = [SELECT Id FROM User WHERE Username = :STANDART_USER_USERNAME];
        System.runAs(standardUser) {
            TestSetting__c settingUser = TestSetting__c.getInstance();
            System.debug('-----settingUser: ' + settingUser);
            Assert.areEqual(USER_LEVEL_VALUE, settingUser.TextField__c);
        }
    }

    public static User createUser(String userProfileName, String userName, Boolean doInsert) {
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :userProfileName LIMIT 1].Id,
            LastName = 'Testing',
            Email = userName,
            Alias = 'standt',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = userName
        );

        if (doInsert) {
            insert user;
        }

        return user;
    }

    public static User createStandardUser(String userName, Boolean doInsert) {
        return createUser('Standard User', userName, doInsert);
    }
}