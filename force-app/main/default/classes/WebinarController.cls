public with sharing class WebinarController {
    
    /**
     * Gets all public webinars
     */
    @AuraEnabled(cacheable=true)
    public static Webinar__c[] getPublicWebinars(List<String> topicFilter, String searchTerm){
        try {
            String safeSearchTerm = String.escapeSingleQuotes(searchTerm);
            DateTime now = System.now();
            System.debug(topicFilter);

            String q =  'SELECT Id, Name, StartTime__c, ' +
                        'Duration__c, Description__c, Campaign__c, ' + 
                        'Link__c, Owner.Name, Topics__c ' +
                        'FROM Webinar__c ' +
                        'WHERE IsPublic__c = true ' +
                        'AND StartTime__c > :now ';
            if (!topicFilter.isEmpty()) {
                q += 'AND Topics__c includes (';
                for (String topic : topicFilter) {
                    q += '\'' + topic + '\',';
                }
                q = q.removeEnd(',') + ') ';
            }
            if (!String.isBlank(safeSearchTerm)) {
                q += 'AND Name LIKE \'%' + safeSearchTerm + '%\' ';
            }
            q += 'ORDER BY StartTime__c ASC';

            System.debug(q);
            Webinar__c[] webinars = Database.query(q);

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
                Campaign__c,
                Link__c,
                Topics__c
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
                WebinarHandler.createCampaignMember(webinar.Campaign__c, newLead.Id);
            }

            WebinarHandler.createWebinarRegistrant(webinar.Id, newLead.Id);

            WebinarHandler.sendInvitationEmail(webinar, newLead);
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
}