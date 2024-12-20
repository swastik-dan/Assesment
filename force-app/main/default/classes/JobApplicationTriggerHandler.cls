/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 11-27-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class JobApplicationTriggerHandler extends ExtendedTriggerHandler {
  private Map<Id, Job_Application__c> newJobApplicationMap;

  /**
   * @description
   * @author Swastik Dan | 10-26-2024
   **/
  public JobApplicationTriggerHandler() {
    this.newJobApplicationMap = (Map<Id, Job_Application__c>) Trigger.newMap;
  }

  /**
   * @description
   * @author Swastik Dan | 10-26-2024
   * @return boolean
   **/
  public override boolean isTriggerEnabled() {
    return sobject_Trigger_Manager__mdt.getInstance('JOB_APPLICATION_TRIGGER')
        .disableTrigger__c == true
      ? false
      : true;
  }

  /**
   * @description
   * @author Swastik Dan | 10-26-2024
   **/
  public override void afterUpdate() {
    List<Job_Application__c> jobApplications = fetchJobApplications(
      this.newJobApplicationMap
    );
    List<Id> candidateIdList = new List<Id>();
    for (Job_Application__c jobApplication : jobApplications) {
      if (jobApplication.Job_Application_Status__c == 'Shortlisted') {
        candidateIdList.add(jobApplication.Candidate__c);
      }
    }
    if (candidateIdList.size() > 0) {
      System.enqueueJob(new CandidateResumeGeneratorQueueable(candidateIdList));
    }
  }

  /**
   * @description
   * @author Swastik Dan | 10-26-2024
   * @param newJobApplicationMap
   * @return List<Job_Application__c>
   **/
  private List<Job_Application__c> fetchJobApplications(
    Map<Id, Job_Application__c> newJobApplicationMap
  ) {
    return [
      SELECT Id, Candidate__c, Job_Application_Status__c
      FROM Job_Application__c
      WHERE Id IN :newJobApplicationMap.keySet()
      WITH USER_MODE
    ];
  }
}
