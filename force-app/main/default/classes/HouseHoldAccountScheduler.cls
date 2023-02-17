global class HouseHoldAccountScheduler implements Schedulable {
    global void execute(SchedulableContext sc) { 
    	Database.executeBatch(new HouseHoldAccountBatch(),10);
    }

}