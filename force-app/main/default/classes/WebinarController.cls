public with sharing class WebinarController {
    
    /**
     * Gets all public webinars
     */
    @AuraEnabled(cacheable=true)
    public static Webinar__c[] getPublicWebinars(){
        try {
            Webinar__c[] webinars = [
                SELECT Id,
                Name,
                StartTime__c,
                Duration__c,
                Description__c,
                Campaign__c
                FROM Webinar__c
                WHERE IsPublic__c = true
                AND StartTime__c > :System.now()
                ORDER BY StartTime__c ASC
            ];
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, webinars); // enforce field-level security
            return securityDecision.getRecords();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Gets a single webinar given the webinar id
     */
    @AuraEnabled(cacheable=true)
    public static Webinar__c getWebinarById(Id webinarId) {
        try {
            return [
                SELECT Id,
                Name,
                StartTime__c,
                Duration__c,
                Description__c,
                Owner.Name,
                Campaign__c
                FROM Webinar__c
                WHERE Id = :webinarId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Takes input from an anonymous form to create a lead, then adds that lead to the list of registrants for the
     * webinar and includes them in the related marketing campaign
     */
    @AuraEnabled
    public static void registerForWebinar(Id webinarId, String firstName, String lastName, String company, String emailAddress, String phoneNumber, String jobTitle) {
        try {
            Webinar__c webinar = getWebinarById(webinarId);

            if (webinarIsExpired(webinar)) {
                throw new AuraHandledException('Unable to register since this webinar has already ended.');
            }

            Lead newLead = createLead(firstName, lastName, company, emailAddress, phoneNumber, jobTitle);
            if (webinar.Campaign__c != null) {
                createCampaignMember(webinar.Campaign__c, newLead.Id);
            }

            createWebinarRegistrant(webinar.Id, newLead.Id);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Checks to see if the webinar has already passed it's date
     */
    private static Boolean webinarIsExpired(Webinar__c webinar) {
        return webinar.StartTime__c < System.now();
    }

    /**
     * Creates a new lead given inputs from a web form
     */
    private static Lead createLead(String firstName, String lastName, String company, String emailAddress, String phoneNumber, String jobTitle) {
        Lead newLead = new Lead(
            FirstName = firstName,
            LastName = lastName,
            Company = company,
            Title = jobTitle,
            Email = emailAddress,
            Phone = phoneNumber
        );
        insert newLead;
        return newLead;
    }

    /**
     * Checks for existing campaign membership for a lead, and then
     * if none, will create a CampaignMember
     */
    private static void createCampaignMember(Id campaignId, Id leadId) {
        CampaignMember[] existingCampaignMember = [
            SELECT Id FROM CampaignMember WHERE CampaignId = :campaignId AND LeadId = :leadId
        ];
        
        if (existingCampaignMember.isEmpty()) {
            insert new CampaignMember(
                CampaignId = campaignId,
                LeadId = leadId
            );
        }
    }

    private static void createWebinarRegistrant(Id webinarId, Id leadId) {
        insert new WebinarRegistrant__c(
            Webinar__c = webinarId,
            Lead__c = leadId
        );
    }
}
