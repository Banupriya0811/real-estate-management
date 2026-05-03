@isTest
public class MaintenanceControllerTest {

    @testSetup
    static void setupData() {
        // Create test property
        Property__c prop = new Property__c(
            Name           = 'Test Property',
            Address__c     = '123 Test St',
            City__c        = 'Chennai',
            State__c       = 'Tamil Nadu',
            Postal_Code__c = '600001',
            Country__c     = 'India',
            Type__c        = 'Residential',
            Status__c      = 'Available',
            Rent__c        = 15000,
            Description__c = 'Test'
        );
        insert prop;

        // Create test vendors
        List<Vendor__c> vendors = new List<Vendor__c>();
        for (Integer i = 0; i < 3; i++) {
            vendors.add(new Vendor__c(
                Name     = 'Test Vendor ' + i,
                Phone__c = '900000000' + i,
                Email__c = 'vendor' + i + '@test.com'
            ));
        }
        insert vendors;
    }

    @isTest
    static void testGetMaintenanceRequests() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];
        Vendor__c vendor = [SELECT Id FROM Vendor__c LIMIT 1];

        Maintenance_Request__c req = new Maintenance_Request__c(
            Property__c    = prop.Id,
            Vendor__c      = vendor.Id,
            Status__c      = 'Open',
            Description__c = 'Test maintenance request'
        );
        insert req;

        Test.startTest();
        List<Maintenance_Request__c> requests =
            MaintenanceController.getMaintenanceRequests();
        Test.stopTest();

        System.assertEquals(1, requests.size(), 'Should return 1 request');
        System.assertEquals('Open', requests[0].Status__c);
    }

    @isTest
    static void testAutoAssignVendor() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];

        List<Maintenance_Request__c> requests =
            new List<Maintenance_Request__c>();
        requests.add(new Maintenance_Request__c(
            Property__c    = prop.Id,
            Status__c      = 'Open',
            Description__c = 'Test auto assign'
        ));

        Test.startTest();
        insert requests;
        Test.stopTest();

        Maintenance_Request__c saved = [
            SELECT Id, Vendor__c
            FROM Maintenance_Request__c
            WHERE Id = :requests[0].Id
        ];
        System.assertNotEquals(null, saved.Vendor__c,
            'Vendor should be auto assigned');
    }

    @isTest
    static void testCreateRequest() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];

        Maintenance_Request__c req = new Maintenance_Request__c(
            Property__c    = prop.Id,
            Status__c      = 'Open',
            Description__c = 'New test request'
        );

        Test.startTest();
        Maintenance_Request__c result =
            MaintenanceController.createRequest(req);
        Test.stopTest();

        System.assertNotEquals(null, result.Id, 'Request ID should not be null');
    }

    @isTest
    static void testLeaseAgreementTrigger() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];

        Tenant__c tenant = new Tenant__c(
            Name     = 'Trigger Test Tenant',
            Phone__c = '9999999999',
            Email__c = 'trigger@test.com'
        );
        insert tenant;

        Lease_Agreement__c lease = new Lease_Agreement__c(
            Property__c          = prop.Id,
            Tenant__c            = tenant.Id,
            Start_Date__c        = Date.today(),
            End_Date__c          = Date.today().addMonths(12),
            Agreed_Monthly_Rent__c = 20000
        );

        Test.startTest();
        insert lease;
        Test.stopTest();

        List<Task> tasks = [
            SELECT Id, Subject
            FROM Task
            WHERE WhatId = :lease.Id
        ];
        System.assertEquals(1, tasks.size(), 'One task should be created');
        System.assert(tasks[0].Subject.contains('Generate Lease Agreement'));
    }
}sf apex run test --test-level RunLocalTests --result-format human --wait 10