/**
 * @description       : Test class for Position Trigger Handler
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-24-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
@isTest
public class PositionTriggerTest {
  @TestSetup
  static void makeData() {
    User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'adminuser@user.test', 'admin');
    insert adminUser;

    List<Candidate__c> candidateList = CommonTestHelper.createGenericCandidate(10);
    insert candidateList;

    List<Position__c> positionList = CommonTestHelper.createGenericPosition(10);
    insert positionList;

    List<Job_Application__c> jobApplicationList = new List<Job_Application__c>();
    for (Integer index = 0; index < candidateList.size(); index++) {
      jobApplicationList.add(
        new Job_Application__c(Candidate__c = candidateList[index].Id, Position__c = positionList[index].Id)
      );
    }

    insert jobApplicationList;
  }

  /**
   * @description : Test Position Update without changes
   * @author Swastik Dan | 12-21-2024
   **/
  @isTest
  static void testNoChangePositionUpdate() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');

    Test.startTest();

    System.runAs(adminUser) {
      List<Position__c> positionList = [SELECT Id FROM Position__c LIMIT 10];
      update positionList;
    }

    Test.stopTest();

    List<Position_Update_Log__c> positionUpdateList = [
      SELECT Id, Position__c
      FROM Position_Update_Log__c
      WHERE CreatedById = :adminUser.Id
    ];

    System.assertEquals(0, positionUpdateList.size(), 'Logs should not be created for no changes');
  }

  /**
   * @description : Test Bulk Position Update with changes
   * @author Swastik Dan | 12-21-2024
   **/
  @isTest
  static void testBulkPositionUpdate() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');

    Test.startTest();

    System.runAs(adminUser) {
      List<Position__c> positionList = [
        SELECT Id, Name
        FROM Position__c
        LIMIT 10
      ];

      for (Position__c position : positionList) {
        position.Name = 'Updated Admin';
      }
      update positionList;
    }

    Test.stopTest();

    List<Position_Update_Log__c> positionUpdateList = [
      SELECT Id, Position__c
      FROM Position_Update_Log__c
      WHERE CreatedById = :adminUser.Id
    ];

    System.assertEquals(10, positionUpdateList.size(), 'Correct number of records are not inserted as Admin User');
  }
}
// /**
//  * @description       : Test class for Position Trigger Handler
//  * @author            : Swastik Dan
//  * @group             :
//  * @last modified on  : 12-21-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/
// @isTest
// public class PositionTriggerTest {
//   @TestSetup
//   static void makeData() {
//     User adminUser = CommonTestHelper.createUserWithProfile(
//       'System Administrator',
//       'adminuser@user.test',
//       'admin'
//     );
//     insert adminUser;

//     User restrictedUser = CommonTestHelper.createUserWithProfile(
//       'Cant Access Position',
//       'restricteduser@user.test',
//       'restric'
//     );
//     insert restrictedUser;

//     List<Candidate__c> candidateList = CommonTestHelper.createGenericCandidate(
//       10
//     );
//     insert candidateList;

//     List<Position__c> positionList = CommonTestHelper.createGenericPosition(10);
//     insert positionList;

//     List<Job_Application__c> jobApplicationList = new List<Job_Application__c>();
//     for (Integer index = 0; index < candidateList.size(); index++) {
//       jobApplicationList.add(
//         new Job_Application__c(
//           Candidate__c = candidateList[index].Id,
//           Position__c = positionList[index].Id
//         )
//       );
//     }

//     insert jobApplicationList;
//   }

//   /**
//    * @description : Test Position Update without changes
//    * @author Swastik Dan | 12-21-2024
//    **/
//   @isTest
//   static void testNoChangePositionUpdate() {
//     User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
//     User restrictedUser = CommonTestHelper.findUserByEmail(
//       'restricteduser@user.test'
//     );

//     Test.startTest();

//     System.runAs(adminUser) {
//       List<Position__c> positionList = [SELECT Id FROM Position__c LIMIT 10];
//       update positionList;
//     }

//     System.runAs(restrictedUser) {
//       try {
//         List<Position__c> positionList = [SELECT Id FROM Position__c LIMIT 10];
//         update positionList;
//       } catch (Exception e) {
//         System.assertNotEquals(
//           null,
//           e,
//           'Its Inserted candidate with no access'
//         );
//       }
//     }

//     Test.stopTest();

//     List<Position_Update_Log__c> adminLogList = [
//       SELECT Id, Position__c
//       FROM Position_Update_Log__c
//       WHERE CreatedById = :adminUser.Id
//     ];

//     List<Position_Update_Log__c> restrictedLogList = [
//       SELECT Id, Position__c
//       FROM Position_Update_Log__c
//       WHERE CreatedById = :restrictedUser.Id
//     ];

//     System.assertEquals(
//       0,
//       adminLogList.size(),
//       'Logs should not be created for no changes'
//     );
//     System.assertEquals(
//       0,
//       restrictedLogList.size(),
//       'Restricted User should not have access to update logs'
//     );
//   }

//   /**
//    * @description : Test Bulk Position Update with changes
//    * @author Swastik Dan | 12-21-2024
//    **/
//   @isTest
//   static void testBulkPositionUpdate() {
//     User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
//     User restrictedUser = CommonTestHelper.findUserByEmail(
//       'restricteduser@user.test'
//     );

