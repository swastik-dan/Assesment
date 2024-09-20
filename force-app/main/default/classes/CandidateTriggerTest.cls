/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-20-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
@isTest
public class CandidateTriggerTest {
  @isTest
  static void testCandidateInsert() {
    Test.startTest();
    List<Candidate__c> candidates = TestHelper.createGenericCandidate(2);
    insert candidates;
    Test.stopTest();

    List<String> emailList = new List<String>();
    for (Candidate__c candidate : candidates) {
      emailList.add(candidate.Email__c);
    }

    List<Contact> contacts = [
      SELECT Id, FirstName, LastName, Email
      FROM Contact
      WHERE Email IN :emailList
    ];
    System.assertEquals(
      candidates.size(),
      contacts.size(),
      'Contact records are not created'
    );
  }

  @isTest
  static void testIfContactAlreadyExists() {
    Test.startTest();
    List<Candidate__c> candidates = TestHelper.createGenericCandidate(10);
    insert candidates;
    Test.stopTest();

    List<String> emailList = new List<String>();
    for (Candidate__c candidate : candidates) {
      emailList.add(candidate.Email__c);
    }

    List<Contact> newContacts = [
      SELECT Id, FirstName, LastName, Email
      FROM Contact
      WHERE Email IN :emailList
    ];
    System.assertEquals(
      10,
      newContacts.size(),
      'Contact records are not created'
    );
  }
}
