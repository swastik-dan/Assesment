/**
 * @description       : 
 * @author            : Swastik Dan
 * @group             : 
 * @last modified on  : 12-06-2024
 * @last modified by  : Swastik Dan
 * @history           : 
**/
OriginateUtility.UtilityWrapper objWrapper = new OriginateUtility.UtilityWrapper();
OriginateUtility objOrigUtility = new OriginateUtility();
Blob signedDocumentBody;
DocuSignGetEnvelopeDetailsCallout objGetEnvelopeCallout = new DocuSignGetEnvelopeDetailsCallout();
String childAppId='a72Pa000002D602';

objWrapper =  objOrigUtility.fetchDocuSignConstantData('TPO',
                                                        'Project Contract Signed');
if(objWrapper != NULL && objWrapper.docuSignAccountId != NULL && objWrapper.accessToken != NULL){
    DocuSignGetEnvelopeDetailsCallout.getSignedContract(objWrapper.docuSignAccountId, objWrapper.accessToken, '2c99fddd-66af-4780-92ba-979c64972900', childAppId, Label.Docusign_Solar_Power_Purchase_Agreement);
}