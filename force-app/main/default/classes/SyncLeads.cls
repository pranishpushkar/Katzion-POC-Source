public with sharing class SyncLeads {
    
    private static final String namedCredentialName = 'Katzion';
    private static final String endpoint = '/services/apexrest/LeadReceiver/';

    @AuraEnabled
    public static String SyncLeadsToTarget(List<Id> leadIds) {

        List<Lead> leadsToSync = [Select FirstName, LastName, Company, LeadSource, Email, Status, Rating from Lead where Id IN :leadIds];

        if(leadsToSync.isEmpty()){
            return 'No leads found to sync.';
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + namedCredentialName + endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(leadsToSync));

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode()== 200 || res.getStatusCode()== 201){

        return 'Successfully initiated sync for Selected Leads';
        }else{
            System.debug('Error'+res.getStatusCode()+' '+res.getBody());
            throw new AuraHandledException('Status Code: '+ res.getStatusCode()+ ' Response Body: '+ res.getBody());
        }

    }
}