public with sharing class PropertyController {

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getProperties(
        Integer pageSize,
        Integer pageNumber,
        Decimal maxPrice,
        String availabilityStatus,
        String furnishingStatus
    ) {
        String baseQuery = 'SELECT Id, Name, Address__c, City__c, State__c, ' +
                           'Type__c, Status__c, Furnishing_Status__c, Rent__c, ' +
                           'Description__c FROM Property__c WHERE Id != null';

        if (maxPrice != null)
            baseQuery += ' AND Rent__c <= ' + maxPrice;
        if (String.isNotBlank(availabilityStatus))
            baseQuery += ' AND Status__c = \'' + availabilityStatus + '\'';
        if (String.isNotBlank(furnishingStatus))
            baseQuery += ' AND Furnishing_Status__c = \'' + furnishingStatus + '\'';

        String countQuery = baseQuery.replace(
            'SELECT Id, Name, Address__c, City__c, State__c, Type__c, Status__c, Furnishing_Status__c, Rent__c, Description__c',
            'SELECT COUNT()'
        );
        Integer totalCount = Database.countQuery(countQuery);

        Integer offset = (pageNumber - 1) * pageSize;
        baseQuery += ' ORDER BY CreatedDate DESC LIMIT ' + pageSize + ' OFFSET ' + offset;

        List<Property__c> properties = Database.query(baseQuery);

        Map<String, Object> result = new Map<String, Object>();
        result.put('records', properties);
        result.put('totalCount', totalCount);
        result.put('totalPages', (Integer) Math.ceil((Double) totalCount / pageSize));
        return result;
    }

    @AuraEnabled
    public static Id createProperty(Property__c prop) {
        try {
            insert prop;
            return prop.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}