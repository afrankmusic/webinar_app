@IsTest
public with sharing class WebinarControllerTest {


    @IsTest
    static void testRegisterForWebinar() {
        TestDataFactory.createWebinarsWithCampaigns(1);
        Webinar__c webinar = [SELECT Id, Campaign__c FROM Webinar__c LIMIT 1];
        
        Test.StartTest();
        WebinarController.registerForWebinar(
            webinar.Id,
            'First Name',
            'Last Name',
            'Test Company',
            'test@example.com',
            '1234567890',
            'Tester'
        );
        Test.StopTest();

        Lead[] leadResult = [
            SELECT Id, FirstName, 
            LastName,Email,
            (SELECT Webinar__c FROM WebinarRegistrants__r),
            (SELECT CampaignId FROM CampaignMembers)
            FROM Lead 
        ];

        System.assertEquals(1, leadResult.size(), 'Did not get the expected number of leads');
        System.assertEquals('test@example.com', leadResult[0].Email);
        System.assertEquals(1, leadResult[0].WebinarRegistrants__r.size(), 'Did not get the nexpected number of Webinar Registrants');
        System.assertEquals(webinar.Id, leadResult[0].WebinarRegistrants__r[0].Webinar__c, 'Webinar Registrant was not associated to the correct Webinar');
        System.assertEquals(1, leadResult[0].CampaignMembers.size(), 'Did not get the expected number of Campaign Members');
        System.assertEquals(webinar.Campaign__c, leadResult[0].CampaignMembers[0].CampaignId, 'CampaignMember not associated to the correct Campaign');

    }

    @IsTest
    static void testGetPublicWebinars() {
        TestDataFactory.createWebinarsWithCampaigns(5);
        String nameFilter = '%' + Consts.WEBINAR_TOPIC_RUDIMENTS + '%';
        Webinar__c[] totalWebinars = [SELECT Id FROM Webinar__c];
        Webinar__c[] expectedTopicWebinars = [SELECT Id FROM Webinar__c WHERE Topics__c = :Consts.WEBINAR_TOPIC_RUDIMENTS];
        Webinar__c[] expectedNameWebinars = [SELECT id FROM Webinar__c WHERE Name LIKE :nameFilter];

        Test.StartTest();
        Webinar__c[] nonFiltered = WebinarController.getPublicWebinars(new List<String>(), '');
        Webinar__c[] topicFiltered = WebinarController.getPublicWebinars(new List<String>{Consts.WEBINAR_TOPIC_RUDIMENTS}, '');
        Webinar__c[] nameFiltered = WebinarController.getPublicWebinars(new List<String>(), Consts.WEBINAR_TOPIC_RUDIMENTS);
        Test.StopTest();

        System.assertEquals(totalWebinars.size(), nonFiltered.size());
        System.assertEquals(expectedTopicWebinars.size(), topicFiltered.size());
        System.assertEquals(expectedNameWebinars.size(), nameFiltered.size());
    }
}