@IsTest
private class LeadControllerTest{

    @TestSetup
    static void setupTestData(){
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(
            FirstName = 'Test',
            Lastname = 'Lead One',
            Company = 'Company A',
            LeadSource = 'Web',
            Email = 'xyz@gmail.com',
            Status = 'Open - Not Contacted' 
        ));

        leads.add(new Lead(
            FirstName = 'Test',
            Lastname = 'Lead Two',
            Company = 'Company B',
            LeadSource = 'Phone Inquiry',
            Email = 'abc@gmail.com',
            Status = 'Open - Not Contacted' 
        ));

        leads.add(new Lead(
            FirstName = 'Test',
            Lastname = 'Lead Three',
            Company = 'Company C',
            LeadSource = 'Web',
            Email = 'def@gmail.com',
            Status = 'Open - Not Contacted' 
        ));

        leads.add(new Lead(
            FirstName = 'Test',
            Lastname = 'Lead Four',
            Company = 'Company D',
            LeadSource = 'Web',
            Email = 'mno@gmail.com',
            Status = 'Open - Not Contacted' 
        ));

       insert leads; 
    }

    @isTest
    static void testgetLeadSources(){
        List<String> sources = LeadController.getLeadSources();

        System.assertNotEquals(null, sources, 'Lead sources list should not be null');
        System.assertEquals(true, sources.contains('All'), 'The list should contain "All"');
        System.assertEquals(true, sources.contains('Web'), 'The list should contain "Web"');
        System.assertEquals(true, sources.contains('Phone Inquiry'), 'The list should contain "Phone Inquiry"');
    }

    @isTest
    static void testGetLeads_AllSourceNoSearch(){

        Integer pageSize = 10;
        Integer pageNumber = 1;
        String searchKey = '';
        String leadSource = 'All';

        Map<String,Object> results = LeadController.getLeads(pageSize, pageNumber, searchKey, leadSource);

        List<Lead> leads = (List<Lead>) results.get('leads');
        Integer totalRecords = (Integer) results.get('totalRecords');

        System.assertEquals(4, leads.size(), 'Should return all 4 leads');
        System.assertEquals(4, totalRecords, 'Total record count should be 4');
    }

    @isTest
    static void testGetLeads_AllSourceWithSearch() {

    Integer pageSize = 10;
    Integer pageNumber = 1;

    String searchKey = 'Two';
    String leadSource = 'All';

    Map<String, Object> results = LeadController.getLeads (pageSize, pageNumber, searchkey, leadSource);

    List<Lead> leads = (List<Lead>) results.get ('leads');
    Integer totalRecords = (Integer) results.get('totalRecords');

    System.assertEquals(1, leads.size(), 'Should return only 1 lead matching the search key "Two". ');
    System.assertEquals('Test Lead Two', Leads[0].Name, 'The returned lead name should match the search criteria');
    System.assertEquals(4, totalRecords, 'Total record count should still be 4 regardless of search filter.');

    }

    @isTest
    static void testGetLeads_SpecificSourceNoSearch() {

    Integer pageSize = 10;
    Integer pageNumber = 1;
    String searchKey = null;
    String leadSource = 'Web';

    Map<String, Object> results = LeadController.getLeads(pageSize, pageNumber, searchKey, leadSource);

    List<Lead> leads = (List<Lead>) results.get('leads');
    Integer totalRecords = (Integer) results.get('totalRecords');

    System.assertEquals(3, leads.size(),'Should return 3 leads with LeadSource "Web". ');
    System.assertEquals(4, totalRecords,'Total record count should be 4.');

    for (Lead l : leads) {
    System.assertEquals( 'Web', l.LeadSource, 'All returned leads must have LeadSource "Web".');
    }
}
    @isTest
    static void testGetLeads_SpecificSourceWithSearch() {

    Integer pageSize = 10;
    Integer pageNumber = 1;
    String searchKey = 'One';
    String leadSource = 'Web';
    
    Map<String, Object> results = LeadController.getLeads(pageSize, pageNumber, searchKey, leadSource) ;
    
    List<Lead> leads = (List<Lead>) results.get ('leads');
    Integer totalRecords = (Integer) results.get ('totalRecords');

    System.assertEquals(1, leads.size(), 'Should return 1 lead matching both source "Web" and search "One". ');
    System.assertEquals('Test Lead One', leads[0].Name, 'The returned lead name should be "Test Lead One"');
    System.assertEquals(4, totalRecords, 'Total record count should be 4.');
    
}

    @isTest
    static void testGetLeads_PaginationPage2() {

    Integer pageSize = 2; 
    Integer pageNumber = 2; 
    String searchKey = '';
    String LeadSource = 'All';

    Map<String, Object> results = LeadController.getLeads (pageSize, pageNumber, searchKey, leadSource);
    
    List<Lead> leads = (List<Lead>) results.get('leads');
    Integer totalRecords = (Integer) results.get('totalRecords');
    
    System.assertEquals(2, leads.size(), 'Page 2 should return 2 leads.');
    System.assertEquals(4, totalRecords, 'Total record count should be 4.');
    System.assertEquals(2, (Integer) results.get('pageSize'), 'Page size should match the input.');
    System.assertEquals(2, (Integer) results.get('pageNumber'), 'Page number should match the input.');

    System.assertEquals(true, leads[0].Name.startsWith('Test'), 'First lead on page 2 should be "Test Lead Two".');
    System.assertEquals(true, leads[1].Name.startsWith('Test'), 'Second lead on page 2 should be "Test Lead One".');

}

    @isTest
    static void testGetLeads_NullInputs(){

    Integer pageSize = null; 
    Integer pageNumber = null; 
    String searchKey = null;
    String LeadSource = 'All';

    Map<String, Object> results = LeadController.getLeads (pageSize, pageNumber, searchKey, leadSource);

    List<Lead> leads = (List<Lead>) results.get('leads');
    Integer totalRecords = (Integer) results.get('totalRecords');

    System.assertEquals(4, leads.size(), 'Should return all 4 leads with default page size.');
    System.assertEquals(4, totalRecords, 'Total record count should be 4.');
}
}