/**
 * @description       :
 * @autor            : Swastik Dan
 * @group             :
 * @last modified on  : 09-25-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class SendPositionUpdatesToCandidatesHandler {
  /**
   * @description
   * @author Swastik Dan | 09-25-2024
   * @param inputVariablesList
   **/
  @InvocableMethod(
    label='Send Position Updates To Candidates'
    description='Send Position Updates To Candidates'
  )
  public static void sendPositionUpdateToCandidates(
    List<InputVariablesWrapper> inputVariablesList
  ) {
    // Assuming only one set of input variables is passed
    InputVariablesWrapper inputVariables = inputVariablesList[0];

    List<String> candidateEmails = new List<String>();
    List<Job_Application__c> jobApplications = [
      SELECT Id, Candidate__r.Email__c
      FROM Job_Application__c
      WHERE Position__c = :inputVariables.positionId
      WITH SECURITY_ENFORCED
    ];
    for (Job_Application__c jobApplication : jobApplications) {
      candidateEmails.add(jobApplication.Candidate__r.Email__c);
    }
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setSubject(inputVariables.emailSubject);
    email.setPlainTextBody(inputVariables.emailBody);
    email.setToAddresses(candidateEmails);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
  }

  /**
   * @description       :
   * @author            : Swastik Dan
   * @group             :
   * @last modified on  : 09-25-2024
   * @last modified by  : Swastik Dan
   * @history           :
   **/
  public class InputVariablesWrapper {
    @InvocableVariable(label='Position Id' required=true)
    public Id positionId;
    @InvocableVariable(label='Email Subject' required=true)
    public String emailSubject;
    @InvocableVariable(label='Email Body' required=true)
    public String emailBody;
  }
}