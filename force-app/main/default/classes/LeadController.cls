public with sharing class LeadController {

    private static final Integer defaultPageSize = 10;

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLeads(Integer pageSize, Integer pageNumber, String searchKey,String leadSource){

        System.debug('Lead Source: '+leadSource);
        System.debug('Search Key: '+ searchKey);

        String query = 'Select Id, Name, Company, LeadSource, Email from Lead';

        if(leadSource == 'All'){
        if(searchKey != null && searchKey.length()>0){
            query += ' where Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\''; 
        }
        }else{
            if(searchKey == null){
                query += ' where LeadSource = \'' + String.escapeSingleQuotes(leadSource) + '\'';
            }
            else {
                query += ' where Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\'' + ' AND '+ 'LeadSource = \'' + String.escapeSingleQuotes(leadSource) + '\'';
            }
        }

        Integer totalRecordCount = Database.countQuery('Select count() from Lead');

        Integer limitSize = (pageSize != null && pageSize > 0) ? pageSize : defaultPageSize;
        Integer offset =(pageNumber != null && pageNumber > 1) ? (pageNumber-1)*limitSize : 0;

        query += ' ORDER BY Name ASC LIMIT ' + limitSize + ' OFFSET ' + offset;

        System.debug('***Printing Query: '+ query);

        List<Lead> leadsList = Database.query(query);
        
        Map<String,Object> results = new Map<String,Object>();
        results.put('leads',leadsList);
        results.put('totalRecords',totalRecordCount);
        results.put('pageSize',pageSize);
        results.put('pageNumber', pageNumber);

        System.debug('***Printing Map***'+ results);


        return results;

    }

    @AuraEnabled(cacheable=true)
    public static List<String> getLeadSources(){
        List<String> sources = new List<String>();
        sources.add('All');

        Schema.DescribeFieldResult fieldResult = Lead.LeadSource.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry p : ple){
            sources.add(p.getLabel());
        }
        return sources;
    }
    
}