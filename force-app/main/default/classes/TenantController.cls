public with sharing class TenantController {

    @AuraEnabled(cacheable=false)
    public static List<Tenant__c> getTenants() {
        return [SELECT Id, Name, Phone__c, Email__c
                FROM Tenant__c
                ORDER BY CreatedDate DESC];
    }

    @AuraEnabled
    public static Tenant__c createTenant(Tenant__c tenant) {
        try {
            insert tenant;
            return tenant;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}