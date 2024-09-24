/**
 * @description       : Handles the trigger logic for Position__c object.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class PositionTriggerHandler extends TriggerHandler {
  private Map<Id, Position__c> oldPositionMap;
  private Map<Id, Position__c> newPositionMap;
  private List<Position_Update_Log__c> positionUpdateLogs;
  private Map<String, Schema.SObjectField> fieldMap;
  private List<String> fieldsToSkip = new List<String>{
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
    this.fieldMap = Schema.getGlobalDescribe()
      .get('Position__c')
      .getDescribe()
      .fields.getMap();
    this.setMaxLoopCount(1);
  }

  /**
   * @description : This method is called after updating position records. It logs the changes made to the position records and sends notification emails to candidates who have applied for the updated positions.
   * @author Swastik Dan | 09-24-2024
   **/
  public override void afterUpdate() {
    try {
      List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

      // Fetch job applications for updated positions
      Map<Id, List<Job_Application__c>> positionJobApplicationsMap = getJobApplicationsByPosition(
        this.newPositionMap
      );

      // Process updates for each position
      for (Position__c newPosition : newPositionMap.values()) {
        if (
          oldPositionMap != null && oldPositionMap.containsKey(newPosition.Id)
        ) {
          Position__c oldPosition = oldPositionMap.get(newPosition.Id);

          String emailSubject = newPosition.Name + ' Position Updated';
          String emailBody =
            'The position ' +
            newPosition.Name +
            ' has been updated in the following fields: \n';

          // Compare fields and log changes and update email body for each field
          processFieldUpdates(oldPosition, newPosition, emailBody);

          // Send notifications to candidates who have applied for the updated position
          List<Job_Application__c> jobApplications = positionJobApplicationsMap.get(
            newPosition.Id
          );
          if (jobApplications != null) {
            emailsToSend.addAll(
              sendNotificationsToCandidates(
                emailSubject,
                emailBody,
                jobApplications
              )
            );
          }
        }
      }

      // Insert logs and send emails
      if (!positionUpdateLogs.isEmpty()) {
        insert as user positionUpdateLogs;
      }
      if (!emailsToSend.isEmpty()) {
        Messaging.sendEmail(emailsToSend);
      }
    } catch (Exception e) {
      logException(e);
    }
  }

  // get job application and related candidate details from position
  private Map<Id, List<Job_Application__c>> getJobApplicationsByPosition(
    Map<Id, Position__c> positionMap
  ) {
    List<Job_Application__c> jobApplications = [
      SELECT
        Candidate__r.First_Name__c,
        Candidate__r.Last_Name__c,
        Candidate__r.Email__c,
        Name,
        Position__c
      FROM Job_Application__c
      WHERE Position__c IN :positionMap.keySet()
      WITH USER_MODE
    ];

    Map<Id, List<Job_Application__c>> positionJobApplicationsMap = new Map<Id, List<Job_Application__c>>();
    // Map job applications to their respective positions
    for (Job_Application__c jobApp : jobApplications) {
      if (!positionJobApplicationsMap.containsKey(jobApp.Position__c)) {
        positionJobApplicationsMap.put(
          jobApp.Position__c,
          new List<Job_Application__c>()
        );
      }
      // Add job application to the list
      positionJobApplicationsMap.get(jobApp.Position__c).add(jobApp);
    }
    return positionJobApplicationsMap;
  }

  // Compare fields that have changed and log the changes and update the email body with the changes

  // Change processFieldUpdates to void
  private void processFieldUpdates(
    Position__c oldPosition,
    Position__c newPosition,
    String emailBody
  ) {
    for (Schema.SObjectField field : fieldMap.values()) {
      if (
        newPosition.get(field) != oldPosition.get(field) &&
        !fieldsToSkip.contains(field.getDescribe().getName())
      ) {
        PositionUpdateLogWrapper updateData = new PositionUpdateLogWrapper();

        updateData.fieldLabel = field.getDescribe().getLabel();
        updateData.oldValue = String.valueOf(oldPosition.get(field));
        updateData.newValue = String.valueOf(newPosition.get(field));
        updateData.positionId = newPosition.Id;

        Position_Update_Log__c updateLog = createPositionUpdateLog(updateData);
        positionUpdateLogs.add(updateLog);

        emailBody +=
          updateData.fieldLabel +
          ': ' +
          updateData.oldValue +
          ' -> ' +
          updateData.newValue +
          '\n';
      }
    }
  }

  // get notification emails for the candidates
  private List<Messaging.SingleEmailMessage> sendNotificationsToCandidates(
    String subject,
    String body,
    List<Job_Application__c> jobApplications
  ) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    for (Job_Application__c jobApp : jobApplications) {
      if (jobApp.Candidate__r.Email__c != null) {
        emails.add(
          createEmailMessage(subject, body, jobApp.Candidate__r.Email__c)
        );
      }
    }
    return emails;
  }
  // create email message
  private Messaging.SingleEmailMessage createEmailMessage(
    String subject,
    String body,
    String toAddress
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setSubject(subject);
    email.setPlainTextBody(body);
    email.setToAddresses(new List<String>{ toAddress });
    return email;
  }
  // create position update log
  private Position_Update_Log__c createPositionUpdateLog(
    PositionUpdateLogWrapper updateData
  ) {
    Position_Update_Log__c updateLog = new Position_Update_Log__c();
    updateLog.Position__c = updateData.positionId;
    updateLog.Chnaged_Filed__c = updateData.fieldLabel;
    updateLog.Old_Value__c = updateData.oldValue;
    updateLog.New_Value__c = updateData.newValue;
    updateLog.Update_Date_Time__c = Datetime.now();
    updateLog.Updated_By__c = UserInfo.getUserId();
    return updateLog;
  }
  // Wrapper class for position update log
  public class PositionUpdateLogWrapper {
    public String fieldLabel;
    public String oldValue;
    public String newValue;
    public Id positionId;
  }
  // log exception
  private void logException(Exception e) {
    Log__c log = new Log__c();
    log.Log_Message__c = e.getMessage();
    log.Error_Type__c = e.getTypeName();
    insert as user log;
  }
}

