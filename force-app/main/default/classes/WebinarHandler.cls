public without sharing class WebinarHandler {

     /**
     * Checks for existing campaign membership for a lead, and then
     * if none, will create a CampaignMember
     */
    public static void createCampaignMember(Id campaignId, Id leadId) {
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

    public static void createWebinarRegistrant(Id webinarId, Id leadId) {
        insert new WebinarRegistrant__c(
            Webinar__c = webinarId,
            Lead__c = leadId
        );
    }

    public static void sendInvitationEmail(Webinar__c webinar, Lead lead) {
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        attachments.add(createCalendarAttachment(webinar));
        msg.setFileAttachments(attachments);
        msg.setSubject('Your invitation for: ' + webinar.Name);
        msg.setPlainTextBody('Hi ' + lead.FirstName + ',\n' +
                            'Join our webinar at... (TODO)');
        List<String> toAddresses = new List<String>{lead.Email};
        msg.setToAddresses(toAddresses);
        List<Messaging.SingleEmailMessage> msgsToSend = new List<Messaging.SingleEmailMessage>{msg};
        Messaging.sendEmail(msgsToSend);
    }

    public static Messaging.EmailFileAttachment createCalendarAttachment(Webinar__c webinar) {
        DateTime startTime = webinar.StartTime__c;
        DateTime endTime = webinar.StartTime__c.addMinutes((Integer)webinar.Duration__c);
        String dateFormat = 'yyyyMMdd\'T\'HHmmss\'Z\'';

        String icsString =  'BEGIN:VCALENDAR\r\n' +
                            'VERSION:2.0\r\n' +
                            'PRODID:-//ZContent.net//Zap Calendar 1.0//EN\r\n' +
                            'CALSCALE:GREGORIAN\r\n' +
                            'METHOD:PUBLISH\r\n' +
                            'BEGIN:VEVENT\r\n' +
                            'SUMMARY:' + webinar.Name + '\r\n' +
                            'UID:' + webinar.Id + '\r\n' +
                            'SEQUENCE:0\r\n' +
                            'DTSTAMP:' + startTime.formatGMT(dateFormat) + '\r\n' +
                            'DTSTART:' + startTime.formatGMT(dateFormat) + '\r\n' +
                            'DTEND:' + endTime.formatGMT(dateFormat) + '\r\n' +
                            'DESCRIPTION:' + formatCalendarDescription(webinar) + '\r\n' +
                            'URL:' + webinar.Link__c + '\r\n' +
                            'END:VEVENT\r\n' +
                            'END:VCALENDAR\r\n';
        
        Messaging.EmailFileAttachment attch = new Messaging.EmailFileAttachment();
        attch.body = Blob.valueOf(icsString);
        attch.filename = 'invite.ics';
        attch.contenttype = 'text/calendar';
        return attch;
    }

    private static String formatCalendarDescription(Webinar__c webinar) {
        String description = webinar.Description__c.replace('\n', '\\n');
        description += '\\n\\n Join link: ' + webinar.Link__c;
        return description;
    }
}
