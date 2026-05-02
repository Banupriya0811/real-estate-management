public with sharing class MaintenanceController {

    @AuraEnabled(cacheable=false)
    public static List<Maintenance_Request__c> getMaintenanceRequests() {
        return [SELECT Id, Name, Property__c, Property__r.Name,
                Vendor__c, Vendor__r.Name, Status__c, Description__c
                FROM Maintenance_Request__c
                ORDER BY CreatedDate DESC];
    }

    @AuraEnabled
    public static Maintenance_Request__c createRequest(Maintenance_Request__c req) {
        try {
            insert req;
            return req;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void autoAssignVendor(List<Maintenance_Request__c> newRequests) {
        List<Vendor__c> allVendors = [SELECT Id FROM Vendor__c LIMIT 50];
        if (allVendors.isEmpty()) return;

        Map<Id, Integer> vendorWorkload = new Map<Id, Integer>();
        for (Vendor__c v : allVendors) {
            vendorWorkload.put(v.Id, 0);
        }

        List<AggregateResult> workloads = [
            SELECT Vendor__c, COUNT(Id) cnt
            FROM Maintenance_Request__c
            WHERE Status__c IN ('Open', 'In Progress')
            AND Vendor__c != null
            GROUP BY Vendor__c
        ];

        for (AggregateResult ar : workloads) {
            Id vendorId = (Id) ar.get('Vendor__c');
            Integer cnt = (Integer) ar.get('cnt');
            if (vendorWorkload.containsKey(vendorId)) {
                vendorWorkload.put(vendorId, cnt);
            }
        }

        Id leastBusyVendor = null;
        Integer minLoad = 999999;
        for (Id vendorId : vendorWorkload.keySet()) {
            if (vendorWorkload.get(vendorId) < minLoad) {
                minLoad = vendorWorkload.get(vendorId);
                leastBusyVendor = vendorId;
            }
        }

        for (Maintenance_Request__c req : newRequests) {
            req.Vendor__c = leastBusyVendor;
        }
    }
}