/*
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
    // soql query to ger the canidate details from the form the crrated by field form the iob applications related to the position
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    List<Job_Application__c> allRelatedJobApplications = [
      SELECT
        Candidate__r.First_Name__c,
        Candidate__r.Last_Name__c,
        Candidate__r.Email__c,
        Candidate__r.Contact__c,
        Name,
        Position__c
      FROM Job_Application__c
      WHERE Position__c IN :newPositionMap.keySet()
      WITH USER_MODE
    ];
    Map<Id, List<Job_Application__c>> positionIdToJobApplicationsIdMap = new Map<Id, List<Job_Application__c>>();
    // map the job application to the respective position id
    for (Job_Application__c jobApplication : allRelatedJobApplications) {
      if (
        !positionIdToJobApplicationsIdMap.containsKey(
          jobApplication.Position__c
        )
      ) {
        positionIdToJobApplicationsIdMap.put(
          jobApplication.Position__c,
          new List<Job_Application__c>()
        );
      }
      positionIdToJobApplicationsIdMap.get(jobApplication.Position__c)
        .add(jobApplication);
    }

    // Check if any field value is changed and if changed then create a log for that and add it to the list
    for (Position__c newPosition : newPositionMap.values()) {
      String emailSubject = newPosition.Name + ' Position Updated';
      String emailBody =
        'The position ' +
        newPosition.Name +
        ' has been updated in follwoing fields:  \n';
      // get the canidates emails for the positiontojobapplication map
      List<Job_Application__c> jobApplications = positionIdToJobApplicationsIdMap.get(
        newPosition.Id
      );

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
            emailBody +=
              positionUpdateData.fieldLabel +
              ' : ' +
              positionUpdateData.oldValue +
              ' -> ' +
              positionUpdateData.newValue +
              '\n';

            positionUpdateLogs.add(positionUpdateLog);
          }
        }
      }

      // send email to the candidates
      for (Job_Application__c jobApplication : jobApplications) {
        Messaging.SingleEmailMessage email = createEmailMessage(
          emailSubject,
          emailBody,
          jobApplication.Candidate__r.Email__c
        );
        emailsToSend.add(email);
      }
    }
    if (!positionUpdateLogs.isEmpty()) {
      insert as user positionUpdateLogs;
    }
    if (!emailsToSend.isEmpty()) {
      Messaging.sendEmail(emailsToSend);
    }
  }

  private Messaging.SingleEmailMessage createEmailMessage(
    String subject,
    String body,
    String toAddress
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setSubject(subject);
    email.setPlainTextBody(body);
    email.setToAddresses(new List<String>{ toAddress });
    return email;
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
  */
