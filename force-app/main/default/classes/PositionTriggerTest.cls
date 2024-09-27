/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-26-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

@isTest
public class PositionTriggerTest {
  @TestSetup
  static void makeData() {
    User adminUser = TestHelper.createUserWithProfile(
      'System Administrator',
      'adminuser@user.test',
      'admin'
    );
    insert adminUser;

    User profileRestrictedUser = TestHelper.createUserWithProfile(
      'Cant Access Position',
      'restricteduser@user.test',
      'restric'
    );
    insert profileRestrictedUser;

    Candidate__c candidate = TestHelper.createGenericCandidate(1)[0];
    insert candidate;

    Position__c position = TestHelper.createGenericPosition(1)[0];
    insert position;

    Job_Application__c jobApplication = new Job_Application__c(
      Candidate__c = candidate.Id,
      Position__c = position.Id
    );
    insert jobApplication;
  }

  @isTest
  static void testPositionInsert() {
    User adminUser = [
      SELECT Id
      FROM User
      WHERE Email = 'adminuser@user.test'
    ];
    User restrictedUser = [
      SELECT Id
      FROM User
      WHERE Email = 'restricteduser@user.test'
    ];
    Position__c position = [
      SELECT Id
      FROM Position__c
      WHERE Name = 'Test Position 0'
    ];

    Test.startTest();
    System.runAs(adminUser) {
      position.Name = 'Updated Position';
      update position;
    }
    System.runAs(restrictedUser) {
      try {
        position.Name = 'Updated Position';
        update position;
      } catch (DmlException e) {
        System.assertNotEquals(
          null,
          e,
          'User should not be able to access/modify Position__c'
        );
      }
    }
    Test.stopTest();

    List<Position_Update_Log__c> positionUpdateEventLogs = [
      SELECT Id
      FROM Position_Update_Log__c
    ];

    System.assertEquals(
      1,
      positionUpdateEventLogs.size(),
      'Position update event not created'
    );
  }
}
