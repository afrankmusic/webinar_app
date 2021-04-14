public with sharing class Consts {
    
    public static final String WEBINAR_TOPIC_RUDIMENTS = 'Rudiments';
    public static final String WEBINAR_TOPIC_MUSICIANSHIP = 'Musicianship';
    public static final String WEBINAR_TOPIC_PRODUCT_REVIEW = 'Product Review';
    public static final String WEBINAR_TOPIC_LIVE_DEMO = 'Live Demo';
    public static final String WEBINAR_TOPIC_QA = 'Q&A';

    @AuraEnabled(cacheable=true)
    public static List<String> getWebinarTopics() {
        return new List<String>{
            WEBINAR_TOPIC_RUDIMENTS,
            WEBINAR_TOPIC_MUSICIANSHIP,
            WEBINAR_TOPIC_PRODUCT_REVIEW,
            WEBINAR_TOPIC_LIVE_DEMO,
            WEBINAR_TOPIC_QA
        };
    }

}
