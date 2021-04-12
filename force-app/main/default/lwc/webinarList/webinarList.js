import { LightningElement, wire } from 'lwc';
import getPublicWebinars from '@salesforce/apex/WebinarController.getPublicWebinars';

export default class WebinarList extends LightningElement {
    error;
    records;

    @wire(getPublicWebinars)
    wiredRecords({error, data}) {
        if (error) {
            console.error(error)
            this.error = error;
        }

        if (data) {
            console.log('retrievedData');
            console.log(data);
            this.records = data;
        }
    }
}