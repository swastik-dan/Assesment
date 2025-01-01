/**
 * @description       : Common Test Helper class for creating test data
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-26-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
@isTest
public with sharing class CommonTestHelper {
  /**
   * @description : Create a single generic candidate record for testing purposes
   * @author Swastik Dan
   * @return Candidate__c
   **/
  public static Candidate__c createSingleGenericCandidate() {
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Test First Name',
      Last_Name__c = 'Test Last Name',
      Email__c = 'test@test.com'
    );

    return candidate;
  }

  /**
   * @description : Create generic candidate records for testing purposes
   * @author Swastik Dan
   * @param numberOfCandidate
   * @return List<Candidate__c>
   **/
  public static List<Candidate__c> createGenericCandidates(Integer numberOfCandidate) {
    List<Candidate__c> candidates = new List<Candidate__c>();
    for (Integer iterator = 0; iterator < numberOfCandidate; iterator++) {
      Candidate__c candidate = new Candidate__c(
        First_Name__c = 'Test First Name ' + iterator,
        Last_Name__c = 'Test Last Name ' + iterator,
        Email__c = 'test' + iterator + '@test.com'
      );
      candidates.add(candidate);
    }
    return candidates;
  }

  /**
   * @description : Create a single generic contact record for testing purposes
   * @author Swastik Dan
   * @return Contact
   **/
  public static Contact createSingleGenericContact() {
    Contact contact = new Contact(FirstName = 'Test First Name', LastName = 'Test Last Name', Email = 'test@test.com');

    return contact;
  }

  /**
   * @description : Create generic contact records for testing purposes
   * @author Swastik Dan
   * @param numberOfContact
   * @param startNumber
   * @return List<Contact>
   **/
  public static List<Contact> createGenericContacts(Integer numberOfContact, Integer startNumber) {
    List<Contact> contacts = new List<Contact>();
    if (startNumber == null) {
      for (Integer iterator = 0; iterator < numberOfContact; iterator++) {
        Contact contact = new Contact(
          FirstName = 'Test First Name ' + iterator,
          LastName = 'Test Last Name ' + iterator,
          Email = 'test' + iterator + '@test.com'
        );
        contacts.add(contact);
      }
    } else {
      for (Integer iterator = startNumber; iterator < numberOfContact; iterator++) {
        Contact contact = new Contact(
          FirstName = 'Test First Name ' + iterator,
          LastName = 'Test Last Name ' + iterator,
          Email = 'test' + iterator + '@test.com'
        );
        contacts.add(contact);
      }
    }

    return contacts;
  }

  /**
   * @description : Create a single generic position record for testing purposes
   * @author Swastik Dan
   * @return Position__c
   **/
  public static Position__c createSingleGenericPosition() {
    Position__c position = new Position__c(
      Name = 'Test Position',
      Status__c = 'New Position',
      Type__c = 'Full Time',
      Min_Pay__c = 100000,
      Max_Pay__c = 150000
    );
    return position;
  }

  /**
   * @description : Create generic position records for testing purposes
   * @author Swastik Dan
   * @param numberOfPosition
   * @return List<Position__c>
   **/
  public static List<Position__c> createGenericPositions(Integer numberOfPosition) {
    List<Position__c> positions = new List<Position__c>();
    for (Integer iterator = 0; iterator < numberOfPosition; iterator++) {
      Position__c position = new Position__c(
        Name = 'Test Position ' + iterator,
        Status__c = 'New Position',
        Type__c = 'Full Time',
        Min_Pay__c = 100000,
        Max_Pay__c = 150000
      );
      positions.add(position);
    }
    return positions;
  }

  /**
   * @description : Create a single generic employment website record for testing purposes
   * @author Swastik Dan
   * @return Employment_Website__c
   **/
  public static Employment_Website__c createSingleGenericEmploymentWebsite() {
    Employment_Website__c employmentWebsite = new Employment_Website__c(
      Name = 'Test Employment Website',
      Web_Address__c = 'https://www.test.com',
      Maximum_Budget__c = 1000,
      Price_Per_Post__c = 100
    );
    return employmentWebsite;
  }

  /**
   * @description : Create generic employment website records for testing purposes
   * @author Swastik Dan
   * @param numberOfEmploymentWebsite
   * @return List<Employment_Website__c>
   **/
  public static List<Employment_Website__c> createGenericEmploymentWebsites(Integer numberOfEmploymentWebsite) {
    List<Employment_Website__c> employmentWebsites = new List<Employment_Website__c>();
    for (Integer iterator = 0; iterator < numberOfEmploymentWebsite; iterator++) {
      Employment_Website__c employmentWebsite = new Employment_Website__c(
        Name = 'Test Employment Website ' + iterator,
        Web_Address__c = 'https://www.test' + iterator + '.com',
        Maximum_Budget__c = 1000,
        Price_Per_Post__c = 100
      );
      employmentWebsites.add(employmentWebsite);
    }

    return employmentWebsites;
  }

  /**
   * @description : Create a single generic job posting record for testing purposes
   * @author Swastik Dan
   * @param employmentWebsiteId
   * @param positionId
   * @return Job_Posting__c
   **/
  public static Job_Posting__c createSingleGenericJobPosting(Id employmentWebsiteId, Id positionId) {
    Job_Posting__c jobPosting = new Job_Posting__c(
      Job_Name__c = 'Job Posting',
      Department__c = 'Department',
      Active__c = true,
      Employment_Website__c = employmentWebsiteId,
      Position__c = positionId
    );

    return jobPosting;
  }

  /**
   * @description : Create generic job posting records for testing purposes
   * @author Swastik Dan
   * @param employmentWebsiteId
   * @param positionId
   * @param numberOfJobPostings
   * @return List<Job_Posting__c>
   **/
  public static List<Job_Posting__c> createGenericJobPostings(
    Id employmentWebsiteId,
    Id positionId,
    Integer numberOfJobPostings
  ) {
    List<Job_Posting__c> jobPostingList = new List<Job_Posting__c>();

    for (Integer iterator = 0; iterator < numberOfJobPostings; iterator++) {
      Job_Posting__c jobPosting = new Job_Posting__c(
        Job_Name__c = 'Job Posting ' + iterator,
        Department__c = 'Department ' + iterator,
        Active__c = true,
        Employment_Website__c = employmentWebsiteId,
        Position__c = positionId
      );
      jobPostingList.add(jobPosting);
    }

    return jobPostingList;
  }

  /**
   * @description : Create generic job application records for testing purposes
   * @author Swastik Dan
   * @param candidates
   * @param positions
   * @return List<Job_Application__c>
   **/
  public static List<Job_Application__c> createGenericJobApplications(
    List<Candidate__c> candidates,
    List<Position__c> positions
  ) {
    List<Job_Application__c> jobApplications = new List<Job_Application__c>();
    for (Integer iterator = 0; iterator < candidates.size(); iterator++) {
      Job_Application__c jobApplication = new Job_Application__c(
        Candidate__c = candidates[iterator].Id,
        Position__c = positions[iterator].Id
      );
      jobApplications.add(jobApplication);
    }

    return jobApplications;
  }

  /**
   * @description : Create generic user records for testing purposes
   * @author Swastik Dan
   * @param profileName
   * @param userEmail
   * @param nickName
   * @return User
   **/
  public static User createUserWithProfile(String profileName, String userEmail, String nickName) {
    Profile profileInst = [
      SELECT Id
      FROM Profile
      WHERE Name = :profileName
      LIMIT 1
    ];

    User user = new User();
    user.FirstName = 'TestOne';
    user.LastName = 'User';
    user.Alias = nickName;
    user.Email = userEmail;
    user.Username = userEmail;
    user.CommunityNickname = nickName;
    user.ProfileId = profileInst.Id;
    user.TimeZoneSidKey = 'America/Los_Angeles';
    user.LocaleSidKey = 'en_US';
    user.EmailEncodingKey = 'UTF-8';
    user.LanguageLocaleKey = 'en_US';

    return user;
  }

  /**
   * @description : Find user by email address
   * @author Swastik Dan
   * @param userEmail
   * @return User
   **/
  public static User findUserByEmail(String userEmail) {
    return [
      SELECT Id
      FROM User
      WHERE Email = :userEmail
      LIMIT 1
    ];
  }

  /**
   * @description : Create job application records with random details for testing purposes
   * @param candidates
   * @param positions
   * @return List<Job_Application__c>
   **/
  public static List<Job_Application__c> createJobApplicationWithRandomDetails(
    List<Candidate__c> candidates,
    List<Position__c> positions
  ) {
    List<Job_Application__c> jobApplications = new List<Job_Application__c>();
    Integer totalJobApplication = 100;

    for (Integer iterator = 0; iterator < totalJobApplication; iterator++) {
      Job_Application__c jobApplication = new Job_Application__c(
        Candidate__c = candidates[0].Id,
        Position__c = positions[iterator].Id
      );

      if (iterator < 30) {
        jobApplication.Candidate_Not_Interested__c = false;
        jobApplication.Active__c = true;
      } else if (iterator < 60) {
        jobApplication.Job_Application_Status__c = 'Interviewed';
        jobApplication.Active__c = true;
        jobApplication.Candidate_Not_Interested__c = false;
      } else if (iterator < 90) {
        jobApplication.Job_Application_Status__c = 'Applied';
        jobApplication.Candidate_Not_Interested__c = true;
        jobApplication.Active__c = true;
      } else {
        jobApplication.Job_Application_Status__c = null;
        jobApplication.Candidate_Not_Interested__c = false;
        jobApplication.Active__c = true;
      }

      jobApplications.add(jobApplication);
    }

    return jobApplications;
  }

  /**
   * @description : Format the DateTime to String in the format yyyy-MM-dd
   * @author Swastik Dan
   * @param inputDate
   * @return String
   **/
  public static String formatDate(DateTime inputDate) {
    if (inputDate == null) {
      return null;
    }
    return inputDate.format('yyyy-MM-dd');
  }
}
// /**
//  * @description       :
//  * @author            : Swastik Dan
//  * @group             :
//  * @last modified on  : 12-22-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/
// @isTest
// public with sharing class CommonTestHelper {
//   /**
//    * @description : Create generic candidate records for testing purposes
//    * @author Swastik Dan | 10-01-2024
//    * @param numberOfCandidate
//    * @return List<Candidate__c>
//    **/
//   public static List<Candidate__c> createGenericCandidate(
//     Integer numberOfCandidate
//   ) {
//     List<Candidate__c> candidates = new List<Candidate__c>();
//     for (Integer iterator = 0; iterator < numberOfCandidate; iterator++) {
//       Candidate__c candidate = new Candidate__c(
//         First_Name__c = 'Test First Name ' + iterator,
//         Last_Name__c = 'Test Last Name ' + iterator,
//         Email__c = 'test' + iterator + '@test.com'
//       );
//       candidates.add(candidate);
//     }
//     return candidates;
//   }

