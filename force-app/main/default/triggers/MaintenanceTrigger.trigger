trigger MaintenanceTrigger on Maintenance_Request__c (before insert) {
    MaintenanceController.autoAssignVendor(Trigger.new);
}