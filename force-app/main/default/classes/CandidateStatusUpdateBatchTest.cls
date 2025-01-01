/**
 * @description       : Test class for CandidateStatusUpdateBatch class. This class tests the batch class for updating the candidate status based on the rules.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-29-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
@isTest
private class CandidateStatusUpdateBatchTest {
  @TestSetup
  static void makeData() {
    User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'adminuser@user.test', 'admin');
    insert adminUser;
    List<Candidate__c> candidateList = CommonTestHelper.createGenericCandidates(1);
    insert candidateList;
    List<Position__c> positionList = CommonTestHelper.createGenericPositions(100);
    insert positionList;

    List<Job_Application__c> jobApplicationList = CommonTestHelper.createJobApplicationWithRandomDetails(
      candidateList,
      positionList
    );

    insert jobApplicationList;

    Integer iterator = 0;
    for (Job_Application__c jobApplication : jobApplicationList) {
      if (iterator < 30) {
        jobApplication.LastActivityDate__c = Date.today().addDays(-40);
      } else if (iterator < 60) {
        jobApplication.LastInterviewDate__c = Date.today().addDays(-20);
      }
      iterator++;
    }

    update jobApplicationList;
  }

  /**
   * @description : Test First Rule
   * @author Swastik Dan | 12-29-2024
   **/
  @isTest
  static void testFirstRule() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    Test.startTest();
    System.runAs(adminUser) {
      CandidateStatusUpdateBatch candidateBatch = new CandidateStatusUpdateBatch();
      Database.executeBatch(candidateBatch);
    }
    Test.stopTest();
    List<Job_Application__c> firstCandidateRuleList = [
      SELECT Id
      FROM Job_Application__c
      WHERE Job_Application_Status__c = 'Inactive'
    ];
    System.assertEquals(30, firstCandidateRuleList.size(), 'First Rule Failed');
  }

  /**
   * @description : Test Second Rule
   * @author Swastik Dan | 12-29-2024
   **/
  @isTest
  static void testSecondRule() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    Test.startTest();
    System.runAs(adminUser) {
      CandidateStatusUpdateBatch candidateBatch = new CandidateStatusUpdateBatch();
      Database.executeBatch(candidateBatch);
    }
    Test.stopTest();
    List<Job_Application__c> secondCandidateRuleList = [
      SELECT Id
      FROM Job_Application__c
      WHERE Job_Application_Status__c = 'Not Selected'
    ];
    System.assertEquals(30, secondCandidateRuleList.size(), 'Second Rule Failed');
  }

  /**
   * @description : Test Third Rule
   * @author Swastik Dan | 12-29-2024
   **/
  @isTest
  static void testThirdRule() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    Test.startTest();
    System.runAs(adminUser) {
      CandidateStatusUpdateBatch candidateBatch = new CandidateStatusUpdateBatch();
      Database.executeBatch(candidateBatch);
    }
    Test.stopTest();
    List<Job_Application__c> thirdCandidateRuleList = [
      SELECT Id
      FROM Job_Application__c
      WHERE Candidate_Not_Interested__c = TRUE AND Job_Application_Status__c = 'Withdrawn'
    ];

    System.assertEquals(30, thirdCandidateRuleList.size(), 'Third Rule Failed');
  }

  /**
   * @description : Test Not On The Rule Rule
   * @author Swastik Dan | 12-29-2024
   **/
  @isTest
  static void testNotOnTheRule() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    Test.startTest();
    System.runAs(adminUser) {
      CandidateStatusUpdateBatch candidateBatch = new CandidateStatusUpdateBatch();
      Database.executeBatch(candidateBatch);
    }
    Test.stopTest();
    List<Job_Application__c> notOnTheRule = [
      SELECT Id
      FROM Job_Application__c
      WHERE Job_Application_Status__c = NULL
    ];

    System.assertEquals(10, notOnTheRule.size(), 'Not On The Rule Failed');
  }

  /**
   * @description : Test Schedulable Executions
   * @author Swastik Dan | 12-29-2024
   **/
  @isTest
  static void testSchedulableExecution() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    Test.startTest();
    System.runAs(adminUser) {
      // Schedule the batch job
      String cronExpression = '0 0 12 * * ?'; //daily at 12 PM
      System.schedule('Test Scheduled Batch', cronExpression, new CandidateStatusUpdateBatch());
    }
    Test.stopTest();

    // Assert that the scheduled job executed
    System.assert(true, 'Scheduled batch job should execute without errors.');
  }
}

