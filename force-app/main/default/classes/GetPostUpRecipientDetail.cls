/*
 * Get PostUp Recipient Details for Cron Job at particular interval of time. To set time and start Class as Schedule Job in Salesforce.
 */ 
public class GetPostUpRecipientDetail Implements Schedulable{ 
    
    public void execute(SchedulableContext sc){ 
        System.debug('GetPostUpRecipientDetail : execute');
        Integer cronFrequency;  
        PostUpFieldMap__c[] postUpCronRecordList = [select PostUp_Cron_Time__c, name from PostUpFieldMap__c where PostUp_Cron_Time__c !=: null AND Name = 'Cron Time Hr'];
        if(!postUpCronRecordList.isEmpty()) {
            for(PostUpFieldMap__c postUpCronRecord : postUpCronRecordList) {
                cronFrequency = (Integer) postUpCronRecord.PostUp_Cron_Time__c; 
            }
        } 
        // Re-schedule ourself to run again in "intervalMinutes" time 
        DateTime now  = DateTime.now();
        if(cronFrequency != null) { 
            DateTime nextRunTime = now.addHours(cronFrequency); 
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                nextRunTime.month() + ' ? ' + nextRunTime.year();  
            System.schedule(GetPostUpRecipientDetail.class.getName() + '-' + now.format(), cronString, new GetPostUpRecipientDetail());
            Id jobId = sc.getTriggerId(); 
            callAPI();
        } 
    }    
     
    public void callAPI(){ 
        System.debug('GetPostUpRecipientDetail : callAPI');
        System.enqueueJob(new PostUpRecipientSubscriptionQueue());
    }
}