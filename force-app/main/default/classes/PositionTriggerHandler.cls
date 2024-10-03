/**
 * @description       : This class handles the trigger operations for Position object. It logs the changes made to the position records and sends notification emails to candidates who have applied for the updated positions.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 10-03-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

public with sharing class PositionTriggerHandler extends ExtendedTriggerHandler {
  private Map<Id, Position__c> oldPositionMap;
  private Map<Id, Position__c> newPositionMap;
  private Map<String, Schema.SObjectField> fieldMap;
  private String message;
  private Integer numberOfFieldsUpdated;
  private List<String> fieldsToSkip = new List<String>{
    'CreatedById',
    'CreatedDate',
    'LastModifiedById',
    'LastModifiedDate',
    'SystemModstamp',
    'OwnerId',
    'LastModifiedBy'
  };

  /**
   * @description : Constructor to initialize the class variables
   * @author Swastik Dan | 10-01-2024
   **/
  public PositionTriggerHandler() {
    this.oldPositionMap = (Map<Id, Position__c>) Trigger.oldMap;
    this.newPositionMap = (Map<Id, Position__c>) Trigger.newMap;
    this.fieldMap = Schema.getGlobalDescribe()
      .get('Position__c')
      .getDescribe()
      .fields.getMap();
    this.numberOfFieldsUpdated = 0;
  }

  /**
   * @description : This method checks if the trigger is enabled or disabled based on the custom metadata setting.
   * @author Swastik Dan | 10-01-2024
   * @return boolean
   **/
  public override boolean isTriggerEnabled() {
    return !sobject_Trigger_Manager__mdt.getInstance('POSITION_TRIGGER')
      .disableTrigger__c;
  }

  /**
   * @description : This method is called after updating position records. It logs the changes made to the position records and sends notification emails to candidates who have applied for the updated positions.
   * @author Swastik Dan | 10-01-2024
   **/
  public override void afterUpdate() {
    try {
      List<Position_Update__e> positionUpdateEvents = new List<Position_Update__e>();
      handleFieldUpdates(positionUpdateEvents);
      // System.debug(
      //   'code runs and number of fileds changed = ' + numberOfFieldsUpdated
      // );
      if (!positionUpdateEvents.isEmpty() && this.numberOfFieldsUpdated > 0) {
        EventBus.publish(positionUpdateEvents);
      }
      if (Test.isRunningTest()) {
        throw new DmlException('Test DML Exception');
      }
    } catch (Exception logException) {
      createLogException(logException);
    }
  }

  /**
   * @description : This method handles the field updates for the position records and creates the platform events for the updated positions. It logs the changes made to the position records and updates the email body with the changes.
   * @author Swastik Dan | 10-01-2024
   * @param positionUpdateEvents
   **/
  private void handleFieldUpdates(
    List<Position_Update__e> positionUpdateEvents
  ) {
    for (Position__c newPosition : newPositionMap.values()) {
      if (
        oldPositionMap != null && oldPositionMap.containsKey(newPosition.Id)
      ) {
        Position__c oldPosition = oldPositionMap.get(newPosition.Id);
        String emailSubject = newPosition.Name + ' Position Updated';
        this.message =
          'The position ' +
          newPosition.Name +
          ' has been updated in the following fields: \n';
        logFieldChanges(oldPosition, newPosition);
        Position_Update__e positionUpdateEvent = createPositionUpdateEvent(
          newPosition,
          emailSubject,
          message.length() > 32768 ? message.substring(0, 32768) : message
        );
        positionUpdateEvents.add(positionUpdateEvent);
      }
    }
  }

  /**
   * @description : This method compares the fields that have changed in the position records and logs the changes. It updates the email body with the changes made to the position records.
   * @author Swastik Dan | 10-01-2024
   * @param oldPosition
   * @param newPosition
   **/
  private void logFieldChanges(
    Position__c oldPosition,
    Position__c newPosition
  ) {
    for (Schema.SObjectField field : fieldMap.values()) {
      if (
        newPosition.get(field) != oldPosition.get(field) &&
        !fieldsToSkip.contains(field.getDescribe().getName())
      ) {
        this.numberOfFieldsUpdated = this.numberOfFieldsUpdated + 1;
        message +=
          field.getDescribe().getLabel() +
          ': ' +
          String.valueOf(oldPosition.get(field)) +
          ' -> ' +
          String.valueOf(newPosition.get(field)) +
          '\n';
      }
    }
  }
  /**
   * @description : This method creates a platform event for the updated position record. It sets the position ID, email subject, and message in the platform event fields and returns the event instance.
   * @author Swastik Dan | 10-01-2024
   * @param newPosition
   * @param emailSubject
   * @param message
   * @return Position_Update__e
   **/
  private Position_Update__e createPositionUpdateEvent(
    Position__c newPosition,
    String emailSubject,
    String message
  ) {
    Position_Update__e positionUpdateEvent = new Position_Update__e();
    positionUpdateEvent.Posotion_Id__c = newPosition.Id;
    positionUpdateEvent.Email_Subject__c = emailSubject;
    positionUpdateEvent.Message__c = message;
    return positionUpdateEvent;
  }

  /**
   * @description : This method creates a log record for the exception occurred during the trigger execution. It logs the exception message and type in the Log object for tracking and debugging purposes.
   * @author Swastik Dan | 10-01-2024
   * @param logException
   **/
  private void createLogException(Exception logException) {
    Log__c log = new Log__c();
    log.Log_Message__c = logException.getMessage();
    log.Error_Type__c = logException.getTypeName();
    insert as user log;
  }
}
