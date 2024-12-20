/**
 * @description       :  Queueable class to generate candidate resumes as PDFs and attach them to candidate records.
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-20-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

public with sharing class CandidateResumeGeneratorQueueable implements Queueable, Database.AllowsCallouts {
  private List<Id> candidateIds;
  private static final String CANDIDATE_RESUME_PAGE = 'CandidateResumePage';
  private static final String CANDIDATE_ID_PARAMETER = 'id';
  private static final String PDF_CONTENT_TYPE = 'application/pdf';
  private static final String PDF_FILE_EXTENSION = '.pdf';
  private static final String PDF_FILE_NAME_DATE_FORMAT = 'yyyy-MM-dd_HH:mm:ss';
  private static final String MOCK_PDF_CONTENT = 'Mock PDF content';
  private static final String UNDERSCORE = '_';
  /**
   * @description Constructor to initialize the candidate IDs.
   * @param candidateIds List of candidate IDs for which resumes need to be generated.
   **/
  public CandidateResumeGeneratorQueueable(List<Id> candidateIds) {
    this.candidateIds = candidateIds;
  }

  /**
   * @description Executes the queueable job to generate PDFs and attach them to candidate records.
   * @param context Queueable context.
   **/
  public void execute(QueueableContext context) {
    // Query the candidate records
    List<Candidate__c> candidates = getCandidateByIds(candidateIds);
    List<Attachment> attachments = createAttachments(candidates);
    if (attachments.size() > 0) {
      insert attachments;
    }
  }

  /**
   * @description Creates attachments for the candidate records.
   * @param candidates List of candidate records.
   * @return List of attachments.
   **/
  private List<Attachment> createAttachments(List<Candidate__c> candidates) {
    List<Attachment> attachments = new List<Attachment>();
    Blob pdfBlob;
    for (Candidate__c candidate : candidates) {
      PageReference pdfPage = Page.CandidateResumePage;
      pdfPage.getParameters().put(CANDIDATE_ID_PARAMETER, candidate.Id);
      if (Test.isRunningTest()) {
        pdfBlob = Blob.valueOf(MOCK_PDF_CONTENT);
      } else {
        pdfBlob = pdfPage.getContentAsPDF();
      }
      String fileName =
        candidate.First_Name__c +
        UNDERSCORE +
        candidate.Last_Name__c +
        UNDERSCORE +
        DateTime.now().format(PDF_FILE_NAME_DATE_FORMAT) +
        PDF_FILE_EXTENSION;
      Attachment attachment = new Attachment(
        ParentId = candidate.Id,
        Name = fileName,
        Body = pdfBlob,
        ContentType = PDF_CONTENT_TYPE
      );
      attachments.add(attachment);
    }
    return attachments;
  }

  /**
   * @description Queries candidate records by their IDs.
   * @param candidateIds List of candidate IDs.
   * @return List of candidate records.
   **/
  private List<Candidate__c> getCandidateByIds(List<Id> candidateIds) {
    return [
      SELECT Id, First_Name__c, Last_Name__c
      FROM Candidate__c
      WHERE Id IN :candidateIds
    ];
  }
}

// /**
//  * @description       : Queueable class to generate candidate resumes as PDFs and attach them to candidate records.
//  * @last modified on  : 12-20-2024
//  * @last modified by  : Swastik Dan
//  **/
// public with sharing class CandidateResumeGeneratorQueueable implements Queueable {

//   private List<Id> candidateIds;

//   /**
//    * @description Constructor to initialize the candidate IDs.
//    * @param candidateIds List of candidate IDs for which resumes need to be generated.
//    **/
//   public CandidateResumeGeneratorQueueable(List<Id> candidateIds) {
//     this.candidateIds = candidateIds;
//   }

//   /**
//    * @description Executes the queueable job to generate PDFs and attach them to candidate records.
//    * @param context Queueable context.
//    **/
//   public void execute(QueueableContext context) {
//     // Query the candidate records
//     List<Candidate__c> candidates = getCandidateByIds(candidateIds);

//     List<Attachment> attachments = createAttachments(candidates);

//     if (attachments.size() > 0) {
//       insert attachments;
//     }
//   }

//   /**
//    * @description : Creates attachments for the candidate records.
//    * @author Swastik Dan | 11-27-2024
//    * @param candidates
//    * @return List<Attachment>
//    **/
//   private List<Attachment> createAttachments(List<Candidate__c> candidates) {
//     List<Attachment> attachments = new List<Attachment>();
//     Blob pdfBlob;
//     for (Candidate__c candidate : candidates) {
//       PageReference pdfPage = Page.CandidateResumePage;
//       pdfPage.getParameters().put('id', candidate.Id);
//       if (Test.isRunningTest()) {
//         pdfBlob = Blob.valueOf('Mock PDF content');
//       } else {
//         pdfBlob = pdfPage.getContentAsPDF();
//       }
//       Attachment attachment = new Attachment(
//         ParentId = candidate.Id,
//         Name = candidate.First_Name__c +
//           '_' +
//           candidate.Last_Name__c +
//           '_Resume_' +
//           DateTime.now().format('yyyy-MM-dd_HH:mm:ss') +
//           '.pdf',
//         Body = pdfBlob,
//         ContentType = 'application/pdf'
//       );
//       attachments.add(attachment);
//     }
//     return attachments;
//   }

//   /**
//    * @description Queries the candidate records by their IDs.
//    * @param candidateIds List of candidate IDs.
//    * @return List of candidate records.
//    **/
//   private List<Candidate__c> getCandidateByIds(List<Id> candidateIds) {
//     return [
//       SELECT Id, First_Name__c, Last_Name__c
//       FROM Candidate__c
//       WHERE Id IN :candidateIds
//       WITH USER_MODE
//     ];
//   }
// }

