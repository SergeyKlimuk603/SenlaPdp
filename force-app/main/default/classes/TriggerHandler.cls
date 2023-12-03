/*
 * Родительский класс для всех объектов выполняющих какие-либо действия в триггерах
 */

public virtual class TriggerHandler {
    public void run() {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                this.beforeInsert(Trigger.new);
            }
            when AFTER_INSERT {
                this.afterInsert(Trigger.newMap);
            }
            when BEFORE_UPDATE {
                this.beforeUpdate(Trigger.new, Trigger.oldMap);
            }
            when AFTER_UPDATE {
                this.afterUpdate(Trigger.new, Trigger.oldMap);
            }
            when BEFORE_DELETE {
                this.beforeDelete(Trigger.oldMap);
            }
            when AFTER_DELETE {
                this.afterDelete(Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                this.afterUndelete(Trigger.oldMap);
            }
        }
    }

    protected virtual void beforeInsert(List<sObject> newObjectsList) {
    }
    protected virtual void afterInsert(Map<Id, sObject> newObjectsMap) {
    }
    protected virtual void beforeUpdate(List<sObject> newObjectsList, Map<Id, sObject> oldObjectsMap) {
    }
    protected virtual void afterUpdate(List<sObject> newObjectsList, Map<Id, sObject> oldObjectsMap) {
    }
    protected virtual void beforeDelete(Map<Id, sObject> oldObjectsMap) {
    }
    protected virtual void afterDelete(Map<Id, sObject> oldObjectsMap) {
    }
    protected virtual void afterUndelete(Map<Id, sObject> oldObjectsMap) {
    }
}
