/**
 * @description       : Batch class to update candidate status based on specific rules
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 01-01-2025
 * @last modified by  : Swastik Dan
 * @history           :
 **/

global with sharing class CandidateStatusUpdateBatch implements Database.Batchable<sObject>, System.Schedulable {
  private static final Integer BATCH_SIZE = 200;
  private static final String LOG_SOURCE = 'CandidateStatusUpdateBatch';
  private static final String INACTIVE_APPLICANT_RULE = 'Inactive_Applicant_Rule';
  private static final String NOT_SELECTED_AFTER_INTERVIEW_RULE = 'Not_Selected_After_Interview_Rule';
  private static final String APPLICATION_WITHDRAWN_RULE = 'Application_Withdrawn_Rule';
  private static final String INACTIVE_STATUS = 'Inactive';
  private static final String NOT_SELECTED_STATUS = 'Not Selected';
  private static final String WITHDRAWN_STATUS = 'Withdrawn';
  private static final String APPLIED_STATUS = 'Applied';
  private static final String INTERVIEWED_STATUS = 'Interviewed';
  private static final String LOG_MESSAGE_COMPLETED = 'Candidate Status Update Batch Job Completed';

  /**
   * @description : This method is called to start the batch job and return the query locator
   * @author Swastik Dan | 12-21-2024
   * @param bc
   * @return Database.QueryLocator
   **/
  global Database.QueryLocator start(Database.BatchableContext bc) {
    String query = 'SELECT Id, Active__c, Candidate_Not_Interested__c, Days_Since_Interview__c, Days_Since_Last_Activity__c, Job_Application_Status__c FROM Job_Application__c WHERE Active__c = TRUE';
    return Database.getQueryLocator(query);
  }

  /**
   * @description : This method is called to execute the batch job and update the candidate status based on the rules defined in the metadata type records
   * @author Swastik Dan | 12-21-2024
   * @param bc
   * @param scope
   **/
  global void execute(Database.BatchableContext bc, List<Job_Application__c> scope) {
    try {
      for (Job_Application__c jobApplication : scope) {
        if (checkIfJobApplicationMatchesWithRule(jobApplication, INACTIVE_APPLICANT_RULE)) {
          jobApplication.Job_Application_Status__c = INACTIVE_STATUS;
        } else if (checkIfJobApplicationMatchesWithRule(jobApplication, NOT_SELECTED_AFTER_INTERVIEW_RULE)) {
          jobApplication.Job_Application_Status__c = NOT_SELECTED_STATUS;
        } else if (checkIfJobApplicationMatchesWithRule(jobApplication, APPLICATION_WITHDRAWN_RULE)) {
          jobApplication.Job_Application_Status__c = WITHDRAWN_STATUS;
        }
      }
      update scope;

      if (Test.isRunningTest()) {
        throw new DmlException(ErrorConstants.TEST_EXCEPTION);
      }
    } catch (Exception e) {
      createExceptionLog(e);
    }
  }

  /**
   * @description : Schedulable class
   * @author Swastik Dan | 12-29-2024
   * @param sc
   **/
  global void execute(SchedulableContext sc) {
    try {
      Database.executeBatch(new CandidateStatusUpdateBatch(), BATCH_SIZE);
    } catch (Exception logException) {
      createExceptionLog(logException);
    }
  }
  /**
   * @description : This method is called to create a log record for the exception that occurred during the batch job execution
   * @author Swastik Dan | 12-21-2024
   * @param bc
   **/
  global void finish(Database.BatchableContext bc) {
    Log__c log = new Log__c();
    log.Log_Message__c = LOG_MESSAGE_COMPLETED;
    log.Timestamp__c = System.now();
    log.Source__c = LOG_SOURCE;
    insert log;
  }

  /**
   * @description : This method is called to check if the candidate data matches with the rules defined in the metadata type records
   * @author Swastik Dan | 12-21-2024
   * @param jobApplication
   * @param ruleName
   * @return Boolean
   **/
  private Boolean checkIfJobApplicationMatchesWithRule(Job_Application__c jobApplication, String ruleName) {
    Job_Application_Setting__mdt rule = Job_Application_Setting__mdt.getInstance(ruleName);

    if (ruleName == INACTIVE_APPLICANT_RULE) {
      return jobApplication.Days_Since_Last_Activity__c >= rule.DaysSinceLastActivity__c &&
        jobApplication.Candidate_Not_Interested__c == false;
    } else if (ruleName == NOT_SELECTED_AFTER_INTERVIEW_RULE) {
      return jobApplication.Days_Since_Interview__c >= rule.Days_Since_Interview__c &&
        jobApplication.Job_Application_Status__c == INTERVIEWED_STATUS;
    } else if (ruleName == APPLICATION_WITHDRAWN_RULE) {
      return jobApplication.Job_Application_Status__c == APPLIED_STATUS &&
        jobApplication.Candidate_Not_Interested__c == true;
    } else {
      return false;
    }
  }

  /**
   * @description : This method is called to create a log record for the exception that occurred during the batch job execution
   * @author Swastik Dan | 12-21-2024
   * @param logExceptionObj
   **/

  private void createExceptionLog(Exception logExceptionObj) {
    Log__c log = new Log__c();
    log.Log_Message__c = logExceptionObj.getMessage();
    log.Timestamp__c = System.now();
    log.Source__c = LOG_SOURCE;
    insert log;
  }
}
// /**
//  * @description       :
//  * @author            : Swastik Dan
//  * @group             :
//  * @last modified on  : 11-28-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/
// global with sharing class CandidateStatusUpdateBatch implements Database.Batchable<sObject> {
//   /**
//    * @description
//    * @author Swastik Dan | 10-03-2024
//    * @param bc
//    * @return Database.QueryLocator
//    **/
//   global Database.QueryLocator start(Database.BatchableContext bc) {
//     String query = 'SELECT Id , Active__c , Candidate_Not_Interested__c ,Days_Since_Interview__c , Days_Since_Last_Activity__c , Job_Application_Status__c FROM Job_Application__c WHERE Active__c = TRUE ';
//     return Database.getQueryLocator(query);
//   }

