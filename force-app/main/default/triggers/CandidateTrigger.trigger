/**
 * @description       : This is the trigger handler for the Candidate object.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-20-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
trigger CandidateTrigger on Candidate__c(after insert) {
  new CandidateTriggerHandler().execute();

}