// public with sharing class PositionTriggerHandler extends TriggerHandler {
//   Map<Id, Position__c> oldPositionMap;
//   Map<Id, Position__c> newPositionMap;
//   List<String> fieldsToSkip = new List<String>{
//     'CreatedById',
//     'CreatedDate',
//     'LastModifiedById',
//     'LastModifiedDate',
//     'SystemModstamp'
//   };
//   List<Position_Update_Log__c> positionUpdateLogs;
//   // https://trailhead.salesforce.com/trailblazer-community/feed/0D54V00007T4K2wSAF
//   Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Position__c');
//   Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe()
//     .fields.getMap();
//   List<Messaging.SingleEmailMessage> emailsToSend;
//   List<Job_Application__c> allRelatedJobApplications;
//   Map<Id, List<Job_Application__c>> positionIdToJobApplicationsIdMap;
//   public PositionTriggerHandler() {
//     this.oldPositionMap = Trigger.oldMap;
//     this.newPositionMap = Trigger.newMap;
//     this.positionUpdateLogs = new List<Position_Update_Log__c>();
//     List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
//     this.allRelatedJobApplications = [
//       SELECT
//         Candidate__r.First_Name__c,
//         Candidate__r.Last_Name__c,
//         Candidate__r.Email__c,
//         Candidate__r.Contact__c,
//         Name,
//         Position__c
//       FROM Job_Application__c
//       WHERE Position__c IN :newPositionMap.keySet()
//       WITH USER_MODE
//     ];
//     this.positionIdToJobApplicationsIdMap = new Map<Id, List<Job_Application__c>>();
//     this.setMaxLoopCount(1);
//   }

//   public override void afterUpdate() {

//   }

//   private

//   private Messaging.SingleEmailMessage createEmailMessage(
//     String subject,
//     String body,
//     String toAddress
//   ) {
//     Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//     email.setSubject(subject);
//     email.setPlainTextBody(body);
//     email.setToAddresses(new List<String>{ toAddress });
//     return email;
//   }

//   private Position_Update_Log__c createPositionUpdateLog(
//     PositionUpdateLogWrapper positionUpdateData
//   ) {
//     Position_Update_Log__c positionUpdateLog = new Position_Update_Log__c();
//     positionUpdateLog.Position__c = positionUpdateData.positionId;
//     positionUpdateLog.Chnaged_Filed__c = positionUpdateData.fieldLabel;
//     positionUpdateLog.Old_Value__c = positionUpdateData.oldValue;
//     positionUpdateLog.New_Value__c = positionUpdateData.newValue;
//     positionUpdateLog.Update_Date_Time__c = Datetime.now();
//     positionUpdateLog.Updated_By__c = UserInfo.getUserId();
//     return positionUpdateLog;
//   }

//   public class PositionUpdateLogWrapper {
//     public String fieldLabel;
//     public String oldValue;
//     public String newValue;
//     public Id positionId;
//   }
// }

