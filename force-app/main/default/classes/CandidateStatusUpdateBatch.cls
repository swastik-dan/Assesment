/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 10-03-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
global with sharing class CandidateStatusUpdateBatch implements Database.Batchable<sObject> {
  /**
   * @description
   * @author Swastik Dan | 10-03-2024
   * @param bc
   * @return Database.QueryLocator
   **/
  global Database.QueryLocator start(Database.BatchableContext bc) {
    String query = 'SELECT Id , Active__c , Candidate_Not_Interested__c ,Days_Since_Interview__c , Days_Since_Last_Activity__c , Job_Application_Status__c FROM Job_Application__c WHERE Active__c = TRUE ';
    return Database.getQueryLocator(query);
  }

  /**
   * @description
   * @author Swastik Dan | 10-03-2024
   * @param bc
   * @param scope
   **/
  global void execute(
    Database.BatchableContext bc,
    List<Job_Application__c> scope
  ) {
    try {
      for (Job_Application__c jobApplication : scope) {
        // check if the candidate data matches with the rules and take action accordingly
        if (
          checkIfJobApplicationMatchesWithRule(
            jobApplication,
            'Inactive_Applicant_Rule'
          )
        ) {
          jobApplication.Job_Application_Status__c = 'Inactive';
        } else if (
          checkIfJobApplicationMatchesWithRule(
            jobApplication,
            'Not_Selected_After_Interview_Rule'
          )
        ) {
          jobApplication.Job_Application_Status__c = 'Not Selected';
        } else if (
          checkIfJobApplicationMatchesWithRule(
            jobApplication,
            'Application_Withdrawn_Rule'
          )
        ) {
          jobApplication.Job_Application_Status__c = 'Withdrawn';
        }
      }
      update scope;
    } catch (Exception e) {
      createExceptionLog(e);
    }
  }

  /**
   * @description
   * @author Swastik Dan | 10-03-2024
   * @param bc
   **/
  global void finish(Database.BatchableContext bc) {
    Log__c log = new Log__c();
    log.Log_Message__c = 'Candidate Status Update Batch Job Completed';
    log.Timestamp__c = System.now();
    log.Source__c = 'CandidateStatusUpdateBatch';
    insert log;
  }

  /**
   * @description
   * @author Swastik Dan | 10-03-2024
   * @param jobApplication
   * @param ruleName
   * @return Boolean
   **/
  private Boolean checkIfJobApplicationMatchesWithRule(
    Job_Application__c jobApplication,
    String ruleName
  ) {
    // get the rule from the metadata
    Job_Application_Setting__mdt rule = Job_Application_Setting__mdt.getInstance(
      ruleName
    );

    // check if the rule matches with the data
    switch on ruleName {
      when 'Inactive_Applicant_Rule' {
        if (
          jobApplication.Days_Since_Last_Activity__c >=
          rule.DaysSinceLastActivity__c &&
          jobApplication.Candidate_Not_Interested__c == false
        ) {
          return true;
        }
        return false;
      }
      when 'Not_Selected_After_Interview_Rule' {
        if (
          jobApplication.Days_Since_Interview__c >=
          rule.Days_Since_Interview__c &&
          jobApplication.Job_Application_Status__c == 'Interviewed'
        ) {
          return true;
        }
        return false;
      }
      when 'Application_Withdrawn_Rule' {
        if (
          jobApplication.Job_Application_Status__c == 'Applied' &&
          jobApplication.Candidate_Not_Interested__c == true
        ) {
          return true;
        }
        return false;
      }
      when else {
        return false;
      }
    }
  }

  /**
   * @description
   * @author Swastik Dan | 10-03-2024
   * @param logException
   **/
  private void createExceptionLog(Exception logException) {
    Log__c log = new Log__c();
    log.Log_Message__c = logException.getMessage();
    log.Timestamp__c = System.now();
    log.Source__c = 'CandidateStatusUpdateBatch';
    insert log;
  }
}