//   /**
//    * @description : Create generic contact records for testing purposes
//    * @author Swastik Dan | 10-01-2024
//    * @param numberOfContact
//    * @param startNumber
//    * @return List<Contact>
//    **/
//   public static List<Contact> createGenericContact(
//     Integer numberOfContact,
//     Integer startNumber
//   ) {
//     List<Contact> contacts = new List<Contact>();
//     if (startNumber == null) {
//       for (Integer iterator = 0; iterator < numberOfContact; iterator++) {
//         Contact contact = new Contact(
//           FirstName = 'Test First Name ' + iterator,
//           LastName = 'Test Last Name ' + iterator,
//           Email = 'test' + iterator + '@test.com'
//         );
//         contacts.add(contact);
//       }
//     } else {
//       for (
//         Integer iterator = startNumber; iterator < numberOfContact; iterator++
//       ) {
//         Contact contact = new Contact(
//           FirstName = 'Test First Name ' + iterator,
//           LastName = 'Test Last Name ' + iterator,
//           Email = 'test' + iterator + '@test.com'
//         );
//         contacts.add(contact);
//       }
//     }

//     return contacts;
//   }

//   /**
//    * @description  : Create generic position records for testing purposes
//    * @author Swastik Dan | 10-01-2024
//    * @param numberOfPosition
//    * @return List<Position__c>
//    **/
//   public static List<Position__c> createGenericPosition(
//     Integer numberOfPosition
//   ) {
//     List<Position__c> positions = new List<Position__c>();
//     for (Integer iterator = 0; iterator < numberOfPosition; iterator++) {
//       Position__c position = new Position__c(
//         Name = 'Test Position ' + iterator,
//         Status__c = 'New Position',
//         Type__c = 'Full Time',
//         Min_Pay__c = 100000,
//         Max_Pay__c = 150000
//       );
//       positions.add(position);
//     }
//     return positions;
//   }

