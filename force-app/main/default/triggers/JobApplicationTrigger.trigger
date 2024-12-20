/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 10-26-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
trigger JobApplicationTrigger on Job_Application__c(after update) {
  new JobApplicationTriggerHandler().execute();
}