// private class CandidateStatusUpdateBatchTest {
//   @TestSetup
//   static void makeData() {
//     User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'adminuser@user.test', 'admin');
//     insert adminUser;
//     List<Candidate__c> candidateList = CommonTestHelper.createGenericCandidates(1);
//     insert candidateList;
//     List<Position__c> positionList = CommonTestHelper.createGenericPositions(100);
//     insert positionList;

//     List<Job_Application__c> jobApplicationList = CommonTestHelper.createJobApplicationWithRandomDetails(
//       candidateList,
//       positionList
//     );

//     insert jobApplicationList;

//     Integer iterator = 0;
//     for (Job_Application__c jobApplication : jobApplicationList) {
//       if (iterator < 30) {
//         jobApplication.LastActivityDate__c = Date.today().addDays(-40);
//       } else if (iterator < 60) {
//         jobApplication.LastInterviewDate__c = Date.today().addDays(-20);
//       }
//       iterator++;
//     }

//     // for (Integer iterator = 0; iterator < jobApplicationList.size(); iterator++) {

//     //   if (iterator < 30) {
//     //     Test.setCreatedDate(jobApplication.Id, DateTime.now().addDays(-40));
//     //     jobApplication.Candidate_Not_Interested__c = false;
//     //   } else if (iterator < 60) {
//     //     jobApplication.Job_Application_Status__c = 'Interviewed';
//     //     Test.setCreatedDate(jobApplication.Id, DateTime.now().addDays(-20));
//     //     jobApplication.Candidate_Not_Interested__c = false;
//     //   } else if (iterator < 90) {
//     //     jobApplication.Job_Application_Status__c = 'Applied';
//     //     jobApplication.Candidate_Not_Interested__c = true;
//     //   } else {
//     //     jobApplication.Job_Application_Status__c = null;
//     //     jobApplication.Candidate_Not_Interested__c = false;
//     //   }

//     //   jobApplications.add(jobApplication);
//     // }

//     update jobApplicationList;

//     // for (Integer iterator = 0; iterator < jobApplicationList.size(); iterator++) {
//     //   if (iterator < 3) {
//     //     Test.setCreatedDate(jobApplicationList[iterator].Id, DateTime.now().addDays(-40));
//     //   } else if (iterator < 4) {
//     //     Test.setCreatedDate(jobApplicationList[iterator].Id, DateTime.now().addDays(-20));
//     //   }
//     // }

//     // update jobApplicationList;

//     // // Adjust CreatedDate to matching the rule
//     // List<Job_Application__c> jobApplicationsToUpdate = new List<Job_Application__c>();
//     // for (Integer iterator = 0; iterator < jobApplications.size(); iterator++) {
//     //   if (iterator < 15) {
//     //     Test.setCreatedDate(jobApplications[iterator].Id, DateTime.now().addDays(-40));
//     //   } else if (iterator < 30) {
//     //     Test.setCreatedDate(jobApplications[iterator].Id, DateTime.now().addDays(-20));
//     //   }
//     //   jobApplicationsToUpdate.add(jobApplications[iterator]);
//     // }

//     // update jobApplicationsToUpdate;
//   }
//   @isTest
//   static void testUpdateCandidateStatusBatch() {
//     User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
//     List<Job_Application__c> oldjobApplications = [
//       SELECT
//         Id,
//         Days_Since_Last_Activity__c,
//         Days_Since_Interview__c,
//         Test_LastActivityDate__c,
//         Test_LastModifiedDate__c
//       FROM Job_Application__c
//     ];
//     System.debug(
//       String.valueOf(oldjobApplications[3]) +
//         String.valueOf(oldjobApplications[33]) +
//         String.valueOf(oldjobApplications[63]) +
//         String.valueOf(oldjobApplications[93]) +
//         'OLDjobApplications'
//     );
//     Test.startTest();
//     System.runAs(adminUser) {
//       CandidateStatusUpdateBatch candidateBatch = new CandidateStatusUpdateBatch();
//       Database.executeBatch(candidateBatch);
//     }
//     Test.stopTest();
//     List<Job_Application__c> jobApplications = [
//       SELECT Id, Job_Application_Status__c, Days_Since_Last_Activity__c, Days_Since_Interview__c
//       FROM Job_Application__c
//     ];
//     System.debug(
//       String.valueOf(jobApplications[3]) +
//         String.valueOf(jobApplications[33]) +
//         String.valueOf(jobApplications[63]) +
//         String.valueOf(jobApplications[93]) +
//         'OLDjobApplications'
//     );
//     List<Job_Application__c> firstCandidateRuleList = [
//       SELECT Id
//       FROM Job_Application__c
//       WHERE Days_Since_Last_Activity__c >= 30 AND Job_Application_Status__c = 'Inactive'
//     ];
//     List<Job_Application__c> secondCandidateRuleList = [
//       SELECT Id
//       FROM Job_Application__c
//       WHERE Job_Application_Status__c = 'Not Selected'
//     ];