//   /**
//    * @description : Find position by name
//    * @author Swastik Dan | 10-01-2024
//    * @param positionName
//    * @return Position__c
//    **/
//   public static Position__c findPostionByName(String positionName) {
//     return [
//       SELECT Id
//       FROM Position__c
//       WHERE Name = :positionName
//       LIMIT 1
//     ];
//   }
//   /**
//    * @description : Create generic job application records for testing purposes
//    * @author Swastik Dan | 10-01-2024
//    * @param candidates
//    * @param positions
//    * @return List<Job_Application__c>
//    **/
//   public static List<Job_Application__c> createGenericJobApplication(
//     List<Candidate__c> candidates,
//     List<Position__c> positions
//   ) {
//     List<Job_Application__c> jobApplications = new List<Job_Application__c>();
//     for (Integer iterator = 0; iterator < candidates.size(); iterator++) {
//       Job_Application__c jobApplication = new Job_Application__c(
//         Candidate__c = candidates[iterator].Id,
//         Position__c = positions[iterator].Id
//       );
//       jobApplications.add(jobApplication);
//     }
//     return jobApplications;
//   }

//   /**
//    * @description : Create generic user records for testing purposes
//    * @author Swastik Dan | 10-01-2024
//    * @param profileName
//    * @param userEmail
//    * @param nickName
//    * @return User
//    **/
//   public static User createUserWithProfile(
//     String profileName,
//     String userEmail,
//     String nickName
//   ) {
//     Profile profileInst = [
//       SELECT Id
//       FROM Profile
//       WHERE Name = :profileName
//       LIMIT 1
//     ];

