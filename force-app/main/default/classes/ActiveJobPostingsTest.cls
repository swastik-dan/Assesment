/**
 * @description       : Test class for ActiveJobPostings class to test the active job posting functionalitys
 * @group             :
 * @last modified on  : 12-22-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

@isTest
private class ActiveJobPostingsTest {
  @TestSetup
  static void makeData() {
    User adminUser = CommonTestHelper.createUserWithProfile('System Administrator', 'adminuser@user.test', 'admin');
    insert adminUser;
    Employment_Website__c employmentWebsite = CommonTestHelper.createSingleGenericEmploymentWebsite();
    insert employmentWebsite;

    Position__c position = CommonTestHelper.createSingleGenericPosition();
    insert position;

    List<Job_Posting__c> jobPostingList = CommonTestHelper.createGenericJobPostings(
      employmentWebsite.Id,
      position.Id,
      10
    );
    insert jobPostingList;
  }

  /**
   * @description : Test method to get active job postings
   * @author Swastik Dan | 09-30-2024
   **/
  @isTest
  static void testGetActiveJobPostings() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    System.runAs(adminUser) {
      Test.startTest();
      List<Job_Posting__c> jobPostings = ActiveJobPostingDataHandler.getActiveJobPostings('Department 1', null, null);
      Test.stopTest();
      System.assertEquals(1, jobPostings.size(), 'Expected 1 job posting for Department 1');
    }
  }

  /**
   * @description : Test method to get active job postings with dates
   * @author Swastik Dan | 09-30-2024
   **/
  @isTest
  static void testGetActiveJobPostingsWithDates() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    System.runAs(adminUser) {
      Test.startTest();

      // Set up test data
      Date today = Date.today();
      Date startDate = today.addDays(-5);
      Date endDate = today.addDays(5);

      String startDateString = CommonTestHelper.formatDate(startDate);
      String endDateString = CommonTestHelper.formatDate(endDate);

      // Call the method with string dates
      List<Job_Posting__c> jobPostings = ActiveJobPostingDataHandler.getActiveJobPostings(
        'Department 1',
        startDateString,
        endDateString
      );

      Test.stopTest();

      // Validate the results
      System.assertEquals(1, jobPostings.size(), 'Expected 1 job posting for Department 1 within date range');
    }
  }

  /**
   * @description : Test method to get active job postings with no filters applied
   * @author Swastik Dan | 09-30-2024
   **/
  @isTest
  static void testGetActiveJobPostingsWithNothing() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    System.runAs(adminUser) {
      Test.startTest();
      List<Job_Posting__c> jobPostings = ActiveJobPostingDataHandler.getActiveJobPostings(null, null, null);
      Test.stopTest();
      System.assertEquals(10, jobPostings.size(), 'Expected 10 job postings with no filters');
    }
  }

  /**
   * @description : Test method to get active job postings with invalid dates
   * @author Swastik Dan | 09-30-2024
   **/
  @isTest
  static void testGetActiveJobPostingsWithInvalidDates() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    System.runAs(adminUser) {
      Test.startTest();
      List<Job_Posting__c> jobPostings = ActiveJobPostingDataHandler.getActiveJobPostings(
        'Department 1',
        '2028-10-01',
        '2029-10-31'
      );
      Test.stopTest();
      System.assertEquals(0, jobPostings.size(), 'Expected 0 job postings for future date range');
    }
  }

  /**
   * @description : Test method to get active job postings with invalid departments
   * @author Swastik Dan | 09-30-2024
   **/
  @isTest
  static void testGetActiveJobPostingsWithInvalidDepartment() {
    User adminUser = CommonTestHelper.findUserByEmail('adminuser@user.test');
    System.runAs(adminUser) {
      Test.startTest();
      List<Job_Posting__c> jobPostings = ActiveJobPostingDataHandler.getActiveJobPostings('Department 11', null, null);
      Test.stopTest();
      System.assertEquals(0, jobPostings.size(), 'Expected 0 job postings for non-existent department');
    }
  }
}

// /**
//  * @description       : Test class for ActiveJobPostings class to test the active job posting functionalitys
//  * @group             :
//  * @last modified on  : 12-21-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/

// @isTest
// private class ActiveJobPostingsTest {
//   @TestSetup
//   static void makeData() {
//     User adminUser = CommonTestHelper.createUserWithProfile(
//       'System Administrator',
//       'adminuser@user.test',
//       'admin'
//     );
//     insert adminUser;

//     User profileRestrictedUser = CommonTestHelper.createUserWithProfile(
//       'Standard Employee',
//       'restricteduser@user.test',
//       'restric'
//     );
//     insert profileRestrictedUser;

//     Employment_Website__c employmentWebsite = new Employment_Website__c(
//       Name = 'Test Employment Website',
//       Web_Address__c = 'https://www.test.com',
//       Maximum_Budget__c = 1000,
//       Price_Per_Post__c = 100
//     );
//     insert employmentWebsite;

