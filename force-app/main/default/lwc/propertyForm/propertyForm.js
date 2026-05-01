import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createProperty from '@salesforce/apex/PropertyController.createProperty';

export default class PropertyForm extends LightningElement {
    @track name = '';
    @track address = '';
    @track city = '';
    @track state = '';
    @track postalCode = '';
    @track country = '';
    @track type = '';
    @track furnishingStatus = '';
    @track status = '';
    @track rent = null;
    @track description = '';
    @track recordId = null;
    @track imageUploaded = false;
    @track uploadedCount = 0;
    @track errorMessage = '';

    acceptedFormats = ['.jpg', '.jpeg', '.png', '.gif'];

    typeOptions = [
        { label: 'Residential', value: 'Residential' },
        { label: 'Commercial', value: 'Commercial' }
    ];

    furnishingOptions = [
        { label: 'Furnished', value: 'Furnished' },
        { label: 'Semi-Furnished', value: 'Semi-Furnished' },
        { label: 'Unfurnished', value: 'Unfurnished' }
    ];

    statusOptions = [
        { label: 'Available', value: 'Available' },
        { label: 'Occupied', value: 'Occupied' }
    ];

    handleName(e) { this.name = e.target.value; }
    handleAddress(e) { this.address = e.target.value; }
    handleCity(e) { this.city = e.target.value; }
    handleState(e) { this.state = e.target.value; }
    handlePostalCode(e) { this.postalCode = e.target.value; }
    handleCountry(e) { this.country = e.target.value; }
    handleType(e) { this.type = e.detail.value; }
    handleFurnishing(e) { this.furnishingStatus = e.detail.value; }
    handleStatus(e) { this.status = e.detail.value; }
    handleRent(e) { this.rent = e.target.value; }
    handleDescription(e) { this.description = e.target.value; }

    handleSave() {
        this.errorMessage = '';

        // Validate required fields
        if (!this.name || !this.address || !this.city || !this.state ||
            !this.postalCode || !this.country || !this.type ||
            !this.status || !this.rent || !this.description) {
            this.errorMessage = 'Please fill in all required fields.';
            return;
        }

        // Validate image is uploaded
        if (!this.imageUploaded) {
            this.errorMessage = 'Please upload at least one property image.';
            return;
        }

        const prop = {
            Name: this.name,
            Address__c: this.address,
            City__c: this.city,
            State__c: this.state,
            Postal_Code__c: this.postalCode,
            Country__c: this.country,
            Type__c: this.type,
            Furnishing_Status__c: this.furnishingStatus,
            Status__c: this.status,
            Rent__c: this.rent,
            Description__c: this.description
        };

        createProperty({ prop })
            .then(result => {
                this.recordId = result.Id;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Property created successfully.',
                    variant: 'success'
                }));
                this.handleClear();
            })
            .catch(error => {
                this.errorMessage = 'Error creating property: ' + error.body.message;
            });
    }

    handleUploadFinished(event) {
        const files = event.detail.files;
        this.uploadedCount = files.length;
        this.imageUploaded = true;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Images Uploaded!',
            message: files.length + ' image(s) uploaded successfully.',
            variant: 'success'
        }));
    }

    handleClear() {
        this.name = '';
        this.address = '';
        this.city = '';
        this.state = '';
        this.postalCode = '';
        this.country = '';
        this.type = '';
        this.furnishingStatus = '';
        this.status = '';
        this.rent = null;
        this.description = '';
        this.imageUploaded = false;
        this.uploadedCount = 0;
        this.errorMessage = '';
    }
}