/**
 * @description       : Handles active job posting queries
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 09-30-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
public with sharing class ActiveJobPostingDataHandler {
  /**
   * @description Get active job postings based on department, startDate, and endDate
   * @author Swastik Dan | 09-27-2024
   * @param departmentQuery
   * @param startDate (String in format 'yyyy-MM-dd')
   * @param endDate (String in format 'yyyy-MM-dd')
   * @return List<Job_Posting__c>
   **/
  @AuraEnabled(cacheable=true)
  public static List<Job_Posting__c> getActiveJobPostings(
    String departmentQuery,
    String startDate,
    String endDate
  ) {
    // Base query
    String query = 'SELECT Id, Job_Name__c, Department__c, CreatedDate, Active__c FROM Job_Posting__c WHERE Active__c = TRUE';
    Map<String, Object> queryParams = new Map<String, Object>();

    // Add department filter if provided
    if (!String.isBlank(departmentQuery)) {
      query += ' AND Department__c LIKE :departmentQuery';
      queryParams.put('departmentQuery', '%' + departmentQuery + '%');
    }

    // Add date filters if provided
    if (!String.isBlank(startDate) && !String.isBlank(endDate)) {
      DateTime startDateTime = convertStringToDateTime(startDate);
      DateTime endDateTime = convertStringToDateTime(endDate);

      query += ' AND CreatedDate >= :startDate AND CreatedDate <= :endDate';
      queryParams.put('startDate', startDateTime);
      queryParams.put('endDate', endDateTime);
    }

    // Execute the query with bind parameters
    List<Job_Posting__c> jobPostingList = Database.queryWithBinds(
      query,
      queryParams,
      AccessLevel.USER_MODE
    );

    return jobPostingList;
  }

  /**
   * @description Converts a date string (yyyy-MM-dd) to a DateTime with time set to 00:00:00
   * @param dateString Input date in String format (yyyy-MM-dd)
   * @return DateTime with time at 00:00:00
   **/
  private static DateTime convertStringToDateTime(String dateString) {
    // Convert string to Date
    Date inputDate = Date.valueOf(dateString);

    // Return DateTime with time set to 00:00:00
    return DateTime.newInstance(
      inputDate.year(),
      inputDate.month(),
      inputDate.day(),
      0,
      0,
      0
    );
  }
}
