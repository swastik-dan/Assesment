/**
 * @description       :  Queueable class to generate candidate resumes as PDFs and attach them to candidate records.
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
   * @description : Method to generate candidate resumes as PDFs and attach them to candidate records.s
   * @author Swastik Dan | 12-20-2024
   * @param candidateIds
   **/
  public static void generateResume(List<Id> candidateIds) {
    List<Id> candidateIdList = new List<Id>();
    // Loop through the candidate IDs and add them to the list because Its coming like ('Id1;Id2;Id3')
    for (String candidateId : candidateIds) {
      candidateIdList.addAll(candidateId.split(';'));
    }
    // Enqueue the job with the list of candidate IDs
    System.enqueueJob(new CandidateResumeGeneratorQueueable(candidateIdList));
  }
}

// /**
//  * @description       :
//  * @author            : Swastik Dan
//  * @group             :
//  * @last modified on  : 12-20-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/
// public with sharing class GenerateResumeJob {
//   @InvocableMethod(
//     label='Generate Resume'
//     description='Generate resume for the selected candidates'
//   )
//   /**
//    * @description
//    * @author Swastik Dan | 12-04-2024
//    * @param candidateIds
//    **/
//   public static void generateResumeJob(List<Id> candidateIds) {
//     List<Id> candidateIdList = new List<Id>();

//     for (String candidateId : candidateIds) {
//       candidateIdList.addAll(candidateId.split(';'));
//     }

//     // Enqueue the job with the list of candidate IDs
//     System.enqueueJob(new CandidateResumeGeneratorQueueable(candidateIdList));
//   }
// }

