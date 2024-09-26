/**
 * @description       : Test class for CandidateTriggerHandler class to test the trigger functionality of Candidate object
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-26-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

@isTest
public class CandidateTriggerTest {
  /**
   * @description : Test candidate insert
   * @author Swastik Dan | 09-23-2024
   **/

  @isTest
  static void testCandidateInsert() {
    Test.startTest();
    List<Candidate__c> candidates = TestHelper.createGenericCandidate(4);
    insert as user candidates;
    Test.stopTest();

    List<String> emailList = new List<String>();
    for (Candidate__c candidate : candidates) {
      emailList.add(candidate.Email__c);
    }

    List<Contact> contacts = [
      SELECT Id, FirstName, LastName, Email
      FROM Contact
      WHERE Email IN :emailList
      WITH USER_MODE
    ];
    System.assertEquals(
      candidates.size(),
      contacts.size(),
      'Contact records are not created'
    );
  }

  /**
   * @description : Test if contact already exists
   * @author Swastik Dan | 09-23-2024
   **/
  @isTest
  static void testIfContactAlreadyExists() {
    Test.startTest();
    List<Contact> contacts = TestHelper.createGenericContact(10, 4);
    insert as user contacts;
    List<Candidate__c> candidates = TestHelper.createGenericCandidate(10);
    insert as user candidates;
    Test.stopTest();

    List<String> emailList = new List<String>();
    for (Candidate__c candidate : candidates) {
      emailList.add(candidate.Email__c);
    }

    List<Contact> newContacts = [
      SELECT Id, FirstName, LastName, Email
      FROM Contact
      WHERE Email IN :emailList
      WITH USER_MODE
    ];
    System.assertEquals(
      10,
      newContacts.size(),
      'Contact records are not created'
    );
  }
}
