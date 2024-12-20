/**
 * @description       : 
 * @author            : Swastik Dan
 * @group             : 
 * @last modified on  : 12-20-2024
 * @last modified by  : Swastik Dan
 * @history           : 
**/
@RestResource(urlMapping='/api/candidates')
global with sharing class CandidateRecordAPI {
  @HttpGet
  global static List<Candidate__c> getCandidates() {
    List<Candidate__c> candidateList = [
      SELECT Id, First_Name__c, Last_name__c
      FROM Candidate__c
      LIMIT 10
    ];

    return candidateList;
  }
}
