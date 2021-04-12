import { LightningElement, api } from 'lwc';
import registerForWebinar from '@salesforce/apex/WebinarController.registerForWebinar';

export default class RegistrationModal extends LightningElement {
    @api webinarId = "a008A000004S47KQAS";
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
                console.log('success! Soon to be toast mesage');
                this.handleClose();
            })
            .catch((error) => {
                console.log('error occured');
                console.log(error);
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
        console.log('checking validity');
        console.log(this.template.querySelectorAll('lightning-input'));
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        console.log('checking for cmp' + inputCmp);
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        console.log('all valid? ' + allValid);
        return allValid;
    }
}