//     Test.startTest();

//     System.runAs(adminUser) {
//       List<Position__c> positionList = [
//         SELECT Id, Name
//         FROM Position__c
//         LIMIT 10
//       ];

//       for (Position__c position : positionList) {
//         position.Name = 'Updated Admin';
//       }
//       update positionList;
//     }

//     System.runAs(restrictedUser) {
//       try {
//         List<Position__c> positionList = [
//           SELECT Id, Name
//           FROM Position__c
//           LIMIT 10
//         ];
//         for (Position__c position : positionList) {
//           position.Name = 'Updated Restricted';
//         }
//         update positionList;
//       } catch (Exception e) {
//         System.assertNotEquals(
//           null,
//           e,
//           'Its Inserted candidate with no access'
//         );
//       }
//     }

//     Test.stopTest();

//     List<Position_Update_Log__c> adminLogList = [
//       SELECT Id, Position__c
//       FROM Position_Update_Log__c
//       WHERE CreatedById = :adminUser.Id
//     ];

//     List<Position_Update_Log__c> restrictedLogList = [
//       SELECT Id, Position__c
//       FROM Position_Update_Log__c
//       WHERE CreatedById = :restrictedUser.Id
//     ];

//     System.assertEquals(
//       10,
//       adminLogList.size(),
//       'Correct number of records are not inserted as Admin User'
//     );
//     System.assertEquals(
//       0,
//       restrictedLogList.size(),
//       'Restricted User should not have access to update logs'
//     );
//   }
// }

// /**
//  * @description       : Test class for Position Trigger Handler
//  * @author            : Swastik Dan
//  * @group             :
//  * @last modified on  : 10-01-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/
// @isTest
// public class PositionTriggerTest {
//   @TestSetup
//   static void makeData() {
//     User adminUser = CommonTestHelper.createUserWithProfile(
//       'System Administrator',
//       'adminuser@user.test',
//       'admin'
//     );
//     insert adminUser;

//     List<Candidate__c> candidates = CommonTestHelper.createGenericCandidate(10);
//     insert candidates;

//     List<Position__c> positions = CommonTestHelper.createGenericPosition(10);
//     insert positions;

//     List<Job_Application__c> jobApplications = new List<Job_Application__c>();
//     for (Integer iterator = 0; iterator < candidates.size(); iterator++) {
//       jobApplications.add(
//         new Job_Application__c(
//           Candidate__c = candidates[iterator].Id,
//           Position__c = positions[iterator].Id
//         )
//       );
//     }
//     insert jobApplications;
//   }
//   /**
//    * @description : Test Position Update without changes
//    * @author Swastik Dan | 10-01-2024
//    **/
//   @isTest
//   static void testNoChangePositionUpdate() {
//     User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
//     List<Position__c> positions = [SELECT Id FROM Position__c LIMIT 10];

//     Test.startTest();
//     System.runAs(adminUser) {
//       update positions;
//     }
//     Test.stopTest();

//     List<Position_Update_Log__c> positionUpdateLogs = [
//       SELECT Id
//       FROM Position_Update_Log__c
//     ];

//     System.assertEquals(
//       0,
//       positionUpdateLogs.size(),
//       'Log should not be created for no changes'
//     );
//   }
//   /**
//    * @description : Test Position Insert Trigger to create Position Update Log
//    * @author Swastik Dan | 10-01-2024
//    **/
//   @isTest
//   static void testBulkPositionUpdate() {
//     User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
//     List<Position__c> positions = [SELECT Id, Name FROM Position__c LIMIT 10];

//     for (Position__c position : positions) {
//       position.Name = 'Updated ' + position.Name;
//     }

//     Test.startTest();
//     System.runAs(adminUser) {
//       update positions;
//     }
//     Test.stopTest();

//     List<Position_Update_Log__c> positionUpdateLogs = [
//       SELECT Id, Position__c
//       FROM Position_Update_Log__c
//     ];

//     System.assertEquals(
//       positions.size(),
//       positionUpdateLogs.size(),
//       'Position update logs not created correctly'
//     );
//   }

//   /**
//    * @description : Test Position Update with invalid data
//    * @author Swastik Dan | 10-01-2024
//    **/
//   @isTest
//   static void testInvalidPositionUpdate() {
//     User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
//     Position__c position = new Position__c(Name = null);

//     Test.startTest();
//     try {
//       System.runAs(adminUser) {
//         insert position;
//       }
//     } catch (DmlException e) {
//       System.assert(
//         e.getMessage().contains('Field Name cannot be null'),
//         'Expected a DmlException for null Name'
//       );
//     }
//     Test.stopTest();
//   }

//   /**
//    * @description : Test Deleting Position
//    * @author Swastik Dan | 10-01-2024
//    **/
//   @isTest
//   static void testPositionDelete() {
//     User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
//     Position__c position = new Position__c(Name = 'Position to Delete');
//     insert position;

//     Test.startTest();
//     System.runAs(adminUser) {
//       delete position;
//     }
//     Test.stopTest();

//     List<Position_Update_Log__c> positionUpdateLogs = [
//       SELECT Id
//       FROM Position_Update_Log__c
//     ];

//     System.assertEquals(
//       0,
//       positionUpdateLogs.size(),
//       'Log should not be created upon deletion'
//     );
//   }
// }
