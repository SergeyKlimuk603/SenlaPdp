
public virtual class TriggerHandler {
    private static Integer TRIGGER_RUN_COUNT = 0;
    
    public void run() {
        //System.debug('-----TestObjectTriggerHandler runs!!! Count: ' + TRIGGER_RUN_COUNT++);
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
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
}
