/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 10-30-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

@isTest
private class CandidateStatusUpdateBatchTest {
  @TestSetup
  static void makeData() {
    List<Candidate__c> candidateList = CommonTestHelper.createGenericCandidate(
      1
    );
    insert candidateList;
    List<Position__c> positionList = CommonTestHelper.createGenericPosition(
      100
    );
    insert positionList;
    // This cretats total 100 job applications among which 30 follow rule 1 and 30 follow rule 2 and 30 follow rule 3 and 10 are not on the rule
    List<Job_Application__c> jobApplicationList = CommonTestHelper.createJobApplicationWithRandomDetails(
      candidateList,
      positionList
    );
    insert jobApplicationList;
    System.debug(jobApplicationList.size());
    for (Integer i = 0; i < 30; i++) {
      Job_Application__c jobApplication = jobApplicationList[i];
      //Test.setCreatedDate(id, dt)
    }

    List<Job_Application__c> firstCandidateRuleList = [
      SELECT Id
      FROM Job_Application__c
      WHERE Days_Since_Last_Activity__c >= 30
    ];

    for (Integer i = 30; i < 60; i++) {
      Job_Application__c jobApplication = jobApplicationList[i];
      Test.setCreatedDate(jobApplication.Id, DateTime.now().addDays(-15));
    }
  }

  /**
   * @description
   *
   *
   * @author Swastik Dan | 10-04-2024
   **/
  @isTest
  static void testCandidateStatusUpdateBatch() {
    Test.startTest();
    CandidateStatusUpdateBatch candidateBatch = new CandidateStatusUpdateBatch();
    Database.executeBatch(candidateBatch);
    Test.stopTest();

    List<Job_Application__c> firstCandidateRuleList = [
      SELECT Id
      FROM Job_Application__c
      WHERE
        Days_Since_Last_Activity__c >= 30
        AND Job_Application_Status__c = 'Inactive'
    ];
    List<Job_Application__c> secondCandidateRuleList = [
      SELECT Id
      FROM Job_Application__c
      WHERE
        Days_Since_Interview__c >= 14
        AND Job_Application_Status__c = 'Not Selected'
    ];

    List<Job_Application__c> thirdCandidateRuleList = [
      SELECT Id
      FROM Job_Application__c
      WHERE
        Candidate_Not_Interested__c = TRUE
        AND Job_Application_Status__c = 'Withdrawn'
    ];

    List<Job_Application__c> notOnTheRule = [
      SELECT Id
      FROM Job_Application__c
      WHERE Job_Application_Status__c = 'New'
    ];

    System.assertEquals(30, firstCandidateRuleList.size(), 'First Rule Failed');
    System.assertEquals(
      30,
      secondCandidateRuleList.size(),
      'Second Rule Failed'
    );
    System.assertEquals(30, thirdCandidateRuleList.size(), 'Third Rule Failed');
    System.assertEquals(10, notOnTheRule.size(), 'Not On The Rule Failed');
  }
}
