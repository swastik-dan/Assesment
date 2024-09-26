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
    Profile profileInst = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Cant Access Position'
    ];

    User user = new User();
    user.FirstName = 'TestOne';
    user.LastName = 'User';
    user.Alias = 'tuserone';
    user.Email = 'testuserone@testuser.com';
    user.Username = 'testuserone@testuser.com';
    user.CommunityNickname = 'tuserone';
    user.ProfileId = profileInst.Id;
    user.TimeZoneSidKey = 'America/Los_Angeles';
    user.LocaleSidKey = 'en_US';
    user.EmailEncodingKey = 'UTF-8';
    user.LanguageLocaleKey = 'en_US';

    insert as user user;

    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Candidate',
      Email__c = 'testcandidate@gmail.com'
    );
    insert as user candidate;

    Position__c position = new Position__c(
      Name = 'Test Position',
      Status__c = 'New Position',
      Type__c = 'Full Time',
      Min_Pay__c = 100000,
      Max_Pay__c = 150000
    );

    insert as user position;

    Job_Application__c jobApplication = new Job_Application__c(
      Candidate__c = candidate.Id,
      Position__c = position.Id
    );

    insert as user jobApplication;

    Position__c positionToUpdate = [
      SELECT Id, Name
      FROM Position__c
      WHERE Id = :position.Id
    ];

    positionToUpdate.Name = 'Updated Position';
    update as user positionToUpdate;
  }
  // * https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/platform_events_test_deliver.htm
  @isTest
  static void testPositionUpdate() {
    List<Case> positionUpdateEvents = [
      SELECT Id
      FROM Case
      WITH USER_MODE
    ];

    System.assertEquals(
      1,
      positionUpdateEvents.size(),
      'Position update event not created'
    );

    User user = [SELECT Id FROM User WHERE Email = 'testuserone@testuser.com'];
    System.runAs(user) {
      Position__c position = [
        SELECT Id, Name
        FROM Position__c
        WHERE Name = 'Updated Position'
      ];

      position.Name = 'Updated Position 2';
      update as user position;

      List<Case> positionLogsUser = [
        SELECT Id
        FROM Case
        WITH USER_MODE
      ];

      System.assertEquals(0, positionLogsUser.size(), 'Position log created');
    }

  }
}
// /**
//  * @description       : Test class for PositionTrigger
//  * @author            : Swastik Dan
//  * @last modified on  : 09-25-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/
// @isTest
// public class PositionTriggerTest {
//   /**
//    * @description      : Test setup data creation
//    * @author           : Swastik Dan | 09-24-2024
//    **/
//   @TestSetup
//   static void makeData() {
//     // Create test User
//     Profile profileInst = [
//       SELECT Id
//       FROM Profile
//       WHERE Name = 'Cant Access Position'
//     ];

//     User user = new User();
//     user.FirstName = 'TestOne';
//     user.LastName = 'User';
//     user.Alias = 'tuserone';
//     user.Email = 'testuserone@testuser.com';
//     user.Username = 'testuserone@testuser.com';
//     user.CommunityNickname = 'tuserone';
//     user.ProfileId = profileInst.Id;
//     user.TimeZoneSidKey = 'America/Los_Angeles';
//     user.LocaleSidKey = 'en_US';
//     user.EmailEncodingKey = 'UTF-8';
//     user.LanguageLocaleKey = 'en_US';

//     insert as user user;

//     // Create test Candidate record
//     Candidate__c candidateInst = new Candidate__c(
//       First_Name__c = 'Test',
//       Last_Name__c = 'Candidate',
//       Email__c = 'testcandidate@gmail.com'
//     );
//     insert as user candidateInst;

//     // Create test Position record
//     Position__c positionInst = new Position__c(
//       Name = 'Test Position',
//       Status__c = 'New Position',
//       Type__c = 'Full Time',
//       Min_Pay__c = 100000,
//       Max_Pay__c = 150000
//     );
//     insert as user positionInst;

//     // Create Job Application record linked to Candidate and Position
//     Job_Application__c jobApplicationInst = new Job_Application__c(
//       Candidate__c = candidateInst.Id,
//       Position__c = positionInst.Id
//     );
//     insert as user jobApplicationInst;

//     //Query and update Position record
//     Position__c positionToUpdate = [
//       SELECT Id, Name
//       FROM Position__c
//       WHERE Id = :positionInst.Id
//     ];

//     positionToUpdate.Name = 'Updated Position';
//     update as user positionToUpdate; // Fixed syntax issue
//   }

//   /**
//    * @description      : Test Position update and log creation
//    * @author           : Swastik Dan | 09-24-2024
//    **/
//   @isTest
//   static void testPositionUpdate() {
//     User user = [SELECT Id FROM User WHERE Email = 'testuserone@testuser.com'];
//     Test.startTest();

//     // Query updated position
//     List<Position__c> updatedPositions = [
//       SELECT Id, Name
//       FROM Position__c
//       WHERE Name = 'Updated Position'
//     ];

//     // Query Position Update Log
//     List<Position_Update_Log__c> positionLogs = [
//       SELECT Id, Position__c
//       FROM Position_Update_Log__c
//       WHERE Position__c = :updatedPositions[0].Id
//     ];

//     // Assert that the Position was updated and the log was created
//     System.assertEquals(1, updatedPositions.size(), 'Position not updated');
//     System.assertEquals(1, positionLogs.size(), 'Position log not created');

//     System.runAs(user) {
//       Position__c updatedPositionsUser = [
//         SELECT Id, Name
//         FROM Position__c
//         WHERE Name = 'Updated Position'
//       ];

//       updatedPositionsUser.Name = 'Updated Position 2';

//       update as user updatedPositionsUser;

//       List<Position__c> updatedPositionsUserTwo = [
//         SELECT Id, Name
//         FROM Position__c
//         WHERE Name = 'Updated Position 2'
//       ];

//       // Query Position Update Log
//       List<Position_Update_Log__c> positionLogsUser = [
//         SELECT Id, Position__c
//         FROM Position_Update_Log__c
//         WHERE Position__c = :updatedPositionsUserTwo[0].Id
//       ];

//       // check for the dml exception  insted of checking the size of the list becaus e its should thow a dml exception
//     }
//     Test.stopTest();
//   }
// }