//     Position__c position = new Position__c(
//       Name = 'Test Position',
//       Status__c = 'New Position',
//       Type__c = 'Full Time',
//       Min_Pay__c = 100000,
//       Max_Pay__c = 150000
//     );
//     insert position;

//     List<Job_Posting__c> jobPostingList = new List<Job_Posting__c>();

//     for (Integer iterable = 0; iterable < 10; iterable++) {
//       Job_Posting__c jobPosting = new Job_Posting__c(
//         Job_Name__c = 'Job Posting ' + iterable,
//         Department__c = 'Department ' + iterable,
//         Active__c = true,
//         Employment_Website__c = employmentWebsite.Id,
//         Position__c = position.Id
//       );
//       jobPostingList.add(jobPosting);
//     }

//     insert jobPostingList;
//   }

//   /**
//    * @description : Test method to get active job postings
//    * @author Swastik Dan | 09-30-2024
//    **/
//   @isTest
//   static void testGetActiveJobPostings() {
//     User adminUser = [
//       SELECT Id
//       FROM User
//       WHERE Email = 'adminuser@user.test'
//       LIMIT 1
//     ];
//     System.runAs(adminUser) {
//       Test.startTest();
//       List<Job_Posting__c> jobPostings = ActiveJobPostingDataHandler.getActiveJobPostings(
//         'Department 1',
//         null,
//         null
//       );
//       Test.stopTest();
//       System.assertEquals(
//         1,
//         jobPostings.size(),
//         'Expected 1 job posting for Department 1'
//       );
//     }
//   }

//   /**
//    * @description : Test method to get active job postings with dates
//    * @author Swastik Dan | 09-30-2024
//    **/
//   @isTest
//   static void testGetActiveJobPostingsWithDates() {
//     User adminUser = [
//       SELECT Id
//       FROM User
//       WHERE Email = 'adminuser@user.test'
//       LIMIT 1
//     ];
//     System.runAs(adminUser) {
//       Test.startTest();

//       // Set up test data
//       Date today = Date.today();
//       Date startDate = today.addDays(-5);
//       Date endDate = today.addDays(5);

//       String startDateString = CommonTestHelper.formatDate(startDate);
//       String endDateString = CommonTestHelper.formatDate(endDate);

//       // Call the method with string dates
//       List<Job_Posting__c> jobPostings = ActiveJobPostingDataHandler.getActiveJobPostings(
//         'Department 1',
//         startDateString,
//         endDateString
//       );

//       Test.stopTest();

//       // Validate the results
//       System.assertEquals(
//         1,
//         jobPostings.size(),
//         'Expected 1 job posting for Department 1 within date range'
//       );
//     }
//   }

//   /**
//    * @description : Test method to get active job postings with no filters applied
//    * @author Swastik Dan | 09-30-2024
//    **/
//   @isTest
//   static void testGetActiveJobPostingsWithNothing() {
//     User adminUser = [
//       SELECT Id
//       FROM User
//       WHERE Email = 'adminuser@user.test'
//       LIMIT 1
//     ];
//     System.runAs(adminUser) {
//       Test.startTest();
//       List<Job_Posting__c> jobPostings = ActiveJobPostingDataHandler.getActiveJobPostings(
//         null,
//         null,
//         null
//       );
//       Test.stopTest();
//       System.assertEquals(
//         10,
//         jobPostings.size(),
//         'Expected 10 job postings with no filters'
//       );
//     }
//   }

//   /**
//    * @description : Test method to get active job postings with invalid dates
//    * @author Swastik Dan | 09-30-2024
//    **/
//   @isTest
//   static void testGetActiveJobPostingsWithInvalidDates() {
//     User adminUser = [
//       SELECT Id
//       FROM User
//       WHERE Email = 'adminuser@user.test'
//       LIMIT 1
//     ];
//     System.runAs(adminUser) {
//       Test.startTest();
//       List<Job_Posting__c> jobPostings = ActiveJobPostingDataHandler.getActiveJobPostings(
//         'Department 1',
//         '2028-10-01',
//         '2029-10-31'
//       );
//       Test.stopTest();
//       System.assertEquals(
//         0,
//         jobPostings.size(),
//         'Expected 0 job postings for future date range'
//       );
//     }
//   }

//   /**
//    * @description : Test method to get active job postings with invalid departments
//    * @author Swastik Dan | 09-30-2024
//    **/
//   @isTest
//   static void testGetActiveJobPostingsWithInvalidDepartment() {
//     User adminUser = [
//       SELECT Id
//       FROM User
//       WHERE Email = 'adminuser@user.test'
//       LIMIT 1
//     ];
//     System.runAs(adminUser) {
//       Test.startTest();
//       List<Job_Posting__c> jobPostings = ActiveJobPostingDataHandler.getActiveJobPostings(
//         'Department 11',
//         null,
//         null
//       );
//       Test.stopTest();
//       System.assertEquals(
//         0,
//         jobPostings.size(),
//         'Expected 0 job postings for non-existent department'
//       );
//     }
//   }
// }

