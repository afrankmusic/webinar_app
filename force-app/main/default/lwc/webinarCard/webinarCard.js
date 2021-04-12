import { LightningElement, api, wire } from 'lwc';
import getWebinarById from '@salesforce/apex/WebinarController.getWebinarById';

export default class WebinarCard extends LightningElement {
    @api recordId;
    record; 
    showRegistrationModal = false;

    /** Retrieve information about the webinar */
    @wire(getWebinarById, {webinarId: '$recordId'})
    wiredWebinar({error, data}) {
        console.log('getting webinar for id: ' + this.recordId);
        if (error) {
            console.error(error);
        }

        if (data) {
            this.record = data;
        }
    }

    openRegistrationModal() {
        this.showRegistrationModal = true;
    }

    closeRegistrationModal() {
        this.showRegistrationModal = false;
    }

}