/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-20-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
trigger CandidateTrigger on Candidate__c(before insert) {
  new CandidateTriggerHandler().run();
  System.debug('Trigger caled');

}
