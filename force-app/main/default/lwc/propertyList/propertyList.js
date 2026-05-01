import { LightningElement, track } from 'lwc';
import getProperties from '@salesforce/apex/PropertyController.getProperties';

export default class PropertyList extends LightningElement {
    @track properties = [];
    @track currentPage = 1;
    @track totalPages = 1;
    @track totalCount = 0;
    @track maxPrice = null;
    @track availabilityStatus = '';
    @track furnishingStatus = '';

    pageSize = 25;

    statusOptions = [
        { label: 'All', value: '' },
        { label: 'Available', value: 'Available' },
        { label: 'Occupied', value: 'Occupied' }
    ];

    furnishingOptions = [
        { label: 'All', value: '' },
        { label: 'Furnished', value: 'Furnished' },
        { label: 'Semi-Furnished', value: 'Semi-Furnished' },
        { label: 'Unfurnished', value: 'Unfurnished' }
    ];

    connectedCallback() {
        this.loadProperties();
    }

    loadProperties() {
        getProperties({
            pageSize: this.pageSize,
            pageNumber: this.currentPage,
            maxPrice: this.maxPrice,
            availabilityStatus: this.availabilityStatus,
            furnishingStatus: this.furnishingStatus
        })
        .then(result => {
            this.properties = result.records;
            this.totalPages = result.totalPages;
            this.totalCount = result.totalCount;
        })
        .catch(error => {
            console.error('Error loading properties', error);
        });
    }

    get noRecords() {
        return this.properties.length === 0;
    }

    get isPrevDisabled() {
        return this.currentPage <= 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    handleMaxPrice(event) {
        this.maxPrice = event.target.value ? parseFloat(event.target.value) : null;
    }

    handleStatus(event) {
        this.availabilityStatus = event.detail.value;
    }

    handleFurnishing(event) {
        this.furnishingStatus = event.detail.value;
    }

    handleSearch() {
        this.currentPage = 1;
        this.loadProperties();
    }

    handleClear() {
        this.maxPrice = null;
        this.availabilityStatus = '';
        this.furnishingStatus = '';
        this.currentPage = 1;
        this.loadProperties();
    }

    handlePrev() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadProperties();
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadProperties();
        }
    }
}