/**
 * @description       : Test class for CandidateTriggerHandler class to test the trigger functionality of Candidate object
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-26-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

@isTest
public class CandidateTriggerTest {
  @TestSetup
  static void makeData() {
    User adminUser = TestHelper.createUserWithProfile(
      'System Administrator',
      'adminuser@user.test',
      'admin'
    );
    insert adminUser;

    User profileNormalUser = TestHelper.createUserWithProfile(
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
    User adminUser = [
      SELECT Id
      FROM User
      WHERE Email = 'adminuser@user.test'
    ];
    User normalUser = [
      SELECT Id
      FROM User
      WHERE Email = 'restricteduser@user.test'
    ];
    Test.startTest();
    System.runAs(adminUser) {
      List<Candidate__c> admincandidates = TestHelper.createGenericCandidate(4);
      insert as user admincandidates;
    }

    System.runAs(normalUser) {
      try {
        List<Candidate__c> restrictedcandidates = TestHelper.createGenericCandidate(
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

    System.Assert.areEqual(4, adminCandidates.size(), 'Admin User');
    System.Assert.areEqual(0, restrictedCandidates.size(), 'Normal User');
  }

  /**
   * @description : Test if contact already exists
   * @author Swastik Dan | 09-23-2024
   **/
  @isTest
  static void testIfContactAlreadyExists() {
    User adminUser = [
      SELECT Id
      FROM User
      WHERE Email = 'adminuser@user.test'
    ];
    User normalUser = [
      SELECT Id
      FROM User
      WHERE Email = 'restricteduser@user.test'
    ];

    Test.startTest();
    System.runAs(adminUser) {
      List<Contact> contacts = TestHelper.createGenericContact(10, 4);
      insert as user contacts;
      List<Candidate__c> candidates = TestHelper.createGenericCandidate(10);
      insert as user candidates;
    }

    System.runAs(normalUser) {
      try {
        List<Contact> contacts = TestHelper.createGenericContact(10, 4);
        insert as user contacts;
        List<Candidate__c> candidates = TestHelper.createGenericCandidate(10);
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

    System.Assert.areEqual(10, adminCandidates.size(), 'Admin User');
    System.Assert.areEqual(0, restrictedCandidates.size(), 'Normal User');
  }
}
