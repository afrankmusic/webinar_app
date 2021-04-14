@IsTest
public with sharing class TestDataFactory {

    /**
     * Creates test campaigns and one webinar per topic for each
     */
    public static void createWebinarsWithCampaigns(Integer numCampaigns) {
        List<Campaign> campaigns = new List<Campaign>();
        for (Integer i=0; i< numCampaigns; i++) {
            campaigns.add(new Campaign(Name = 'Test Campaign ' + i));
        }
        insert campaigns;

        List<Webinar__c> webinars = new List<Webinar__c>();
        for (Campaign cmp : campaigns) {
            for (String topic : Consts.getWebinarTopics()) {
                webinars.add(new Webinar__c(
                    Name = topic,
                    Topics__c = topic,
                    IsPublic__c = true,
                    Description__c = 'Test webinar for ' + topic,
                    Campaign__c = cmp.Id,
                    StartTime__c = System.now().addDays(1),
                    Duration__c = 30,
                    Link__c = 'https://google.com'
                ));
            }
        }

        insert webinars;
    }
}
