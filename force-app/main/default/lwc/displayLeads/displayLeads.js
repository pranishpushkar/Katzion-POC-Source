import { LightningElement, track, wire } from 'lwc';
import getLeads from '@salesforce/apex/LeadController.getLeads';
import getLeadSources from '@salesforce/apex/LeadController.getLeadSources';
import syncSelectedLeads from '@salesforce/apex/SyncLeads.syncLeadsToTarget';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
        {label: 'Name', fieldName: 'Name', type: 'text'},
        {label: 'Company', fieldName: 'Company', type: 'text'},
        {label: 'Source', fieldName: 'LeadSource', type: 'text'},
        {label: 'Email', fieldName: 'Email', type: 'email'},
        {label: 'Phone', fieldName: 'Phone', type: 'Phone'},
];

export default class DisplayLeads extends LightningElement {

    columns= COLUMNS;
    @track leads= [];
    @track selectedLeadsIds = [];
    @track totalRecords = 0;
    @track isLoading = false;

    @track searchKey = '';
    @track leadSourceFilter = 'All';
    @track leadSourceOptions = [];

    @track pageSize = 10;
    @track pageNumber = 1;

    get isSyncDisabled(){
        return this.selectedLeadsIds.length === 0;
    }

    get pageSizeOptions(){
        return [
            {label: '5', value: 5},
            {label: '10', value: 10},
            {label: '20', value: 20},
            {label: '50', value: 50}
        ];
    }

    @wire(getLeadSources)
    wiredLeadSources({error,data}) {
        if(data){
            this.leadSourceOptions = data.map(source => ({
                label: source,
                value: source
            }));

        }else if(error){
            this.showToast('Error', error.body.message, 'error');
        }
    }
    connectedCallback(){
        this.fetchLeads();
    }

    fetchLeads(){
        this.isLoading = true;
        getLeads({
            pageSize: this.pageSize,
            pageNumber: this.pageNumber,
            searchKey: this.searchKey,
            leadSource: this.leadSourceFilter
        })
        .then(result => {
            this.leads = result.leads;
            this.totalRecords = result.totalRecords;
            this.pageSize = result.pageSize;
            this.pageNumber = result.pageNumber;
            this.isLoading = false;
        })
        .catch(error => {
            this.showToast('Error fetching lead records.', error.body.message, 'error');
            this.isLoading = false;
        });


    }

    handleRowSelection(event){
        this.selectedLeadsIds = event.detail.selectedRows.map(row => row.Id);
    }

    handleSearchChange(event){
        this.searchKey = event.target.value;
        this.pageNumber = 1;
        this.fetchLeads();

    }

    handleSourceChange(event){
        console.log('Inside Handle Source Change');
        this.leadSourceFilter = event.detail.value;
        console.log(event.detail.value);
        console.log(this.leadSourceFilter);
        this.pageNumber = 1;
        this.fetchLeads();
    }

    handlePageSizeChange(event){
        this.pageSize = parseInt(event.detail.value, 10);
        console.log(this.pageSize);
        this.pageNumber = 1;
        this.fetchLeads();
    }

    handlePrevious(){
        this.pageNumber = this.pageNumber - 1;
        this.fetchLeads();
    }

    handleNext(){
        console.log('Inside Display Leads Handle Next');
        this.pageNumber = this.pageNumber + 1;
        this.fetchLeads();
    }

    syncLeads(){
        if(this.selectedLeadsIds.length === 0){
            this.showToast('Warning','Please select at least one lead to sync.', 'warning');
            return;
        }
        this.isLoading = true;

        syncSelectedLeads({leadIds: this.selectedLeadsIds})
            .then(result => {
                this.showToast('Success', result, 'success');
            })
            .catch(error => {
                this.showToast('Sync Error', 'An error occurred during sync: '+ error.body.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showToast(title, message, variant){
        const event= new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    
}