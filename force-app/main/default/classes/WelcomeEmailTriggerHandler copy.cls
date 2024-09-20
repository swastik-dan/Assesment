/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-20-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class WelcomeEmailTriggerHandler extends TriggerHandler {
  List<Candidate__c> newCandidateList;
  public WelcomeEmailTriggerHandler() {
    this.newCandidateList = (List<Candidate__c>) Trigger.new;
    this.setMaxLoopCount(1);
  }

  public override void beforeInsert() {
    List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
    List<Contact> contactsToInsert = new List<Contact>();
    Map<String, Contact> emailToContactMap = new Map<String, Contact>();

    // Query the email template outside the loop
    EmailTemplate template = [
      SELECT Id
      FROM EmailTemplate
      WHERE Name = 'Candidate Welcome Email Template'
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    // Query existing contacts
    Set<String> candidateEmails = new Set<String>();
    for (Candidate__c candidate : this.newCandidateList) {
      candidateEmails.add(candidate.Email__c);
    }

    if (Schema.sObjectType.Contact.isAccessible()) {
      for (Contact contact : [
        SELECT Id, Email
        FROM Contact
        WHERE Email IN :candidateEmails
        WITH SECURITY_ENFORCED
      ]) {
        emailToContactMap.put(contact.Email, contact);
      }
    } else {
      throw new InsufficientPrivilegesException(
        'You do not have access to the Contact object'
      );
    }

    for (Candidate__c candidate : this.newCandidateList) {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setTemplateId(template.Id);

      Contact associatedContact = emailToContactMap.get(candidate.Email__c);

      if (associatedContact != null) {
        email.setTargetObjectId(associatedContact.Id);
      } else {
        Contact contact = new Contact(
          Email = candidate.Email__c,
          FirstName = candidate.First_Name__c,
          LastName = candidate.Last_Name__c
        );
        insert contact;
        email.setTargetObjectId(candidate.Contact__c);
      }
      //
      //List<String> toAddresses = new List<String> { candidate.Email__c };
      //email.setToAddresses(toAddresses);
      email.setWhatId(candidate.Id);
      emailToSend.add(email);
    }

    // Insert new contacts outside the loop
    if (!contactsToInsert.isEmpty()) {
      insert contactsToInsert;
    }

    if (!emailToSend.isEmpty()) {
      Messaging.sendEmail(emailToSend);
    }
  }
}
// public with sharing class WelcomeEmailTriggerHandler extends TriggerHandler {
//   List<Candidate__c> newCandidate;

//   public WelcomeEmailTriggerHandler() {
//     this.newCandidate = (List<Candidate__c>) Trigger.new;
//     this.setMaxLoopCount(1);
//   }
//   public override void beforeInsert() {
//     List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
//     List<Contact> contactsToInsert = new List<Contact>();

//     EmailTemplate template = [
//       SELECT Id
//       FROM EmailTemplate
//       WHERE Name = 'Candidate Welcome Email Template'
//       WITH SECURITY_ENFORCED
//       LIMIT 1
//     ];

//     // All the new candidates that do not have a contact
//     for (Candidate__c candidate : newCandidate) {
//       if (candidate.Contact__c == null) {
//         Contact candidateContact = new Contact(
//           FirstName = candidate.First_Name__c,
//           LastName = candidate.Last_Name__c,
//           Email = candidate.Email__c,
//           Candidate__c = candidate.Id
//         );
//         contactsToInsert.add(candidateContact);
//       }
//     }
//     if (!contactsToInsert.isEmpty()) {
//       insert contactsToInsert;
//     }

//     // Extract email addresses from newCandidate list
//     Set<String> candidateEmails = new Set<String>();
//     for (Candidate__c candidate : newCandidate) {
//       candidateEmails.add(candidate.Email__c);
//     }

//     // Query updated candidates using the extracted email addresses
//     List<Candidate__c> updatedCandidate = [
//       SELECT Id, Contact__c, Email__c
//       FROM Candidate__c
//       WHERE Email__c IN :candidateEmails
//       WITH SECURITY_ENFORCED
//     ];

//     for (Candidate__c candidate : updatedCandidate) {
//       Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//       email.setTemplateId(template.Id);
//       email.setTargetObjectId(candidate.Contact__c);
//       List<String> toAddresses = new List<String>{ candidate.Email__c };
//       email.setToAddresses(toAddresses);
//       email.setWhatId(candidate.Id);
//       emailToSend.add(email);
//     }

//     if (!emailToSend.isEmpty()) {
//       Messaging.sendEmail(emailToSend);
//     }
//   }
// }

/*
public with sharing class WelcomeEmailTriggerHandler extends TriggerHandler {
  List<Candidate__c> newCandidateList;
  public WelcomeEmailTriggerHandler() {
    this.newCandidateList = (List<Candidate__c>) Trigger.new;
    this.setMaxLoopCount(1);
  }

  public override void beforeInsert() {
    List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
    List<Contact> contactsToInsert = new List<Contact>();
    Map<String, Contact> emailToContactMap = new Map<String, Contact>();


    // Query the email template outside the loop
    EmailTemplate template = [
      SELECT Id
      FROM EmailTemplate
      WHERE Name = 'Candidate Welcome Email Template'
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    // Query existing contacts
    Set<String> candidateEmails = new Set<String>();
    for (Candidate__c candidate : this.newCandidateList) {
      candidateEmails.add(candidate.Email__c);
    }

    if (Schema.sObjectType.Contact.isAccessible()) {
      for (Contact contact : [
          SELECT Id, Email
          FROM Contact

         
          WHERE Email IN :candidateEmails
          WITH SECURITY_ENFORCED
      ]) {
          emailToContactMap.put(contact.Email, contact);
      }
  } else {

    throw new InsufficientPrivilegesException('You do not have access to the Contact object');
     
  }

    for (Candidate__c candidate : this.newCandidateList) {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setTemplateId(template.Id);
  
      Contact associatedContact = emailToContactMap.get(candidate.Email__c);
  
      if (associatedContact != null) {
          email.setTargetObjectId(associatedContact.Id);
      } else {
          Contact contact = new Contact(
              Email = candidate.Email__c,
              FirstName = candidate.First_Name__c,
              LastName = candidate.Last_Name__c
          );
          insert contact; 
          email.setTargetObjectId(contact.Id);
      }
      // 
      //List<String> toAddresses = new List<String> { candidate.Email__c };
      //email.setToAddresses(toAddresses);
      email.setWhatId(candidate.Id);
      emailToSend.add(email);
  }

    // Insert new contacts outside the loop
    if (!contactsToInsert.isEmpty()) {
      insert contactsToInsert;
    }

    if (!emailToSend.isEmpty()) {
      Messaging.sendEmail(emailToSend);
    }
  }
}
*/

//  public override void beforeInsert() {
//     List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
//     List<Contact> contactsToInsert = new List<Contact>();
//     Map<String, Contact> emailToContactMap = new Map<String, Contact>();
//     // Email Template Query
//     EmailTemplate template = [
//       SELECT Id
//       FROM EmailTemplate
//       WHERE Name = 'Candidate Welcome Email Template'
//       WITH SECURITY_ENFORCED
//       LIMIT 1
//     ];
//     for (Candidate__c candidate : newCandidate) {
//       if (candidate.Contact__c == null) {
//         Contact candidateContact = new Contact(
//           FirstName = candidate.First_Name__c,
//           LastName = candidate.Last_Name__c,
//           Email = candidate.Email__c,
//           Candidate__c = candidate.Id
//         );
//         contactsToInsert.add(candidateContact);
//       }
//     }

//     if (Schema.sObjectType.Contact.isAccessible()) {
//       for (Contact contact : [
//         SELECT Id, Email
//         FROM Contact
//         WHERE Email IN :newCandidate
//         WITH SECURITY_ENFORCED
//       ]) {
//         emailToContactMap.put(contact.Email, contact);
//       }
//     } else {
//       throw new InsufficientPrivilegesException(
//         'You do not have access to the Contact object'
//       );
//     }

//     for (Candidate__c candidate : newCandidate) {
//       Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//       email.setTemplateId(template.Id);
//       Contact associatedContact = emailToContactMap.get(candidate.Email__c);
//       if (associatedContact != null) {
//         email.setTargetObjectId(associatedContact.Id);
//       } else {
//         Contact contact = new Contact(
//           Email = candidate.Email__c,
//           FirstName = candidate.First_Name__c,
//           LastName = candidate.Last_Name__c
//         );
//         insert contact;
//         email.setTargetObjectId(contact.Id);
//       }
//       email.setWhatId(candidate.Id);
//       emailsToSend.add(email);
//     }

//     if (!contactsToInsert.isEmpty()) {
//       insert contactsToInsert;
//     }

//     if (!emailsToSend.isEmpty()) {
//       Messaging.sendEmail(emailsToSend);
//     }

//     // try {
//     //   if (Schema.sObjectType.Contact.isCreateable()) {
//     //     insert contactsToInsert;
//     //   } else {
//     //     throw new DmlException('You do not have access to the Contact object');
//     //   }
//     // } catch (DmlException e) {
//     //   System.debug('Error: ' + e.getMessage());
//     // }

//     // List<String> candidateEmails = new List<String>{};
//     // for (Candidate__c candidate : newCandidate) {
//     //   candidateEmails.add(candidate.Email__c);
//     // }

//     // List<Candidate__c> updatedCandidate = [
//     //   SELECT Id, Contact__c, Email__c
//     //   FROM Candidate__c
//     //   WHERE Email__c IN :candidateEmails
//     //   WITH SECURITY_ENFORCED
//     // ];

//     // for (Candidate__c candidate : updatedCandidate) {
//     //   Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//     //   email.setTemplateId(template.Id);
//     //   email.setTargetObjectId(candidate.Contact__c);
//     //   email.setWhatId(candidate.Id);
//     //   emailsToSend.add(email);
//     // }

//     // try {
//     //   if (!emailsToSend.isEmpty()) {
//     //     Messaging.sendEmail(emailsToSend);
//     //   }
//     // } catch (Exception e) {
//     //   System.debug('Error: ' + e.getMessage());
//     // }
//   }

/// new

//  * @description       :  Handler class for Welcome Email Trigger Handler to create contact records and send welcome email to the candidates on insert of candidate records
//  * @author            : Swastik Dan
//  * @group             :
//  * @last modified on  : 09-20-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/
// public with sharing class CandidateTriggerHandler extends TriggerHandler {
//   private List<Candidate__c> newCandidateList;

//   public CandidateTriggerHandler() {
//     this.newCandidateList = (List<Candidate__c>) Trigger.new;
//     this.setMaxLoopCount(1);
//   }

//   /**
//    * @description : Method to create contact records and send welcome email to the candidates on insert of candidate records
//    * @author Swastik Dan | 09-20-2024
//    **/

//   public override void beforeInsert() {
//     List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
//     List<String> candidateEmails = new List<String>();
//     Map<String, Id> emailToContactIdMap = new Map<String, Id>();
//     List<Contact> contactsToInsert = new List<Contact>();
//     try {
//       // Get all the emails from the new candidate list
//       for (Candidate__c candidate : newCandidateList) {
//         candidateEmails.add(candidate.Email__c);
//       }

//       // Get all the contacts with the same email as the candidate
//       List<Contact> existingContacts = [
//         SELECT Id, Email
//         FROM Contact
//         WHERE Email IN :candidateEmails
//         WITH USER_MODE
//       ];

//       // Create a map of email to contact id
//       for (Contact contact : existingContacts) {
//         emailToContactIdMap.put(contact.Email, contact.Id);
//       }

//       // Create a list of contacts to insert

//       for (Candidate__c candidate : newCandidateList) {
//         // If the email already exists in the contact list, then set the contact id
//         if (emailToContactIdMap.containsKey(candidate.Email__c)) {
//           candidate.Contact__c = emailToContactIdMap.get(candidate.Email__c);
//         } else {
//           // If the email does not exist in the contact list, then create a new contact
//           contactsToInsert.add(createContactFromCandidate(candidate));
//         }
//       }
//       // Insert the contacts
//       if (!contactsToInsert.isEmpty()) {
//         insert as user contactsToInsert;
//       }
//       // Create a map of email to contact id for the newly inserted contacts
//       for (Contact contact : contactsToInsert) {
//         emailToContactIdMap.put(contact.Email, contact.Id);
//       }

//       // Set the contact id for the candidates
//       for (Candidate__c candidate : newCandidateList) {
//         if (candidate.Contact__c == null) {
//           candidate.Contact__c = emailToContactIdMap.get(candidate.Email__c);
//         }
//       }

//       // Get the email template
//       EmailTemplate emailTemplate = [
//         SELECT Id
//         FROM EmailTemplate
//         WHERE DeveloperName = 'Candidate_Welcome_Email_Template'
//         WITH SECURITY_ENFORCED
//         LIMIT 1
//       ];

//       // Create the email messages
//       for (Candidate__c candidate : newCandidateList) {
//         if (candidate.Contact__c != null) {
//           Messaging.SingleEmailMessage email = createEmailMessage(
//             candidate,
//             emailTemplate.Id
//           );
//           emailToSend.add(email);
//         }
//       }

//       Messaging.sendEmail(emailToSend);
//     } catch (Exception e) {
//       Log__c log = new Log__c();
//       log.Log_Message__c = e.getMessage();
//       log.Error_Type__c = e.getTypeName();
//       insert as user log;
//     }
//   }

//   // create new contact record
//   private Contact createContactFromCandidate(Candidate__c candidate) {
//     Contact contact = new Contact();
//     contact.FirstName = candidate.First_Name__c;
//     contact.LastName = candidate.Last_Name__c;
//     contact.Email = candidate.Email__c;
//     return contact;
//   }

//   // single email message creation
//   private Messaging.SingleEmailMessage createEmailMessage(
//     Candidate__c candidate,
//     Id templateId,
//     Map<String, Id> emailToContactIdMap
//   ) {
//     Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//     email.setTemplateId(templateId);
//     //email.setTargetObjectId(emailToContactIdMap.get(candidate.Email__c));
//     email.setTargetObjectId(candidate.Contact__c);
//     email.setSaveAsActivity(false);
//     email.setWhatId(candidate.Id);
//     return email;
//   }

//   // public override void beforeInsert() {
//   //   List<Contact> contactList = new List<Contact>();
//   //   try {
//   //     for (Candidate__c candidate : newCandidateList) {
//   //       Contact contact = new Contact();
//   //       contact.FirstName = candidate.First_Name__c;
//   //       contact.LastName = candidate.Last_Name__c;
//   //       contact.Email = candidate.Email__c;
//   //       contactList.add(contact);
//   //     }

//   //     if (!Schema.sObjectType.Contact.isCreateable()) {
//   //       throw new WelcomeEmailTriggerHandlerException(
//   //         'Contact object is not createable'
//   //       );
//   //     }
//   //     insert as user contactList;
//   //     // if (Schema.sObjectType.Contact.isCreateable()) {
//   //     //   insert contactList;
//   //     // }

//   //     List<EmailTemplate> emailTemplate = [
//   //       SELECT Id
//   //       FROM EmailTemplate
//   //       WHERE DeveloperName = 'Candidate_Welcome_Email_Template'
//   //       WITH SECURITY_ENFORCED
//   //       LIMIT 1
//   //     ];

//   //     List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
//   //     for (Contact contact : contactList) {
//   //       Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//   //       email.setTemplateId(emailTemplate[0].Id);
//   //       email.setTargetObjectId(contact.Id);
//   //       email.setSaveAsActivity(false);
//   //       email.setWhatId(contact.Id);
//   //       emails.add(email);
//   //     }
//   //     Messaging.sendEmail(emails);
//   //   } catch (Exception e) {
//   //     System.debug('Exception: ' + e.getMessage());
//   //   }
//   // }
// }
