import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import registerForWebinar from '@salesforce/apex/WebinarController.registerForWebinar';

export default class RegistrationModal extends LightningElement {
    @api webinarId;
    firstName;
    lastName;
    company;
    title;
    email;
    phone;

    handleSave() {
        const fieldsAreValid = this.checkFieldValidity();
        if (!fieldsAreValid) return;

        registerForWebinar({
            webinarId: this.webinarId,
            firstName: this.firstName,
            lastName: this.lastName,
            company: this.company,
            emailAddress: this.email,
            phoneNumber: this.phone,
            jobTitle: this.title
        })
            .then(() => {
                const event = new ShowToastEvent({
                    "title": "Success!",
                    "message": "You have successfully registered!",
                    "variant": "success"
                });
                this.dispatchEvent(event);
                this.handleClose();
            })
            .catch((error) => {
                console.error(error);
            });
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleFirstNameChange(evt) {
        this.firstName = evt.detail.value;
    }

    handleLastNameChange(evt) {
        this.lastName = evt.detail.value;
    }

    handleCompanyChange(evt) {
        this.company = evt.detail.value;
    }

    handleTitleChange(evt) {
        this.title = evt.detail.value;
    }

    handleEmailChange(evt) {
        this.email = evt.detail.value;
    }

    handlePhoneChange(evt) {
        this.phone = evt.detail.value;
    }

    checkFieldValidity() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        console.log('checking for cmp' + inputCmp);
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }
}