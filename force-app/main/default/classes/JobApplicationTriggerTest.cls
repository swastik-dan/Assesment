/**
 * @description       : This is a test class for the JobApplicationTriggerHandler class.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 11-27-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

@isTest
private class JobApplicationTriggerTest {
  @TestSetup
  static void makeData() {
    User adminUserObj = CommonTestHelper.createUserWithProfile(
      'System Administrator',
      'adminuser@user.test',
      'admin'
    );
    insert adminUserObj;

    List<Candidate__c> candidateList = CommonTestHelper.createGenericCandidate(
      20
    );
    insert candidateList;
    List<Position__c> positionList = CommonTestHelper.createGenericPosition(20);
    insert positionList;
    List<Job_Application__c> jobApplicationList = CommonTestHelper.createGenericJobApplication(
      candidateList,
      positionList
    );

    insert jobApplicationList;
  }

  @isTest
  static void testResumeGeneration() {
    User adminUserObj = CommonTestHelper.findUserByEmail('adminuser@user.test');

    System.runAs(adminUserObj) {
      List<Job_Application__c> jobApplicationList = [
        SELECT Id, Candidate__c, Job_Application_Status__c
        FROM Job_Application__c
      ];
      test.startTest();
      Integer counter = 0;
      for (Job_Application__c jobApplication : jobApplicationList) {
        if (counter < 10) {
          jobApplication.Job_Application_Status__c = 'Shortlisted';
          counter++;
        } else {
          break;
        }
      }

      update jobApplicationList;

      Test.stopTest();

      List<Attachment> attachmentList = [
        SELECT Id, ParentId
        FROM Attachment
      ];

      System.assertEquals(
        counter,
        attachmentList.size(),
        'Attachments not created for all shortlisted candidates'
      );
    }
  }
}
