/**
 * @description       : Handles active job posting queriesss
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 12-22-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/

public with sharing class ActiveJobPostingDataHandler {
  // Constants for default time values
  private static final Integer DEFAULT_HOUR = 0;
  private static final Integer DEFAULT_MINUTE = 0;
  private static final Integer DEFAULT_SECOND = 0;

  /**
   * @description : Handles active job posting queries
   * @author Swastik Dan | 12-21-2024
   * @param departmentQuery
   * @param startDate
   * @param endDate
   * @return List<Job_Posting__c>
   **/
  @AuraEnabled(cacheable=true)
  public static List<Job_Posting__c> getActiveJobPostings(String departmentQuery, String startDate, String endDate) {
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
    List<Job_Posting__c> jobPostingList = Database.queryWithBinds(query, queryParams, AccessLevel.USER_MODE);

    return jobPostingList;
  }

  /**
   * @description : Converts a date string to a DateTime object with time set to 00:00:00
   * @param dateString The date string to convert
   * @return DateTime The DateTime object with the specified date and default time
   **/
  private static DateTime convertStringToDateTime(String dateString) {
    // Convert string to Date
    Date inputDate = Date.valueOf(dateString);

    // Return DateTime with time set to default values
    return DateTime.newInstance(
      inputDate.year(),
      inputDate.month(),
      inputDate.day(),
      DEFAULT_HOUR,
      DEFAULT_MINUTE,
      DEFAULT_SECOND
    );
  }
}

// /**
//  * @description       : Handles active job posting queries
//  * @author            : Swastik Dan
//  * @group             :
//  * @last modified on  : 10-08-2024
//  * @last modified by  : Swastik Dan
//  * @history           :
//  **/
// public with sharing class ActiveJobPostingDataHandler {
//   /**
//    * @description
//    * @author Swastik Dan | 10-08-2024
//    * @param departmentQuery
//    * @param startDate
//    * @param endDate
//    * @return List<Job_Posting__c>
//    **/
//   @AuraEnabled(cacheable=true)
//   public static List<Job_Posting__c> getActiveJobPostings(
//     String departmentQuery,
//     String startDate,
//     String endDate
//   ) {
//     // Base query
//     String query = 'SELECT Id, Job_Name__c, Department__c, CreatedDate, Active__c FROM Job_Posting__c WHERE Active__c = TRUE';
//     Map<String, Object> queryParams = new Map<String, Object>();

//     // Add department filter if provided
//     if (!String.isBlank(departmentQuery)) {
//       query += ' AND Department__c LIKE :departmentQuery';
//       queryParams.put('departmentQuery', '%' + departmentQuery + '%');
//     }

//     // Add date filters if provided
//     if (!String.isBlank(startDate) && !String.isBlank(endDate)) {
//       DateTime startDateTime = convertStringToDateTime(startDate);
//       DateTime endDateTime = convertStringToDateTime(endDate);

//       query += ' AND CreatedDate >= :startDate AND CreatedDate <= :endDate';
//       queryParams.put('startDate', startDateTime);
//       queryParams.put('endDate', endDateTime);
//     }

//     // Execute the query with bind parameters
//     List<Job_Posting__c> jobPostingList = Database.queryWithBinds(
//       query,
//       queryParams,
//       AccessLevel.USER_MODE
//     );

//     return jobPostingList;
//   }

//   /**
//    * @description
//    * @author Swastik Dan | 10-08-2024
//    * @param dateString
//    * @return DateTime
//    **/
//   private static DateTime convertStringToDateTime(String dateString) {
//     // Convert string to Date
//     Date inputDate = Date.valueOf(dateString);

//     // Return DateTime with time set to 00:00:00
//     return DateTime.newInstance(
//       inputDate.year(),
//       inputDate.month(),
//       inputDate.day(),
//       0,
//       0,
//       0
//     );
//   }
// }

