/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 10-03-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
trigger PositionTrigger on Position__c(after update) {
  new PositionTriggerHandler().execute();
  System.debug('Trigger runs');
}
