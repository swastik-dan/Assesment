/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-20-2024
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

    insert candidates;

    return candidates;
  }
  public static List<Contact> createGenericContact(Integer numberOfContact) {
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < numberOfContact; i++) {
      Contact contact = new Contact(
        FirstName = 'Test First Name ' + i,
        LastName = 'Test Last Name ' + i,
        Email = 'test' + i + '@test.com'
      );
      contacts.add(contact);
    }

    insert contacts;

    return contacts;
  }
}
