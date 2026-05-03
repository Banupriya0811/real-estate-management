@isTest
public class TenantControllerTest {

    @testSetup
    static void setupData() {
        List<Tenant__c> tenants = new List<Tenant__c>();
        for (Integer i = 0; i < 5; i++) {
            tenants.add(new Tenant__c(
                Name     = 'Test Tenant ' + i,
                Phone__c = '900000000' + i,
                Email__c = 'tenant' + i + '@test.com'
            ));
        }
        insert tenants;
    }

    @isTest
    static void testGetTenants() {
        Test.startTest();
        List<Tenant__c> tenants = TenantController.getTenants();
        Test.stopTest();

        System.assertEquals(5, tenants.size(), 'Should return 5 tenants');
    }

    @isTest
    static void testCreateTenant() {
        Tenant__c tenant = new Tenant__c(
            Name     = 'New Tenant',
            Phone__c = '9876543210',
            Email__c = 'new@test.com'
        );

        Test.startTest();
        Tenant__c result = TenantController.createTenant(tenant);
        Test.stopTest();

        System.assertNotEquals(null, result.Id, 'Tenant ID should not be null');
        System.assertEquals('New Tenant', result.Name);
    }
}