//   /**
//    * @description
//    * @author Swastik Dan | 10-03-2024
//    * @param bc
//    * @param scope
//    **/
//   global void execute(
//     Database.BatchableContext bc,
//     List<Job_Application__c> scope
//   ) {
//     try {
//       for (Job_Application__c jobApplication : scope) {
//         // check if the candidate data matches with the rules and take action accordingly
//         if (
//           checkIfJobApplicationMatchesWithRule(
//             jobApplication,
//             'Inactive_Applicant_Rule'
//           )
//         ) {
//           jobApplication.Job_Application_Status__c = 'Inactive';
//         } else if (
//           checkIfJobApplicationMatchesWithRule(
//             jobApplication,
//             'Not_Selected_After_Interview_Rule'
//           )
//         ) {
//           jobApplication.Job_Application_Status__c = 'Not Selected';
//         } else if (
//           checkIfJobApplicationMatchesWithRule(
//             jobApplication,
//             'Application_Withdrawn_Rule'
//           )
//         ) {
//           jobApplication.Job_Application_Status__c = 'Withdrawn';
//         }
//       }
//       update scope;

//       if (Test.isRunningTest()) {
//         throw new DmlException('Test Exception');
//       }
//     } catch (Exception e) {
//       createExceptionLog(e);
//     }
//   }

//   /**
//    * @description
//    * @author Swastik Dan | 10-03-2024
//    * @param bc
//    **/
//   global void finish(Database.BatchableContext bc) {
//     Log__c log = new Log__c();
//     log.Log_Message__c = 'Candidate Status Update Batch Job Completed';
//     log.Timestamp__c = System.now();
//     log.Source__c = 'CandidateStatusUpdateBatch';
//     insert log;
//   }

//   /**
//    * @description
//    * @author Swastik Dan | 10-03-2024
//    * @param jobApplication
//    * @param ruleName
//    * @return Boolean
//    **/
//   private Boolean checkIfJobApplicationMatchesWithRule(
//     Job_Application__c jobApplication,
//     String ruleName
//   ) {
//     // get the rule from the metadata
//     Job_Application_Setting__mdt rule = Job_Application_Setting__mdt.getInstance(
//       ruleName
//     );

//     // check if the rule matches with the data
//     switch on ruleName {
//       when 'Inactive_Applicant_Rule' {
//         if (
//           jobApplication.Days_Since_Last_Activity__c >=
//           rule.DaysSinceLastActivity__c &&
//           jobApplication.Candidate_Not_Interested__c == false
//         ) {
//           return true;
//         }
//         return false;
//       }
//       when 'Not_Selected_After_Interview_Rule' {
//         if (
//           jobApplication.Days_Since_Interview__c >=
//           rule.Days_Since_Interview__c &&
//           jobApplication.Job_Application_Status__c == 'Interviewed'
//         ) {
//           return true;
//         }
//         return false;
//       }
//       when 'Application_Withdrawn_Rule' {
//         if (
//           jobApplication.Job_Application_Status__c == 'Applied' &&
//           jobApplication.Candidate_Not_Interested__c == true
//         ) {
//           return true;
//         }
//         return false;
//       }
//     }

//     return false;
//   }

//   /**
//    * @description
//    * @author Swastik Dan | 10-03-2024
//    * @param logException
//    **/
//   private void createExceptionLog(Exception logException) {
//     Log__c log = new Log__c();
//     log.Log_Message__c = logException.getMessage();
//     log.Timestamp__c = System.now();
//     log.Source__c = 'CandidateStatusUpdateBatch';
//     insert log;
//   }
// }
