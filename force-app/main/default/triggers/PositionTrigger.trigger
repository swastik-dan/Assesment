/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-23-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
trigger PositionTrigger on Position__c(after update) {
  new PositionTriggerHandler().run();
}
