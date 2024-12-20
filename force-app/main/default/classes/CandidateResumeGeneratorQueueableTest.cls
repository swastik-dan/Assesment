/**
 * @description       : Test class for CandidateResumeGeneratorQueueable
 * @last modified on  : 11-27-2024
 * @last modified by  : Swastik Dan
 **/
@isTest
private class CandidateResumeGeneratorQueueableTest {
  @TestSetup
  static void makeData() {
    User adminUser = CommonTestHelper.createUserWithProfile(
      'System Administrator',
      'adminuser@user.test',
      'admin'
    );
    insert adminUser;
    List<Candidate__c> candidates = CommonTestHelper.createGenericCandidate(20);
    insert candidates;
  }

  /**
   * @description :Test method for CandidateResumeGeneratorQueueable
   * @author Swastik Dan | 11-27-2024
   **/
  @isTest
  static void testResumeQueueable() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');

    // Run the test as the admin user
    System.runAs(adminUser) {
      List<Candidate__c> candidates = [
        SELECT Id, First_Name__c
        FROM Candidate__c
      ];

      List<Id> candidateIds = new List<Id>();
      for (Candidate__c candidate : candidates) {
        candidateIds.add(candidate.Id);
      }

      Test.startTest();

      Id jobId = System.enqueueJob(
        new CandidateResumeGeneratorQueueable(candidateIds)
      );

      Test.stopTest();
      System.assertNotEquals(null, jobId, 'job id did not exist');

      List<Attachment> attachments = [
        SELECT Id, ParentId
        FROM Attachment
      ];
      System.assertEquals(
        candidates.size(),
        attachments.size(),
        'Attachments not created for all candidates'
      );
    }
  }
}
