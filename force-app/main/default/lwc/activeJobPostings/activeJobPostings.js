import { LightningElement, wire, track } from 'lwc';
import getActiveJobPostings from '@salesforce/apex/ActiveJobPostingDataHandler.getActiveJobPostings';

const columns = [
    { label: 'Job Title', fieldName: 'Job_Name__c', type: 'text' },
    { label: 'Job Location', fieldName: 'Location__c', type: 'text' },
    { label: 'Job Department', fieldName: 'Department__c', type: 'text' },
];

export default class ActiveJobPostings extends LightningElement {
    @track data;
    @track jobApplications;
    columns = columns;
    @track department ;
    @track startDate;
    @track endDate ;
    @track error;

    handleDepartmentChange(event) {
        this.department = event.target.value;
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }
    @wire(getActiveJobPostings, { departmentQuery: '$department', startDate: '$startDate', endDate: '$endDate' }) 
    wirejobPostings({ data, error }) {
        console.log('department: ' + this.department + ' startDate: ' + this.startDate + ' endDate: ' + this.endDate);
        if (data) {
            console.log(data);
            this.data = data;
            this.error = undefined;
        } else if (error) {
            console.log(error);
            this.error = error;
            this.data = undefined;
        }
    }

    connectedCallback() {
        console.log('connectedCallback');
      this.department = '';
        this.startDate = null;
        this.endDate = null;
    }

}