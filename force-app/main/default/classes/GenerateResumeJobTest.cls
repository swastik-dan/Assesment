/**
 * @description       :  This is a test class for GenerateResumeJob class
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-21-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

@isTest
private class GenerateResumeJobTest {
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

    List<Candidate__c> candidates = CommonTestHelper.createGenericCandidate(10);
    insert candidates;
  }

  /**
  * @description : Test method to test the generateResumeJob method 
  * @author Swastik Dan | 12-21-2024 
  **/
  @isTest
  static void testGenerateResumeJob() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    User normalUser = CommonTestHelper.findUserByEmail(
      'restricteduser@user.test'
    );

    Test.startTest();
    System.runAs(adminUser) {
      List<Candidate__c> candidates = [
        SELECT Id, First_Name__c
        FROM Candidate__c
      ];

      List<Id> candidateIds = new List<Id>();
      for (Candidate__c candidate : candidates) {
        candidateIds.add(candidate.Id);
      }
      GenerateResumeJob.generateResume(candidateIds);
    }
    System.runAs(normalUser) {
      List<Candidate__c> candidates = [
        SELECT Id, First_Name__c
        FROM Candidate__c
      ];

      List<Id> candidateIds = new List<Id>();
      for (Candidate__c candidate : candidates) {
        candidateIds.add(candidate.Id);
      }
      GenerateResumeJob.generateResume(candidateIds);
    }
    Test.stopTest();

    List<Attachment> adminAttachments = [
      SELECT Id, ParentId
      FROM Attachment
      WHERE CreatedById = :adminUser.Id
    ];

    List<Attachment> normalAttachments = [
      SELECT Id, ParentId
      FROM Attachment
      WHERE CreatedById = :normalUser.Id
    ];

    System.assertEquals(
      10,
      adminAttachments.size(),
      'Attachments not created for all candidates'
    );

    System.assertEquals(
      0,
      normalAttachments.size(),
      'Attachments created for restricted user candidates'
    );
  }
}
