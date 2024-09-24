/**
 * @description       : Handles the trigger logic for Position__c object.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class PositionTriggerHandler extends TriggerHandler {
  Map<Id, Position__c> oldPositionMap;
  Map<Id, Position__c> newPositionMap;
  // https://trailhead.salesforce.com/trailblazer-community/feed/0D54V00007T4K2wSAF
  Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Position__c');
  Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe()
    .fields.getMap();
  List<Position_Update_Log__c> positionUpdateLogs;

  List<String> fieldsToSkip = new List<String>{
    'CreatedById',
    'CreatedDate',
    'LastModifiedById',
    'LastModifiedDate',
    'SystemModstamp'
  };
  public PositionTriggerHandler() {
    this.oldPositionMap = (Map<Id, Position__c>) Trigger.oldMap;
    this.newPositionMap = (Map<Id, Position__c>) Trigger.newMap;
    this.positionUpdateLogs = new List<Position_Update_Log__c>();
    this.setMaxLoopCount(1);
  }

  public override void afterUpdate() {
    // Check if any field value is changed and if changed then create a log for that and add it to the list
    for (Position__c newPosition : newPositionMap.values()) {
      if (
        oldPositionMap != null && oldPositionMap.containsKey(newPosition.Id)
      ) {
        Position__c oldPosition = oldPositionMap.get(newPosition.Id);
        for (Schema.SObjectField field : fieldMap.values()) {
          if (
            newPosition.get(field) != oldPosition.get(field) &&
            !fieldsToSkip.contains(field.getDescribe().getName())
          ) {
            PositionUpdateLogWrapper positionUpdateData = new PositionUpdateLogWrapper();
            positionUpdateData.fieldLabel = field.getDescribe().getLabel();
            positionUpdateData.oldValue = String.valueOf(
              oldPosition.get(field)
            );
            positionUpdateData.newValue = String.valueOf(
              newPosition.get(field)
            );
            positionUpdateData.positionId = newPosition.Id;
            Position_Update_Log__c positionUpdateLog = createPositionUpdateLog(
              positionUpdateData
            );

            positionUpdateLogs.add(positionUpdateLog);
          }
        }
      }
    }
    if (!positionUpdateLogs.isEmpty()) {
      insert as user positionUpdateLogs;
    }
  }

  private Position_Update_Log__c createPositionUpdateLog(
    PositionUpdateLogWrapper positionUpdateData
  ) {
    Position_Update_Log__c positionUpdateLog = new Position_Update_Log__c();
    positionUpdateLog.Position__c = positionUpdateData.positionId;
    positionUpdateLog.Chnaged_Filed__c = positionUpdateData.fieldLabel;
    positionUpdateLog.Old_Value__c = positionUpdateData.oldValue;
    positionUpdateLog.New_Value__c = positionUpdateData.newValue;
    positionUpdateLog.Update_Date_Time__c = Datetime.now();
    positionUpdateLog.Updated_By__c = UserInfo.getUserId();
    return positionUpdateLog;
  }

  public class PositionUpdateLogWrapper {
    public String fieldLabel;
    public String oldValue;
    public String newValue;
    public Id positionId;
  }
}
