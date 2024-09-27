/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-27-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class lwcPracticeData {
  @AuraEnabled(cacheable=true)
  public static List<Candidate__c> getCandidates(Integer limitCandidate) {
    List<Candidate__c> candidates = [
      SELECT Id, First_Name__c, Last_Name__c, Email__c
      FROM Candidate__c
      LIMIT :limitCandidate
    ];

    return candidates;
  }
}