//     User user = new User();
//     user.FirstName = 'TestOne';
//     user.LastName = 'User';
//     user.Alias = nickName;
//     user.Email = userEmail;
//     user.Username = userEmail;
//     user.CommunityNickname = nickName;
//     user.ProfileId = profileInst.Id;
//     user.TimeZoneSidKey = 'America/Los_Angeles';
//     user.LocaleSidKey = 'en_US';
//     user.EmailEncodingKey = 'UTF-8';
//     user.LanguageLocaleKey = 'en_US';

//     return user;
//   }

//   /**
//    * @description : Find user by email address
//    * @author Swastik Dan | 10-01-2024
//    * @param userEmail
//    * @return User
//    **/
//   public static User findUserByEmail(String userEmail) {
//     return [
//       SELECT Id
//       FROM User
//       WHERE Email = :userEmail
//       LIMIT 1
//     ];
//   }

//   /**
//    * @description
//    * @author Swastik Dan | 10-04-2024
//    * @param candidates
//    * @param positions
//    * @return List<Job_Application__c>
//    **/
//   public static List<Job_Application__c> createJobApplicationWithRandomDetails(
//     List<Candidate__c> candidates,
//     List<Position__c> positions
//   ) {
//     List<Job_Application__c> jobApplications = new List<Job_Application__c>();
//     // Integer totalCandidates = candidates.size();
//     Integer totalJobApplication = 100;

//     for (Integer iterator = 0; iterator < totalJobApplication; iterator++) {
//       Job_Application__c jobApplication = new Job_Application__c(
//         Candidate__c = candidates[0].Id,
//         Position__c = positions[iterator].Id
//       );

//       if (iterator < 30) {
//         // First rule: Inactive Applicant
//         // jobApplication.Job_Application_Status__c = 'Inactive';
//         jobApplication.Candidate_Not_Interested__c = false;
//       } else if (iterator < 60) {
//         // Second rule: Not Selected After Interview
//         jobApplication.Job_Application_Status__c = 'Interviewed';
//         jobApplication.Candidate_Not_Interested__c = false;
//       } else if (iterator < 90) {
//         // Third rule: Application Withdrawn
//         jobApplication.Job_Application_Status__c = 'Applied';
//         jobApplication.Candidate_Not_Interested__c = true;
//       } else {
//         jobApplication.Job_Application_Status__c = 'New';
//         jobApplication.Candidate_Not_Interested__c = false;
//       }

//       jobApplications.add(jobApplication);
//     }

//     return jobApplications;
//   }

//   /**
//    * @description : Format the DateTime to String in the format yyyy-MM-dd
//    * @author Swastik Dan | 10-01-2024
//    * @param inputDate
//    * @return String
//    **/
//   public static String formatDate(DateTime inputDate) {
//     if (inputDate == null) {
//       return null; // Handle null input if necessary
//     }
//     // Format the DateTime to String
//     return inputDate.format('yyyy-MM-dd');
//   }
// }
