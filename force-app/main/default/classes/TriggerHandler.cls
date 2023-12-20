
public virtual class TriggerHandler {
    protected final SObjectType OBJEC_TYPE;
    protected TriggerAction ACTION_TYPE;
   
    private static Map<SObjectType, Set<TriggerAction>> runingActions = new Map<SObjectType, Set<TriggerAction>>();
    public static Set<SObjectType> disabledTriggers = new Set<SObjectType>();

    public TriggerHandler() {
        // System.debug('----TriggerHandler constructor runs');
        ACTION_TYPE = getActionType();
    }

    public void run() {
        if (isTriggerAvailable()) {
            return;
        }

        //runingActions.get(OBJEC_TYPE).add(ACTION_TYPE);

        List<SObject> oldChangedObjects = new List<SObject>();
        List<SObject> newChangedObjects = new List<SObject>();
        
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                this.beforeInsert(Trigger.new);
            }
            when AFTER_INSERT {
                this.afterInsert(Trigger.new, Trigger.newMap);
            }
            when BEFORE_UPDATE {
                System.debug('-----start Changed Record Finding before update');
                for (SObject record : Trigger.old) {
                    SObject newRecord = Trigger.newMap.get(record.Id);

                    if (record.clone(false, false, false, false) 
                        != Trigger.newMap.get(record.Id).clone(false, false, false, false)
                    ) {
                        //System.debug('-----recordOld: ' + record.get('Name') + '   '  + record.get('TextField__c') + '   ' + record.get('NumberField__c'));
                        //System.debug('-----recordNew: ' + newRecord.get('Name') + '   '  + newRecord.get('TextField__c') + '   ' + newRecord.get('NumberField__c'));
                        oldChangedObjects.add(record);
                        newChangedObjects.add(Trigger.newMap.get(record.Id));
                    }
                }
                System.debug('-----end Changed Record Finding before update. records for beforeUpdate: ' + newChangedObjects.size());

                if (newChangedObjects.isEmpty()) {
                    return;
                }

                this.beforeUpdate(newChangedObjects, new Map<Id, SObject>(oldChangedObjects));
            }
            when AFTER_UPDATE {
                System.debug('-----start Changed Record Finding after update');
                for (SObject record : Trigger.old) {
                    SObject newRecord = Trigger.newMap.get(record.Id);
                    // SObject recordClone = record.clone(false, false, false, false);
                    // SObject newRecordClone = newRecord.clone(false, false, false, false);
                    // Map<String, Object> recordMap = record.getPopulatedFieldsAsMap();
                    // Map<String, Object> newRecordMap = newRecord.getPopulatedFieldsAsMap();

                    // recordClone.put('LastModifiedDate', null);
                    // newRecordClone.put('LastModifiedDate', null);
                    // recordMap.remove('LastModifiedDate');
                    // newRecordMap.remove('LastModifiedDate');
                    // System.debug('----recordOld: ' + record.get('Name') + '   '  + record.get('TextField__c') + '   ' + record.get('NumberField__c'));
                    // System.debug('----recordNew: ' + newRecord.get('Name') + '   '  + newRecord.get('TextField__c') + '   ' + newRecord.get('NumberField__c'));
                    // System.debug('----areRecordsNotEquals(record, newRecord): ' + areRecordsNotEquals(record, newRecord));
                    if (areRecordsNotEquals(record, newRecord)) {
                        // System.debug('----recordOld: ' + record.get('Name') + '   '  + record.get('TextField__c') + '   ' + record.get('NumberField__c'));
                        // System.debug('----recordNew: ' + newRecord.get('Name') + '   '  + newRecord.get('TextField__c') + '   ' + newRecord.get('NumberField__c'));
                        oldChangedObjects.add(record);
                        newChangedObjects.add(newRecord);
                    }
                }

                System.debug('-----end Changed Record Finding after update. records for afterUpdate: ' + newChangedObjects.size());

                if (newChangedObjects.isEmpty()) {
                    return;
                }

                this.afterUpdate(newChangedObjects, new Map<Id, SObject>(oldChangedObjects));
            }
            when BEFORE_DELETE {
                this.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_DELETE {
                this.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                this.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }

        // switch on Trigger.operationType {
        //     when BEFORE_INSERT {
        //         this.beforeInsert();
        //     }
        //     when AFTER_INSERT {
        //         this.afterInsert();
        //     }
        //     when BEFORE_UPDATE {
        //         this.beforeUpdate();
        //     }
        //     when AFTER_UPDATE {
        //         this.afterUpdate();
        //     }
        //     when BEFORE_DELETE {
        //         this.beforeDelete();
        //     }
        //     when AFTER_DELETE {
        //         this.afterDelete();
        //     }
        //     when AFTER_UNDELETE {
        //         this.afterUndelete();
        //     }
        // }

        runingActions.get(OBJEC_TYPE).remove(ACTION_TYPE);
    }

    protected virtual void beforeInsert() {
    }
    protected virtual void afterInsert() {
    }
    protected virtual void beforeUpdate() {
    }
    protected virtual void afterUpdate() {
    }
    protected virtual void beforeDelete() {
    }
    protected virtual void afterDelete() {
    }
    protected virtual void afterUndelete() {
    }

    protected virtual void beforeInsert(List<SObject> newChangedObjects) {}
    protected virtual void afterInsert(List<SObject> newChangedObjects, Map<Id, SObject> newChangedObjectsMap) {}
    protected virtual void beforeUpdate(List<SObject> newChangedObjects, Map<Id, SObject> oldChangedObjectsMap) {}
    protected virtual void afterUpdate(List<SObject> newChangedObjects, Map<Id, SObject> oldChangedObjectsMap) {}
    protected virtual void beforeDelete(List<SObject> oldChangedObjects, Map<Id, SObject> oldChangedObjectsMap) {}
    protected virtual void afterDelete(List<SObject> oldChangedObjects, Map<Id, SObject> oldChangedObjectsMap) {}
    protected virtual void afterUndelete(List<SObject> newChangedObjects, Map<Id, SObject> newChangedObjectsMap) {}

    private Boolean isTriggerAvailable() {
        if (runingActions.get(OBJEC_TYPE) == null) {
            runingActions.put(OBJEC_TYPE, new Set<TriggerAction>());
        }

        //System.debug('----runingActions: ' + runingActions);

        // return disabledTriggers.contains(OBJEC_TYPE)
        //     || runingActions.get(OBJEC_TYPE).contains(ACTION_TYPE);

        return disabledTriggers.contains(OBJEC_TYPE);
    }

    private TriggerAction getActionType() {
        TriggerAction action;
        switch on Trigger.operationType {
            when BEFORE_INSERT, AFTER_INSERT {
                action = TriggerAction.INSERT_ACTION;
            }
            when BEFORE_UPDATE, AFTER_UPDATE {
                action = TriggerAction.UPDATE_ACTION;
            }
            when BEFORE_DELETE, AFTER_DELETE {
                action = TriggerAction.DELETE_ACTION;
            }
            when AFTER_UNDELETE {
                action = TriggerAction.UNDELETE_ACTION;
            }
        }

        return action;
    }

    private Boolean areRecordsNotEquals(SObject record, SObject newRecord) {
        List<String> ommitedKeys = new List<String>{
            'LastModifiedDate',
            'SystemModstamp'
        };
        Map<String, Object> recordMap = record.getPopulatedFieldsAsMap();
        Map<String, Object> newRecordMap = newRecord.getPopulatedFieldsAsMap();
        Set<String> allKeys = new Set<String>();
        allKeys.addAll(recordMap.keySet());
        allKeys.addAll(newRecordMap.keySet());
        
        for (String key : allKeys) {
            //  System.debug('---recordMap ' + key + ': ' + recordMap.get(key));
            //  System.debug('---newRecordMap ' + key + ': ' + newRecordMap.get(key));
            if (ommitedKeys.contains(key)) {
                continue;
            }

            if (recordMap.get(key) != newRecordMap.get(key)) {
                // System.debug('-------key not equal: ' + key);
                // System.debug('-------recordMap.get(key): ' + recordMap.get(key));
                // System.debug('-------newRecordMap.get(key): ' + newRecordMap.get(key));
                return true;
            }
        }

        return false;
    }

    public enum TriggerAction {INSERT_ACTION, UPDATE_ACTION, DELETE_ACTION, UNDELETE_ACTION}
}
