import { LightningElement, api, wire } from 'lwc';
import getWebinarById from '@salesforce/apex/WebinarController.getWebinarById';

export default class WebinarCard extends LightningElement {
    @api recordId;
    record; 

    /** Retrieve information about the webinar */
    @wire(getWebinarById, {webinarId: '$recordId'})
    wiredWebinar({error, data}) {
        if (error) {
            console.error(error);
        }

        if (data) {
            this.record = data;
        }
    }

}