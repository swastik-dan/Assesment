/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-26-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
@isTest
public with sharing class TestHelper {
  public static List<Candidate__c> createGenericCandidate(
    Integer numberOfCandidate
  ) {
    List<Candidate__c> candidates = new List<Candidate__c>();
    for (Integer i = 0; i < numberOfCandidate; i++) {
      Candidate__c candidate = new Candidate__c(
        First_Name__c = 'Test First Name ' + i,
        Last_Name__c = 'Test Last Name ' + i,
        Email__c = 'test' + i + '@test.com'
      );
      candidates.add(candidate);
    }
    return candidates;
  }
  public static List<Contact> createGenericContact(
    Integer numberOfContact,
    Integer startNumber
  ) {
    List<Contact> contacts = new List<Contact>();
    if (startNumber == null) {
      for (Integer i = 0; i < numberOfContact; i++) {
        Contact contact = new Contact(
          FirstName = 'Test First Name ' + i,
          LastName = 'Test Last Name ' + i,
          Email = 'test' + i + '@test.com'
        );
        contacts.add(contact);
      }
    } else {
      for (Integer i = startNumber; i < numberOfContact; i++) {
        Contact contact = new Contact(
          FirstName = 'Test First Name ' + i,
          LastName = 'Test Last Name ' + i,
          Email = 'test' + i + '@test.com'
        );
        contacts.add(contact);
      }
    }

    return contacts;
  }

  public static List<Position__c> createGenericPosition(
    Integer numberOfPosition
  ) {
    List<Position__c> positions = new List<Position__c>();
    for (Integer i = 0; i < numberOfPosition; i++) {
      Position__c position = new Position__c(
        Name = 'Test Position ' + i,
        Status__c = 'New Position',
        Type__c = 'Full Time',
        Min_Pay__c = 100000,
        Max_Pay__c = 150000
      );
      positions.add(position);
    }
    return positions;
  }

  public static List<Job_Application__c> createGenericJobApplication(
    List<Candidate__c> candidates,
    List<Position__c> positions
  ) {
    List<Job_Application__c> jobApplications = new List<Job_Application__c>();
    for (Integer i = 0; i < candidates.size(); i++) {
      Job_Application__c jobApplication = new Job_Application__c(
        Candidate__c = candidates[i].Id,
        Position__c = positions[i].Id
      );
      jobApplications.add(jobApplication);
    }
    return jobApplications;
  }

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
}
