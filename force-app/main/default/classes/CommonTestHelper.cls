/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 10-01-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
@isTest
public with sharing class CommonTestHelper {
  /**
   * @description : Create generic candidate records for testing purposes
   * @author Swastik Dan | 10-01-2024
   * @param numberOfCandidate
   * @return List<Candidate__c>
   **/
  public static List<Candidate__c> createGenericCandidate(
    Integer numberOfCandidate
  ) {
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
   * @description : Create generic contact records for testing purposes
   * @author Swastik Dan | 10-01-2024
   * @param numberOfContact
   * @param startNumber
   * @return List<Contact>
   **/
  public static List<Contact> createGenericContact(
    Integer numberOfContact,
    Integer startNumber
  ) {
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
      for (
        Integer iterator = startNumber; iterator < numberOfContact; iterator++
      ) {
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
   * @description  : Create generic position records for testing purposes
   * @author Swastik Dan | 10-01-2024
   * @param numberOfPosition
   * @return List<Position__c>
   **/
  public static List<Position__c> createGenericPosition(
    Integer numberOfPosition
  ) {
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
   * @description : Find position by name
   * @author Swastik Dan | 10-01-2024
   * @param positionName
   * @return Position__c
   **/
  public static Position__c findPostionByName(String positionName) {
    return [
      SELECT Id
      FROM Position__c
      WHERE Name = :positionName
      LIMIT 1
    ];
  }
  /**
   * @description : Create generic job application records for testing purposes
   * @author Swastik Dan | 10-01-2024
   * @param candidates
   * @param positions
   * @return List<Job_Application__c>
   **/
  public static List<Job_Application__c> createGenericJobApplication(
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
   * @author Swastik Dan | 10-01-2024
   * @param profileName
   * @param userEmail
   * @param nickName
   * @return User
   **/
  public static User createUserWithProfile(
    String profileName,
    String userEmail,
    String nickName
  ) {
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
   * @author Swastik Dan | 10-01-2024
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
   * @description : Format the DateTime to String in the format yyyy-MM-dd
   * @author Swastik Dan | 10-01-2024
   * @param inputDate
   * @return String
   **/
  public static String formatDate(DateTime inputDate) {
    if (inputDate == null) {
      return null; // Handle null input if necessary
    }
    // Format the DateTime to String
    return inputDate.format('yyyy-MM-dd');
  }
}
