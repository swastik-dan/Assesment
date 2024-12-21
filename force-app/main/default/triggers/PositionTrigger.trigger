/**
 * @description       : This is the trigger handler for Position object.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-21-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
trigger PositionTrigger on Position__c(after update) {
  new PositionTriggerHandler().execute();
}
