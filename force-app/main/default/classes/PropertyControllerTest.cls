@isTest
public class PropertyControllerTest {

    @testSetup
    static void setupData() {
        // Create 30 test properties
        List<Property__c> props = new List<Property__c>();
        for (Integer i = 0; i < 30; i++) {
            props.add(new Property__c(
                Name            = 'Test Property ' + i,
                Address__c      = '123 Test Street',
                City__c         = 'Chennai',
                State__c        = 'Tamil Nadu',
                Postal_Code__c  = '600001',
                Country__c      = 'India',
                Type__c         = 'Residential',
                Status__c       = 'Available',
                Furnishing_Status__c = 'Furnished',
                Rent__c         = 10000 + (i * 500),
                Description__c  = 'Test Description ' + i
            ));
        }
        insert props;
    }

    @isTest
    static void testGetPropertiesPage1() {
        Test.startTest();
        Map<String, Object> result =
            PropertyController.getProperties(25, 1, null, null, null);
        Test.stopTest();

        List<Property__c> records = (List<Property__c>) result.get('records');
        System.assertEquals(25, records.size(), 'Page 1 should return 25 records');
        System.assertEquals(30, (Integer) result.get('totalCount'), 'Total should be 30');
        System.assertEquals(2, (Integer) result.get('totalPages'), 'Total pages should be 2');
    }

    @isTest
    static void testGetPropertiesPage2() {
        Test.startTest();
        Map<String, Object> result =
            PropertyController.getProperties(25, 2, null, null, null);
        Test.stopTest();

        List<Property__c> records = (List<Property__c>) result.get('records');
        System.assertEquals(5, records.size(), 'Page 2 should return 5 records');
    }

    @isTest
    static void testFilterByStatus() {
        Test.startTest();
        Map<String, Object> result =
            PropertyController.getProperties(25, 1, null, 'Available', null);
        Test.stopTest();

        List<Property__c> records = (List<Property__c>) result.get('records');
        for (Property__c p : records) {
            System.assertEquals('Available', p.Status__c, 'Status should be Available');
        }
    }

    @isTest
    static void testFilterByFurnishing() {
        Test.startTest();
        Map<String, Object> result =
            PropertyController.getProperties(25, 1, null, null, 'Furnished');
        Test.stopTest();

        List<Property__c> records = (List<Property__c>) result.get('records');
        for (Property__c p : records) {
            System.assertEquals('Furnished', p.Furnishing_Status__c);
        }
    }

    @isTest
    static void testFilterByPrice() {
        Test.startTest();
        Map<String, Object> result =
            PropertyController.getProperties(25, 1, 12000, null, null);
        Test.stopTest();

        List<Property__c> records = (List<Property__c>) result.get('records');
        for (Property__c p : records) {
            System.assert(p.Rent__c <= 12000, 'Rent should be <= 12000');
        }
    }

    @isTest
    static void testCreateProperty() {
        Property__c prop = new Property__c(
            Name            = 'New Test Property',
            Address__c      = '456 New Street',
            City__c         = 'Mumbai',
            State__c        = 'Maharashtra',
            Postal_Code__c  = '400001',
            Country__c      = 'India',
            Type__c         = 'Commercial',
            Status__c       = 'Available',
            Rent__c         = 50000,
            Description__c  = 'New Test Property Description'
        );

        Test.startTest();
        Id result = PropertyController.createProperty(prop);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Property ID should not be null');
        Property__c saved = [SELECT Id, Name FROM Property__c WHERE Id = :result];
        System.assertEquals('New Test Property', saved.Name);
    }
}