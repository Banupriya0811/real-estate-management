import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTenants from '@salesforce/apex/TenantController.getTenants';
import createTenant from '@salesforce/apex/TenantController.createTenant';

export default class TenantList extends LightningElement {
    @track tenants = [];
    @track tenantName = '';
    @track phone = '';
    @track email = '';
    @track errorMessage = '';

    connectedCallback() {
        this.loadTenants();
    }

    loadTenants() {
        getTenants()
            .then(result => {
                this.tenants = result;
            })
            .catch(error => {
                console.error('Error loading tenants', error);
            });
    }

    get noTenants() {
        return this.tenants.length === 0;
    }

    handleTenantName(e) { this.tenantName = e.target.value; }
    handlePhone(e) { this.phone = e.target.value; }
    handleEmail(e) { this.email = e.target.value; }

    handleAddTenant() {
        this.errorMessage = '';
        if (!this.tenantName) {
            this.errorMessage = 'Tenant name is required.';
            return;
        }

        const tenant = {
            Name: this.tenantName,
            Phone__c: this.phone,
            Email__c: this.email
        };

        createTenant({ tenant })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Tenant added successfully.',
                    variant: 'success'
                }));
                this.tenantName = '';
                this.phone = '';
                this.email = '';
                this.loadTenants();
            })
            .catch(error => {
                this.errorMessage = 'Error: ' +
                    (error.body ? error.body.message : error.message);
            });
    }
}