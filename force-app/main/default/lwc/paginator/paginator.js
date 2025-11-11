import { LightningElement, api } from 'lwc';

export default class Paginator extends LightningElement {

    @api pageNumber;
    @api totalRecords;
    @api pageSize;

    get totalPages() {
        if (this.totalRecords > 0 && this.pageSize > 0) {
            return Math.ceil(this.totalRecords / this.pageSize);
        }
        return 1;
    }

    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    previousHandler() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    nextHandler() {
        console.log('inside paginator next handler');
        this.dispatchEvent(new CustomEvent('next'));
    }
}