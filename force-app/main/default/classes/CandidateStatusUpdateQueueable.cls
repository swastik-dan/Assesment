/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 10-08-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
global with sharing class CandidateStatusUpdateQueueable implements Queueable {
  /**
   * @description : This method is called to execute the batch job to update the status of the candidates based on the rules defined in the CandidateStatusUpdateBatch class.
   * @author Swastik Dan | 10-08-2024
   * @param context
   **/
  global void execute(QueueableContext context) {
    try {
      Database.executeBatch(new CandidateStatusUpdateBatch(), 200);
    } catch (Exception logException) {
      createExceptionLog(logException);
    }
  }
  /**
   * @description : This method is called to create a log record for the exception that occurred during the batch job execution.
   * @author Swastik Dan | 10-08-2024
   * @param logException
   **/
  private void createExceptionLog(Exception logException) {
    Log__c log = new Log__c();
    log.Log_Message__c = logException.getMessage();
    log.Timestamp__c = System.now();
    log.Source__c = 'CandidateStatusUpdateQueueable';
    insert log;
  }
}