/*
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
    // soql query to ger the canidate details from the form the crrated by field form the iob applications related to the position
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    List<Job_Application__c> allRelatedJobApplications = [
      SELECT
        Candidate__r.First_Name__c,
        Candidate__r.Last_Name__c,
        Candidate__r.Email__c,
        Candidate__r.Contact__c,
        Name,
        Position__c
      FROM Job_Application__c
      WHERE Position__c IN :newPositionMap.keySet()
      WITH USER_MODE
    ];
    Map<Id, List<Job_Application__c>> positionIdToJobApplicationsIdMap = new Map<Id, List<Job_Application__c>>();
    // map the job application to the respective position id
    for (Job_Application__c jobApplication : allRelatedJobApplications) {
      if (
        !positionIdToJobApplicationsIdMap.containsKey(
          jobApplication.Position__c
        )
      ) {
        positionIdToJobApplicationsIdMap.put(
          jobApplication.Position__c,
          new List<Job_Application__c>()
        );
      }
      positionIdToJobApplicationsIdMap.get(jobApplication.Position__c)
        .add(jobApplication);
    }

    // Check if any field value is changed and if changed then create a log for that and add it to the list
    for (Position__c newPosition : newPositionMap.values()) {
      String emailSubject = newPosition.Name + ' Position Updated';
      String emailBody =
        'The position ' +
        newPosition.Name +
        ' has been updated in follwoing fields:  \n';
      // get the canidates emails for the positiontojobapplication map
      List<Job_Application__c> jobApplications = positionIdToJobApplicationsIdMap.get(
        newPosition.Id
      );

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
            emailBody +=
              positionUpdateData.fieldLabel +
              ' : ' +
              positionUpdateData.oldValue +
              ' -> ' +
              positionUpdateData.newValue +
              '\n';

            positionUpdateLogs.add(positionUpdateLog);
          }
        }
      }

      // send email to the candidates
      for (Job_Application__c jobApplication : jobApplications) {
        Messaging.SingleEmailMessage email = createEmailMessage(
          emailSubject,
          emailBody,
          jobApplication.Candidate__r.Email__c
        );
        emailsToSend.add(email);
      }
    }
    if (!positionUpdateLogs.isEmpty()) {
      insert as user positionUpdateLogs;
    }
    if (!emailsToSend.isEmpty()) {
      Messaging.sendEmail(emailsToSend);
    }
  }

  private Messaging.SingleEmailMessage createEmailMessage(
    String subject,
    String body,
    String toAddress
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setSubject(subject);
    email.setPlainTextBody(body);
    email.setToAddresses(new List<String>{ toAddress });
    return email;
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









// new 


public with sharing class PositionTriggerHandler extends TriggerHandler {
  private Map<Id, Position__c> oldPositionMap;
  private Map<Id, Position__c> newPositionMap;
  private List<Position_Update_Log__c> positionUpdateLogs;
  private List<String> fieldsToSkip = new List<String>{
    'CreatedById',
    'CreatedDate',
    'LastModifiedById',
    'LastModifiedDate',
    'SystemModstamp'
  };
  private List<Messaging.SingleEmailMessage> emailsToSend;
  private List<Job_Application__c> allRelatedJobApplications;
  private Map<Id, List<Job_Application__c>> positionIdToJobApplicationsIdMap;

  public PositionTriggerHandler() {
    this.oldPositionMap = (Map<Id, Position__c>) Trigger.oldMap;
    this.newPositionMap = (Map<Id, Position__c>) Trigger.newMap;
    this.positionUpdateLogs = new List<Position_Update_Log__c>();
    this.emailsToSend = new List<Messaging.SingleEmailMessage>();
    this.allRelatedJobApplications = [
      SELECT
        Candidate__r.First_Name__c,
        Candidate__r.Last_Name__c,
        Candidate__r.Email__c,
        Candidate__r.Contact__c,
        Name,
        Position__c
      FROM Job_Application__c
      WHERE Position__c IN :newPositionMap.keySet()
      WITH USER_MODE
    ];
    this.positionIdToJobApplicationsIdMap = new Map<Id, List<Job_Application__c>>();
    this.setMaxLoopCount(1);
  }

  public override void afterUpdate() {
    for (Job_Application__c jobApplication : allRelatedJobApplications) {
      if (
        !positionIdToJobApplicationsIdMap.containsKey(
          jobApplication.Position__c
        )
      ) {
        positionIdToJobApplicationsIdMap.put(
          jobApplication.Position__c,
          new List<Job_Application__c>()
        );
      }
      positionIdToJobApplicationsIdMap.get(jobApplication.Position__c)
        .add(jobApplication);
    }

    for (Position__c newPosition : newPositionMap.values()) {
      String emailSubject = newPosition.Name + ' Position Updated';
      String emailBody =
        'The position ' +
        newPosition.Name +
        ' has been updated in follwoing fields:  \n';
      List<Job_Application__c> jobApplications = positionIdToJobApplicationsIdMap.get(
        newPosition.Id
      );

      if (
        oldPositionMap != null && oldPositionMap.containsKey(newPosition.Id)
      ) {
        Position__c oldPosition = oldPositionMap.get(newPosition.Id);
        for (
          Schema.SObjectField field : newPosition.getSObjectType()
            .getDescribe()
            .fields.getMap()
            .values()
        ) {
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
            emailBody +=
              positionUpdateData.fieldLabel +
              ' : ' +
              positionUpdateData.oldValue +
              ' -> ' +
              positionUpdateData.newValue +
              '\n';

            positionUpdateLogs.add(positionUpdateLog);
          }
        }
      }

      for (Job_Application__c jobApplication : jobApplications) {
        Messaging.SingleEmailMessage email = createEmailMessage(
          emailSubject,
          emailBody,
          jobApplication.Candidate__r.Email__c
        );
        emailsToSend.add(email);
      }
    }
  }

  private Messaging.SingleEmailMessage createEmailMessage(
    String subject,
    String body,
    String toAddress
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setSubject(subject);
    email.setPlainTextBody(body);
    email.setToAddresses(new List<String>{ toAddress });
    return email;
  }

  public class PositionUpdateLogWrapper {
    public String fieldLabel;
    public String oldValue;
    public String newValue;
    public Id positionId;
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
}
*/

