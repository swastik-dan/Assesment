/**
 * @description       :
 * @author            : Swastik Dan
 * @group             :
 * @last modified on  : 11-08-2024
 * @last modified by  : Swastik Dan
 * @history           :
 **/
@isTest
global class MockResumePdfGenerator implements HttpCalloutMock {
  global Blob respond(HTTPRequest req) {
    // Create a fake response
    // HttpResponse res = new HttpResponse();
    // res.setHeader('Content-Type', 'application/pdf');
    // res.setBodyAsBlob(Blob.valueOf('Mock PDF content'));
    // res.setStatusCode(200);
    // return res;
    return Blob.valueOf('Test Blob');
  }
}
