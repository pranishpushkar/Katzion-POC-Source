@isTest
private class SyncLeadsTest{

    private class MockSuccessfullCallout implements HttpCalloutMock{

    private Integer statusCode;

    public MockSuccessfullCallout(Integer code){
        this.statusCode = code;
    }

    public HttpResponse respond(HttpRequest req){
        System.assert(req.getEndpoint().contains('callout:Katzion'), 'Endpoint should use the Named Credential.');
        System.assertEquals('POST', req.getMethod(), 'Method should be POST.');

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "OK", "message": "Leads processed"}');
        res.setStatusCode(this.statusCode);
        return res;
    } 
}

    private class MockFailedCallout implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": "Invalid request payload."}');
            res.setStatusCode(400);
            return res;
        }
    }

    @testSetup
    static void setupTestData(){
        List<Lead> testLeads = new List<Lead>();

        for(Integer i = 0; i < 200; i++){
            testLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead' + i,
                Company = 'TestCorp' + i,
                Email = 'test' + i + '@gmail.com',
                Status = 'New',
                LeadSource = 'Web' 
            ));
        }
        insert testLeads;

    }

    @isTest
    static void testSyncLeads_Success200(){

        List<Id> leadIds = new List<Id>();
        for(Lead l : [Select Id from Lead LIMIT 5]){
            leadIds.add(l.Id);
        }
        System.assertNotEquals(0, leadIds.size(), 'Pre-condition failed: Must retrieve at least one Lead Id from setup.');

        String result;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSuccessfullCallout(200));

        result = SyncLeads.syncLeadsToTarget(leadIds);
        Test.stopTest();

        System.assertEquals('Successfully initiated sync for Selected Leads', result, 'The 200 response should return the success message.');
    }

    @isTest
    static void testSyncLeads_Success201(){

        List<Id> leadIds = new List<Id>();
        for(Lead l : [Select Id from Lead LIMIT 5]){
            leadIds.add(l.Id);
        }
        System.assertNotEquals(0, leadIds.size(), 'Pre-condition failed: Must retrieve at least one Lead Id from setup.');

        String result;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSuccessfullCallout(201));

        result = SyncLeads.syncLeadsToTarget(leadIds);
        Test.stopTest();

        System.assertEquals('Successfully initiated sync for Selected Leads', result, 'The 201 response should return the success message.');
    }

    @isTest
    static void testSyncLeads_NoLeadsFound(){

        List<Id> emptyLeadIdList = new List<Id>();

        String result;
        Test.startTest();
        result = SyncLeads.syncLeadsToTarget(emptyLeadIdList);
        Test.stopTest();

        System.assertEquals('No leads found to sync.', result, 'Should return the no leads message when the list is empty');
    }

    @isTest
    static void testSyncLeads_Failure(){

        List<Id> leadIds = new List<Id>();
        for(Lead l : [Select Id from Lead LIMIT 5]){
            leadIds.add(l.Id);
        }

        System.assertNotEquals(0, leadIds.size(), 'Pre-condition failed: Must retrieve at least one lead from setup.');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockFailedCallout());

        try{
            SyncLeads.syncLeadsToTarget(leadIds);
            System.assert(false, 'Expected AuraHandledException, but method finished successfully.');
        } catch(AuraHandledException e){
            System.assert(e.getMessage().contains('Status Code: 400'), 'Exception message should contain the failure code 400.');

        } catch(Exception e){
            System.assert(false, 'Caught an unexpected exception: ' + e.getTypeName() + '. Expected AuraHandled Exception.');
        }
        
        Test.stopTest();


    }


}