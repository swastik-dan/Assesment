/**
 * @description       : This class handles the trigger operations for Position object. It logs the changes made to the position records and sends notification emails to candidates who have applied for the updated positions.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-25-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class PositionTriggerHandler extends TriggerHandler {
  private Map<Id, Position__c> oldPositionMap;
  private Map<Id, Position__c> newPositionMap;
  private Map<String, Schema.SObjectField> fieldMap;
  private String message;
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
   * @author Swastik Dan | 09-25-2024
   **/
  public PositionTriggerHandler() {
    this.oldPositionMap = (Map<Id, Position__c>) Trigger.oldMap;
    this.newPositionMap = (Map<Id, Position__c>) Trigger.newMap;
    this.fieldMap = Schema.getGlobalDescribe()
      .get('Position__c')
      .getDescribe()
      .fields.getMap();
  }

  /**
   * @description : This method is called after updating position records. It logs the changes made to the position records and sends notification emails to candidates who have applied for the updated positions.
   * @author Swastik Dan | 09-25-2024
   **/
  public override void afterUpdate() {
    try {
      // List to store platform events
      List<Position_Update__e> positionUpdateEvents = new List<Position_Update__e>();
      // Process updates for each position
      for (Position__c newPosition : newPositionMap.values()) {
        // Check if the position has been updated
        if (
          oldPositionMap != null && oldPositionMap.containsKey(newPosition.Id)
        ) {
          Position__c oldPosition = oldPositionMap.get(newPosition.Id);
          String emailSubject = newPosition.Name + ' Position Updated';
          this.message =
            'The position ' +
            newPosition.Name +
            ' has been updated in the following fields: \n';

          // Compare fields and log changes and update email body for each field
          processFieldUpdates(oldPosition, newPosition);

          // add the position update event to the list and check if the message length exceeds the limit 32,768 characters
          positionUpdateEvents.add(
            new Position_Update__e(
              Posotion_Id__c = newPosition.Id,
              Email_Subject__c = emailSubject,
              Message__c = message.length() > 32768
                ? message.substring(0, 32768)
                : message
            )
          );
        }
      }
      // Publish platform events
      if (!positionUpdateEvents.isEmpty()) {
        EventBus.publish(positionUpdateEvents);
      }
    } catch (Exception logException) {
      createLogException(logException);
    }
  }
  /**
   * @description : This method compares the fields that have changed in the position records and logs the changes. It updates the email body with the changes made to the position records.
   * @author Swastik Dan | 09-25-2024
   * @param oldPosition
   * @param newPosition
   **/
  private void processFieldUpdates(
    Position__c oldPosition,
    Position__c newPosition
  ) {
    for (Schema.SObjectField field : fieldMap.values()) {
      if (
        newPosition.get(field) != oldPosition.get(field) &&
        !fieldsToSkip.contains(field.getDescribe().getName())
      ) {
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
   * @description : This method creates a log record for the exception occurred during the trigger execution. It logs the exception message and type in the Log object for tracking and debugging purposes.
   * @author Swastik Dan | 09-25-2024
   * @param logException
   **/
  private void createLogException(Exception logException) {
    Log__c log = new Log__c();
    log.Log_Message__c = logException.getMessage();
    log.Error_Type__c = logException.getTypeName();
    insert as user log;
  }
}
