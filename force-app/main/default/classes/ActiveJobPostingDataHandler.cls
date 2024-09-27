/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-27-2024
 * @last modified by  : Swastik Dan
 * @history           :ß
 **/
public with sharing class ActiveJobPostingDataHandler {
  /**
   * @description
   * @author Swastik Dan | 09-27-2024
   * @param departmentQuery
   * @param startDate
   * @param endDate
   * @return List<Job_Posting__c>
   **/
  @AuraEnabled(cacheable=true)
  public static List<Job_Posting__c> getActiveJobPostings(
    String departmentQuery,
    String startDate,
    String endDate
  ) {
    String query = 'SELECT Id, Job_Name__c, Department__c, CreatedDate, Active__c FROM Job_Posting__c WHERE Active__c = TRUE';
    Map<String, Object> queryParams = new Map<String, Object>();

    if (!String.isBlank(departmentQuery)) {
      query += ' AND Department__c LIKE :departmentQuery';
      queryParams.put('departmentQuery', '%' + departmentQuery + '%');
    }
    if (!String.isBlank(startDate) && !String.isBlank(endDate)) {
      query += ' AND CreatedDate >= :startDate AND CreatedDate <= :endDate';
      queryParams.put('startDate', startDate + 'T00:00:00Z');
      queryParams.put('endDate', endDate + 'T00:00:00Z');
    }

    List<Job_Posting__c> jobPostingList = Database.queryWithBinds(
      query,
      queryParams,
      AccessLevel.USER_MODE
    );

    return jobPostingList;
  }
}
