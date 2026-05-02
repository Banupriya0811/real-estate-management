trigger LeaseAgreementTrigger on Lease_Agreement__c (after insert) {
    List<Task> tasks = new List<Task>();
    for (Lease_Agreement__c lease : Trigger.new) {
        tasks.add(new Task(
            Subject      = 'Generate Lease Agreement for: ' + lease.Name,
            WhatId       = lease.Id,
            OwnerId      = UserInfo.getUserId(),
            Status       = 'Not Started',
            Priority     = 'High',
            ActivityDate = Date.today().addDays(3)
        ));
    }
    if (!tasks.isEmpty()) {
        insert tasks;
    }
}