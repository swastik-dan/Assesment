/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-23-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class CandidateTriggerHandler extends TriggerHandler {
  private List<Candidate__c> newCandidateList;
  private Map<Id, Candidate__c> newCandidateMap;
  public CandidateTriggerHandler() {
    this.newCandidateMap = (Map<Id, Candidate__c>) Trigger.newMap;
    this.setMaxLoopCount(1);
  }

  /**
   * @description : This method is called before inserting new candidate records. It creates new contacts for candidates whose email addresses do not exist in the system, and sends welcome emails to new candidates.
   * @author Swastik Dan | 09-20-2024
   **/
  public override void afterInsert() {
    this.newCandidateList = [
      SELECT Id, First_Name__c, Last_Name__c, Email__c, Contact__c
      FROM Candidate__c
      WHERE id IN :newCandidateMap.keySet()
      WITH USER_MODE
    ];
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    Map<String, Id> emailToContactIdMap = new Map<String, Id>();
    List<Contact> contactsToInsert = new List<Contact>();
    List<String> candidateEmails = new List<String>();
    try {
      // Extract candidate email addresses
      for (Candidate__c candidate : newCandidateList) {
        candidateEmails.add(candidate.Email__c);
      }

      // Fetch existing contacts using email addresses
      List<Contact> existingContacts = getExistingContact(candidateEmails);
      // Map email to contact ID
      for (Contact contact : existingContacts) {
        emailToContactIdMap.put(contact.Email, contact.Id);
      }

      // Create new contacts if candidate email does not exist in the map
      for (Candidate__c candidate : newCandidateList) {
        if (!emailToContactIdMap.containsKey(candidate.Email__c)) {
          Contact newContact = createContactFromCandidate(candidate);
          contactsToInsert.add(newContact);
        }
      }

      // Insert new contacts if there are any, and update the map with their IDs
      if (!contactsToInsert.isEmpty()) {
        insert as user contactsToInsert;
        for (Contact contact : contactsToInsert) {
          emailToContactIdMap.put(contact.Email, contact.Id); // Update map with newly inserted contacts
        }
      }

      // Update candidates with corresponding Contact IDs
      for (Candidate__c candidate : newCandidateList) {
        if (candidate.Contact__c == null) {
          candidate.Contact__c = emailToContactIdMap.get(candidate.Email__c); // Link candidate to contact
        }
      }
      // update the user with the contact lookup
      update as user newCandidateList;

      // Create and send email messages using the welcome email template
      for (Candidate__c candidate : newCandidateList) {
        Messaging.SingleEmailMessage email = createEmailMessage(
          candidate,
          getEmailTemplateId('Candidate_Welcome_Email_Template')
        );

        emailsToSend.add(email);
      }

      Messaging.sendEmail(emailsToSend);
    } catch (Exception e) {
      logException(e);
    }
  }
  // Extract candidate email addresses
  @testVisible
  private Contact createContactFromCandidate(Candidate__c candidate) {
    Contact contact = new Contact();
    contact.FirstName = candidate.First_Name__c;
    contact.LastName = candidate.Last_Name__c;
    contact.Email = candidate.Email__c;
    return contact;
  }
  //  get email template id
  private Id getEmailTemplateId(String templateName) {
    EmailTemplate emailTemplate = [
      SELECT Id
      FROM EmailTemplate
      WHERE DeveloperName = :templateName
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    return emailTemplate.Id;
  }
  // create email message
  private Messaging.SingleEmailMessage createEmailMessage(
    Candidate__c candidate,
    Id templateId
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setTemplateId(templateId);
    email.setTargetObjectId(candidate.Contact__c);
    email.setSaveAsActivity(true);
    email.setWhatId(candidate.Id);
    return email;
  }
  // get existing contact
  private List<Contact> getExistingContact(List<String> emails) {
    List<Contact> existingContacts = [
      SELECT Id, Email
      FROM Contact
      WHERE Email IN :emails
      WITH USER_MODE
    ];
    return existingContacts;
  }
  // log exception
  private void logException(Exception e) {
    Log__c log = new Log__c();
    log.Log_Message__c = e.getMessage();
    log.Error_Type__c = e.getTypeName();
    insert as user log;
  }
}
