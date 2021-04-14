import { LightningElement, api, wire } from 'lwc';

export default class WebinarCard extends LightningElement {
    @api recordId;
    @api record; 
    showRegistrationModal = false;

    openRegistrationModal() {
        this.showRegistrationModal = true;
    }

    closeRegistrationModal() {
        this.showRegistrationModal = false;
    }

    get webinarTopics() {
        return this.record.Topics__c.split(';');
    }
}