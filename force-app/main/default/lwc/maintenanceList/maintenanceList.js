import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMaintenanceRequests from '@salesforce/apex/MaintenanceController.getMaintenanceRequests';
import createRequest from '@salesforce/apex/MaintenanceController.createRequest';
import getProperties from '@salesforce/apex/PropertyController.getProperties';

export default class MaintenanceList extends LightningElement {
    @track requests = [];
    @track propertyOptions = [];
    @track selectedProperty = '';
    @track description = '';
    @track errorMessage = '';

    connectedCallback() {
        this.loadRequests();
        this.loadProperties();
    }

    loadRequests() {
        getMaintenanceRequests()
            .then(result => { this.requests = result; })
            .catch(error => { console.error('Error loading requests', error); });
    }

    loadProperties() {
        getProperties({
            pageSize: 200,
            pageNumber: 1,
            maxPrice: null,
            availabilityStatus: '',
            furnishingStatus: ''
        })
        .then(result => {
            this.propertyOptions = result.records.map(p => ({
                label: p.Name,
                value: p.Id
            }));
        })
        .catch(error => { console.error('Error loading properties', error); });
    }

    get noRequests() { return this.requests.length === 0; }

    handleProperty(e) { this.selectedProperty = e.detail.value; }
    handleDescription(e) { this.description = e.target.value; }

    handleSubmit() {
        this.errorMessage = '';
        if (!this.selectedProperty || !this.description) {
            this.errorMessage = 'Please select a property and enter description.';
            return;
        }

        const req = {
            Property__c: this.selectedProperty,
            Description__c: this.description,
            Status__c: 'Open'
        };

        createRequest({ req })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Maintenance request submitted. Vendor auto-assigned!',
                    variant: 'success'
                }));
                this.selectedProperty = '';
                this.description = '';
                this.loadRequests();
            })
            .catch(error => {
                this.errorMessage = 'Error: ' +
                    (error.body ? error.body.message : error.message);
            });
    }
}