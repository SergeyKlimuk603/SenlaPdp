
public virtual class TriggerHandler {
    protected final SObjectType OBJEC_TYPE;
    protected TriggerAction ACTION_TYPE;
   
    private static Map<SObjectType, Set<TriggerAction>> runingActions = new Map<SObjectType, Set<TriggerAction>>();
    public static Set<SObjectType> disabledTriggers = new Set<SObjectType>();

    public TriggerHandler() {
        ACTION_TYPE = getActionType();
    }

    public void run() {
        if (isTriggerAvailable()) {
            return;
        }

        runingActions.get(OBJEC_TYPE).add(ACTION_TYPE);
        
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

    private Boolean isTriggerAvailable() {
        if (runingActions.get(OBJEC_TYPE) == null) {
            runingActions.put(OBJEC_TYPE, new Set<TriggerAction>());
        }

        return disabledTriggers.contains(OBJEC_TYPE)
            || runingActions.get(OBJEC_TYPE).contains(ACTION_TYPE);
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

    public enum TriggerAction {INSERT_ACTION, UPDATE_ACTION, DELETE_ACTION, UNDELETE_ACTION}
}
