/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-26-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
trigger CandidateTrigger on Candidate__c(after insert) {
  new CandidateTriggerHandler().execute();

}
