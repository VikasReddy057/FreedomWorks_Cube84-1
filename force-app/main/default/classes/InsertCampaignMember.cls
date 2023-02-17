public class InsertCampaignMember {
    public static set<Id> ids = new Set<Id>();
    public static Integer batchCount = 0;
    public static void setMemberIds(set<Id> memberIds) {
        ids.addAll(memberIds);
    }
    public static set<Id> getMemberIds() {
        return ids;
    }
    
    public static void setBatchCount() {
        batchCount += 1;
    }
    public static Integer getBatchCount() {
        return batchCount;
    }
}