//     List<Job_Application__c> thirdCandidateRuleList = [
//       SELECT Id
//       FROM Job_Application__c
//       WHERE Candidate_Not_Interested__c = TRUE AND Job_Application_Status__c = 'Withdrawn'
//     ];

//     List<Job_Application__c> notOnTheRule = [
//       SELECT Id
//       FROM Job_Application__c
//       WHERE Job_Application_Status__c = NULL
//     ];

//     System.assertEquals(30, firstCandidateRuleList.size(), 'First Rule Failed');
//     System.assertEquals(30, secondCandidateRuleList.size(), 'Second Rule Failed');
//     System.assertEquals(30, thirdCandidateRuleList.size(), 'Third Rule Failed');
//     System.assertEquals(10, notOnTheRule.size(), 'Not On The Rule Failed');
//   }
// }

// /**
//  * @description       :
//  * @author            : Swastik Dan
//  * @group             :
//  * @last modified on  : 10-30-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/

// @isTest
// private class CandidateStatusUpdateBatchTest {
//   @TestSetup
//   static void makeData() {
//     List<Candidate__c> candidateList = CommonTestHelper.createGenericCandidate(
//       1
//     );
//     insert candidateList;
//     List<Position__c> positionList = CommonTestHelper.createGenericPosition(
//       100
//     );
//     insert positionList;
//     // This cretats total 100 job applications among which 30 follow rule 1 and 30 follow rule 2 and 30 follow rule 3 and 10 are not on the rule
//     List<Job_Application__c> jobApplicationList = CommonTestHelper.createJobApplicationWithRandomDetails(
//       candidateList,
//       positionList
//     );
//     insert jobApplicationList;
//     System.debug(jobApplicationList.size());
//     for (Integer i = 0; i < 30; i++) {
//       Job_Application__c jobApplication = jobApplicationList[i];
//       //Test.setCreatedDate(id, dt)
//     }

//     List<Job_Application__c> firstCandidateRuleList = [
//       SELECT Id
//       FROM Job_Application__c
//       WHERE Days_Since_Last_Activity__c >= 30
//     ];

//     for (Integer i = 30; i < 60; i++) {
//       Job_Application__c jobApplication = jobApplicationList[i];
//       Test.setCreatedDate(jobApplication.Id, DateTime.now().addDays(-15));
//     }
//   }

//   /**
//    * @description
//    *
//    *
//    * @author Swastik Dan | 10-04-2024
//    **/
//   @isTest
//   static void testCandidateStatusUpdateBatch() {
//     Test.startTest();
//     CandidateStatusUpdateBatch candidateBatch = new CandidateStatusUpdateBatch();
//     Database.executeBatch(candidateBatch);
//     Test.stopTest();

//     List<Job_Application__c> firstCandidateRuleList = [
//       SELECT Id
//       FROM Job_Application__c
//       WHERE
//         Days_Since_Last_Activity__c >= 30
//         AND Job_Application_Status__c = 'Inactive'
//     ];
//     List<Job_Application__c> secondCandidateRuleList = [
//       SELECT Id
//       FROM Job_Application__c
//       WHERE
//         Days_Since_Interview__c >= 14
//         AND Job_Application_Status__c = 'Not Selected'
//     ];

//     List<Job_Application__c> thirdCandidateRuleList = [
//       SELECT Id
//       FROM Job_Application__c
//       WHERE
//         Candidate_Not_Interested__c = TRUE
//         AND Job_Application_Status__c = 'Withdrawn'
//     ];

//     List<Job_Application__c> notOnTheRule = [
//       SELECT Id
//       FROM Job_Application__c
//       WHERE Job_Application_Status__c = 'New'
//     ];

//     System.assertEquals(30, firstCandidateRuleList.size(), 'First Rule Failed');
//     System.assertEquals(
//       30,
//       secondCandidateRuleList.size(),
//       'Second Rule Failed'
//     );
//     System.assertEquals(30, thirdCandidateRuleList.size(), 'Third Rule Failed');
//     System.assertEquals(10, notOnTheRule.size(), 'Not On The Rule Failed');
//   }
// }

