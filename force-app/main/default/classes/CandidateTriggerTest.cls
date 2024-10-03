/**
 * @description       : Test class for CandidateTriggerHandler class to test the trigger functionality of Candidate object
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 10-01-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

@isTest
public class CandidateTriggerTest {
  @TestSetup
  static void makeData() {
    User adminUser = CommonTestHelper.createUserWithProfile(
      'System Administrator',
      'adminuser@user.test',
      'admin'
    );
    insert adminUser;

    User profileNormalUser = CommonTestHelper.createUserWithProfile(
      'Standard User',
      'restricteduser@user.test',
      'restric'
    );
    insert profileNormalUser;
  }

  /**
   * @description : Test candidate insert
   * @author Swastik Dan | 09-23-2024
   **/

  @isTest
  static void testCandidateInsert() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    User normalUser = CommonTestHelper.findUserByEmail(
      'restricteduser@user.test'
    );
    Test.startTest();
    System.runAs(adminUser) {
      List<Candidate__c> admincandidates = CommonTestHelper.createGenericCandidate(
        4
      );
      insert as user admincandidates;
    }

    System.runAs(normalUser) {
      try {
        List<Candidate__c> restrictedcandidates = CommonTestHelper.createGenericCandidate(
          4
        );
        insert as user restrictedcandidates;
      } catch (Exception e) {
        System.assertNotEquals(
          null,
          e,
          'Its Inserted candidate with no access'
        );
      }
    }

    Test.stopTest();

    List<Candidate__c> adminCandidates = [
      SELECT Id, Name, Email__c
      FROM Candidate__c
      WHERE CreatedById = :adminUser.Id
      WITH USER_MODE
    ];

    List<Candidate__c> restrictedCandidates = [
      SELECT Id, Name, Email__c
      FROM Candidate__c
      WHERE CreatedById = :normalUser.Id
      WITH USER_MODE
    ];

    System.Assert.areEqual(
      4,
      adminCandidates.size(),
      'Correct number of records are not inserted as Admin User'
    );
    System.Assert.areEqual(
      0,
      restrictedCandidates.size(),
      'Records are inserted with no access'
    );
  }

  /**
   * @description : Test if contact already exists
   * @author Swastik Dan | 09-23-2024
   **/
  @isTest
  static void testIfContactAlreadyExists() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    User normalUser = CommonTestHelper.findUserByEmail(
      'restricteduser@user.test'
    );

    Test.startTest();
    System.runAs(adminUser) {
      List<Contact> contacts = CommonTestHelper.createGenericContact(10, 4);
      insert as user contacts;
      List<Candidate__c> candidates = CommonTestHelper.createGenericCandidate(
        10
      );
      insert as user candidates;
    }

    System.runAs(normalUser) {
      try {
        List<Contact> contacts = CommonTestHelper.createGenericContact(10, 4);
        insert as user contacts;
        List<Candidate__c> candidates = CommonTestHelper.createGenericCandidate(
          10
        );
        insert as user candidates;
      } catch (Exception e) {
        System.assertNotEquals(
          null,
          e,
          'Its Inserted candidate with no access'
        );
      }
    }

    Test.stopTest();

    List<Candidate__c> adminCandidates = [
      SELECT Id, Name, Email__c
      FROM Candidate__c
      WHERE CreatedById = :adminUser.Id
      WITH USER_MODE
    ];

    List<Candidate__c> restrictedCandidates = [
      SELECT Id, Name, Email__c
      FROM Candidate__c
      WHERE CreatedById = :normalUser.Id
      WITH USER_MODE
    ];

    System.Assert.areEqual(
      10,
      adminCandidates.size(),
      'Correct number of records are not inserted as Admin User'
    );
    System.Assert.areEqual(
      0,
      restrictedCandidates.size(),
      'Records are inserted with no access'
    );
  }
}
