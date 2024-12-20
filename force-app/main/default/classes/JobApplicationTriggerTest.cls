/**
 * @description       : This is a test class for the JobApplicationTriggerHandler class.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-21-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

@isTest
private class JobApplicationTriggerTest {
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

  /**
  * @description : This method tests the resume generation for shortlisted candidates.
  * @author Swastik Dan | 12-21-2024 
  **/
  @isTest
  static void testResumeGeneration() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    User normalUser = CommonTestHelper.findUserByEmail(
      'restricteduser@user.test'
    );

    Test.startTest();
    System.runAs(adminUser) {
      List<Job_Application__c> jobApplicationList = [
        SELECT Id, Candidate__c, Job_Application_Status__c
        FROM Job_Application__c
      ];
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
    }

    System.runAs(normalUser) {
      List<Job_Application__c> jobApplicationList = [
        SELECT Id, Candidate__c, Job_Application_Status__c
        FROM Job_Application__c
      ];
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
      'Attachments not created for all shortlisted candidates'
    );

    System.assertEquals(
      0,
      normalAttachments.size(),
      'Attachments created for restricted user candidates'
    );
  }
}
