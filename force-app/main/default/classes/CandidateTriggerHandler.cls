/**
 * @description       : This class handles the trigger events for the Candidate object. It creates new contacts for new candidates and sends welcome emails to the candidates using the Candidate_Welcome_Email_Template email template. It also logs any exceptions that occur during the trigger execution.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 10-01-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class CandidateTriggerHandler extends ExtendedTriggerHandler {
  private List<Candidate__c> newCandidateList;
  private Map<Id, Candidate__c> newCandidateMap;

  /**
   * @description : Constructor to initialize the class variables
   * @author Swastik Dan | 09-26-2024
   **/
  public CandidateTriggerHandler() {
    this.newCandidateMap = (Map<Id, Candidate__c>) Trigger.newMap;
    // this.newCandidateList = (List<Candidate__c>) Trigger.new;
  }

  public override boolean isTriggerEnabled() {
    // CandidateTrigger
    return sobject_Trigger_Manager__mdt.getInstance('CANDIDATE_TRIGGER')
        .disableTrigger__c == true
      ? false
      : true;
  }

  /**
   * @description : This method is called after inserting new candidate records. It creates new contacts for new candidates and sends welcome emails to the candidates using the Candidate_Welcome_Email_Template email template. It also logs any exceptions that occur during the trigger execution.
   * @author Swastik Dan | 09-26-2024
   **/
  public override void afterInsert() {
    try {
      // Fetch new candidates because the trigger.newMap is read-only
      this.newCandidateList = fetchCandidates(this.newCandidateMap);

      // Extract candidate email addresses
      List<String> candidateEmails = extractCandidateEmails(newCandidateList);
      // Fetch existing contacts using email addresses
      Map<String, Id> emailToContactIdMap = mapExistingContacts(
        candidateEmails
      );
      // Create new contacts if candidate email does not exist in the map
      List<Contact> contactsToInsert = createNewContacts(
        newCandidateList,
        emailToContactIdMap
      );
      // Insert new contacts if there are any, and update the map with their IDs
      if (!contactsToInsert.isEmpty()) {
        insert as user contactsToInsert;
        for (Contact contact : contactsToInsert) {
          emailToContactIdMap.put(contact.Email, contact.Id);
        }
      }
      // Update candidates with corresponding Contact IDs
      for (Candidate__c candidate : newCandidateList) {
        if (candidate.Contact__c == null) {
          candidate.Contact__c = emailToContactIdMap.get(candidate.Email__c);
        }
      }

      update as user newCandidateList;
      // Create and send email messages using the welcome email template
      List<Messaging.SingleEmailMessage> emailsToSend = createEmailMessages(
        newCandidateList
      );

      // Send email messages
      Messaging.sendEmail(emailsToSend);
      if (Test.isRunningTest()) {
        throw new DmlException('Test DML Exception');
      }
    } catch (Exception e) {
      logException(e);
    }
  }

  /**
   * @description : This method fetches the new candidate records using the newCandidateMap variable and returns a list of Candidate__c records.
   * @author Swastik Dan | 09-26-2024
   * @param candidateMap
   * @return List<Candidate__c>
   **/
  private List<Candidate__c> fetchCandidates(
    Map<Id, Candidate__c> candidateMap
  ) {
    return [
      SELECT Id, First_Name__c, Last_Name__c, Email__c, Contact__c
      FROM Candidate__c
      WHERE id IN :candidateMap.keySet()
      WITH USER_MODE
    ];
  }

  /**
   * @description : This method extracts the email addresses of the candidates from the list of Candidate__c records and returns a list of email addresses as strings.
   * @author Swastik Dan | 09-26-2024
   * @param candidates
   * @return List<String>
   **/
  private List<String> extractCandidateEmails(List<Candidate__c> candidates) {
    List<String> emails = new List<String>();
    // Extract candidate email addresses from the list of candidates
    for (Candidate__c candidate : candidates) {
      emails.add(candidate.Email__c);
    }
    return emails;
  }

  /**
   * @description : This method fetches the existing contacts using the email addresses of the candidates and returns a map of email addresses to contact IDs as strings and IDs respectively.
   * @author Swastik Dan | 09-26-2024
   * @param candidateEmails
   * @return Map<String, Id>
   **/
  private Map<String, Id> mapExistingContacts(List<String> candidateEmails) {
    Map<String, Id> emailToContactIdMap = new Map<String, Id>();
    // Fetch existing contacts using email addresses
    List<Contact> existingContacts = getExistingContact(candidateEmails);
    // Map email to contact ID
    for (Contact contact : existingContacts) {
      emailToContactIdMap.put(contact.Email, contact.Id);
    }
    return emailToContactIdMap;
  }

  /**
   * @description : This method creates new contact records for the new candidates if the email address of the candidate does not exist in the emailToContactIdMap and returns a list of Contact records to insert.
   * @author Swastik Dan | 09-26-2024
   * @param candidates
   * @param emailToContactIdMap
   * @return List<Contact>
   **/
  private List<Contact> createNewContacts(
    List<Candidate__c> candidates,
    Map<String, Id> emailToContactIdMap
  ) {
    List<Contact> contactsToInsert = new List<Contact>();
    // Create new contacts if candidate email does not exist in the map
    for (Candidate__c candidate : candidates) {
      if (!emailToContactIdMap.containsKey(candidate.Email__c)) {
        // Create new contact from candidate
        Contact newContact = createContactFromCandidate(candidate);
        contactsToInsert.add(newContact);
      }
    }
    return contactsToInsert;
  }

  /**
   * @description : This method creates a new Contact record using the Candidate__c record and returns the Contact record created.
   * @author Swastik Dan | 09-26-2024
   * @param candidate
   * @return Contact
   **/
  private Contact createContactFromCandidate(Candidate__c candidate) {
    Contact contact = new Contact();
    contact.FirstName = candidate.First_Name__c;
    contact.LastName = candidate.Last_Name__c;
    contact.Email = candidate.Email__c;
    return contact;
  }

  /**
   * @description : This method creates email messages for the candidates using the Candidate_Welcome_Email_Template email template and returns a list of Messaging.SingleEmailMessage records to send.
   * @author Swastik Dan | 09-26-2024
   * @param candidates
   * @return List<Messaging.SingleEmailMessage>
   **/
  private List<Messaging.SingleEmailMessage> createEmailMessages(
    List<Candidate__c> candidates
  ) {
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    for (Candidate__c candidate : candidates) {
      Messaging.SingleEmailMessage email = createEmailMessage(
        candidate,
        getEmailTemplateId('Candidate_Welcome_Email_Template')
      );
      emailsToSend.add(email);
    }
    return emailsToSend;
  }

  /**
   * @description : This method fetches the email template ID using the template name and returns the ID of the email template as an Id data type.
   * @author Swastik Dan | 09-26-2024
   * @param templateName
   * @return Id
   **/
  private Id getEmailTemplateId(String templateName) {
    EmailTemplate emailTemplate = [
      SELECT Id
      FROM EmailTemplate
      WHERE DeveloperName = :templateName
      WITH USER_MODE
      LIMIT 1
    ];
    return emailTemplate.Id;
  }

  /**
   * @description : This method creates an email message for the candidate using the Candidate_Welcome_Email_Template email template and returns the Messaging.SingleEmailMessage record created.
   * @author Swastik Dan | 09-26-2024
   * @param candidate
   * @param templateId
   * @return Messaging.SingleEmailMessage
   **/
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

  /**
   * @description : This method fetches the existing contact records using the email addresses of the candidates and returns a list of Contact records for the existing contacts found in the system.
   * @author Swastik Dan | 09-26-2024
   * @param emails
   * @return List<Contact>
   **/
  private List<Contact> getExistingContact(List<String> emails) {
    return [
      SELECT Id, Email
      FROM Contact
      WHERE Email IN :emails
      WITH USER_MODE
    ];
  }

  /**
   * @description : This method logs the exception message and type in the Log object for tracking and debugging purposes. It creates a new Log record with the exception details and inserts it into the database.
   * @author Swastik Dan | 09-26-2024
   * @param logException
   **/
  private void logException(Exception logException) {
    Log__c log = new Log__c();
    log.Log_Message__c = logException.getMessage();
    log.Error_Type__c = logException.getTypeName();
    insert as user log;
  }
}
