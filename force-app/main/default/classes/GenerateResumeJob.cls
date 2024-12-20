/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-20-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class GenerateResumeJob {
  @InvocableMethod(
    label='Generate Resume'
    description='Generate resume for the selected candidates'
  )
  /**
   * @description
   * @author Swastik Dan | 12-04-2024
   * @param candidateIds
   **/
  public static void generateResumeJob(List<Id> candidateIds) {
    List<Id> candidateIdList = new List<Id>();

    for (String candidateId : candidateIds) {
      candidateIdList.addAll(candidateId.split(';'));
    }

    // Enqueue the job with the list of candidate IDs
    System.enqueueJob(new CandidateResumeGeneratorQueueable(candidateIdList));
  }
}
