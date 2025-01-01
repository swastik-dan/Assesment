/**
 * @description       : Queueable class to execute the batch job for updating candidate status
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-22-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

global with sharing class CandidateStatusUpdateJob implements System.Schedulable {
  private static final Integer BATCH_SIZE = 200;
  private static final String LOG_SOURCE = 'CandidateStatusUpdateJob';
  /**
   * @description : This method is called to execute the batch job to update the status of the candidates based on the rules defined in the CandidateStatusUpdateBatch class.
   * @author Swastik Dan | 12-22-2024
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
   * @description : This method is called to create a log record for the exception that occurred during the batch job execution.
   * @author Swastik Dan | 12-22-2024
   * @param logException
   **/
  private void createExceptionLog(Exception logException) {
    Log__c log = new Log__c();
    log.Log_Message__c = logException.getMessage();
    log.Timestamp__c = System.now();
    log.Source__c = logException.getLineNumber() + ' - ' + LOG_SOURCE;
    insert as USER log;
  }
}

// /**
//  * @description       : Queueable class to execute the batch job for updating candidate status
//  * @group             :
//  * @last modified on  : 12-21-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/
// global with sharing class CandidateStatusUpdateQueueable implements Queueable {
//   // Constants for log source and batch size
//   private static final String LOG_SOURCE = 'CandidateStatusUpdateQueueable';
//   private static final Integer BATCH_SIZE = 200;

//   /**
//    * @description : This method is called to execute the batch job to update the status of the candidates based on the rules defined in the CandidateStatusUpdateBatch class.
//    * @param context
//    **/
//   global void execute(QueueableContext context) {
//     try {
//       Database.executeBatch(new CandidateStatusUpdateBatch(), BATCH_SIZE);
//     } catch (Exception logException) {
//       createExceptionLog(logException);
//     }
//   }

//   /**
//    * @description : This method is called to create a log record for the exception that occurred during the batch job execution.
//    * @param logException
//    **/
//   private void createExceptionLog(Exception logException) {
//     Log__c log = new Log__c();
//     log.Log_Message__c = logException.getMessage();
//     log.Timestamp__c = System.now();
//     log.Source__c = logException.getLineNumber() + ' - ' + LOG_SOURCE;
//     insert log;
//   }
// }
// /**
//  * @description       :
//  * @author            : Swastik Dan
//  * @group             :
//  * @last modified on  : 10-08-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/
// global with sharing class CandidateStatusUpdateQueueable implements Queueable {
//   /**
//    * @description : This method is called to execute the batch job to update the status of the candidates based on the rules defined in the CandidateStatusUpdateBatch class.
//    * @author Swastik Dan | 10-08-2024
//    * @param context
//    **/
//   global void execute(QueueableContext context) {
//     try {
//       Database.executeBatch(new CandidateStatusUpdateBatch(), 200);
//     } catch (Exception logException) {
//       createExceptionLog(logException);
//     }
//   }
//   /**
//    * @description : This method is called to create a log record for the exception that occurred during the batch job execution.
//    * @author Swastik Dan | 10-08-2024
//    * @param logException
//    **/
//   private void createExceptionLog(Exception logException) {
//     Log__c log = new Log__c();
//     log.Log_Message__c = logException.getMessage();
//     log.Timestamp__c = System.now();
//     log.Source__c = 'CandidateStatusUpdateQueueable';
//     insert log;
//   }
// }

