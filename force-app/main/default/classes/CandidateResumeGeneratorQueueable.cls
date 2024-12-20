/**
 * @description       : Queueable class to generate candidate resumes as PDFs and attach them to candidate records.
 * @last modified on  : 12-19-2024
 * @last modified by  : Swastik Dan
 **/
public with sharing class CandidateResumeGeneratorQueueable implements Queueable, Database.AllowsCallouts {
  private List<Id> candidateIds;

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
    System.debug(candidates + 'Candidates');
    // Create attachments for the candidates
    List<Attachment> attachments = createAttachments(candidates);

    if (attachments.size() > 0) {
      insert attachments;
    }
  }

  /**
   * @description : Creates attachments for the candidate records.
   * @author Swastik Dan | 11-27-2024
   * @param candidates
   * @return List<Attachment>
   **/
  private List<Attachment> createAttachments(List<Candidate__c> candidates) {
    List<Attachment> attachments = new List<Attachment>();
    Blob pdfBlob;
    for (Candidate__c candidate : candidates) {
      PageReference pdfPage = Page.CandidateResumePage;
      pdfPage.getParameters().put('id', candidate.Id);
      if (Test.isRunningTest()) {
        pdfBlob = Blob.valueOf('Mock PDF content');
      } else {
        pdfBlob = pdfPage.getContentAsPDF();
      }
      Attachment attachment = new Attachment(
        ParentId = candidate.Id,
        Name = candidate.First_Name__c +
          '_' +
          candidate.Last_Name__c +
          '_Resume_' +
          DateTime.now().format('yyyy-MM-dd_HH:mm:ss') +
          '.pdf',
        Body = pdfBlob,
        ContentType = 'application/pdf'
      );
      attachments.add(attachment);
    }
    return attachments;
  }

  /**
   * @description Queries the candidate records by their IDs.
   * @param candidateIds List of candidate IDs.
   * @return List of candidate records.
   **/
  private List<Candidate__c> getCandidateByIds(List<Id> candidateIds) {
    return [
      SELECT Id, First_Name__c, Last_Name__c
      FROM Candidate__c
      WHERE Id IN :candidateIds
      WITH USER_MODE
    ];
  }
}
