import { LightningElement, wire } from 'lwc';
import getPublicWebinars from '@salesforce/apex/WebinarController.getPublicWebinars';
import getWebinarTopics from '@salesforce/apex/Consts.getWebinarTopics';

export default class WebinarList extends LightningElement {
    error;
    recordIds;
    records;
    objectInfo;
    defaultRecordTypeId;
    webinarTopics = [];
    selectedTopics = [];
    searchTerm = '';

    @wire(getPublicWebinars, {topicFilter: '$selectedTopics', searchTerm: '$searchTerm'})
    wiredRecords(response) {
        const {error, data} = response;
        if (error) {
            console.error(error)
            this.error = error;
        }

        if (data) {
            this.records = data;
            this.recordIds = data.map((rec) => rec.Id);
        }
    }

    @wire(getWebinarTopics)
    wiredTopics({ error, data }) {
        if (error) {
            console.error(error);
        }
        if (data) {
            this.webinarTopics = data.map(topic => {
                    return {label: topic, value: topic}
                });
        }
    }

    handleTopicSelection(evt) {
        this.selectedTopics = evt.detail.value;
    }

    handleSearch(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.searchTerm = evt.target.value;
        }
    }
}