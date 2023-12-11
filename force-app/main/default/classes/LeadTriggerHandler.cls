// from Vitaliy Peralayka
public class LeadTriggerHandler extends TriggerHandler {

    public static List<FeedItem> oldPosts;
    public static Map<Id, String> mapBrokers;
    public static Map<Id, String> mapAvailableMessenger;
    public static Map<Id, String> mapFxUserClientId;
    private static Map<Id, DateTime> mapLeadCustomDate;
    private static Map<Id, List<Id>> oldLeadIdsByMasterId;
    private static Map<Id, List<Lead>> clones;

    @TestVisible private static final String DASH = '-';
    @TestVisible private static final String FILL_CYPB_STATUS_UPDATED_UNIX = 'FillCypbStatusUnix';

    public LeadTriggerHandler() {
        ObjectName = 'Lead';
    }

    protected override void beforeInsert() { 
        // filling BrokerText__c with the value Broker__c
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'FillBrokerTextField') != null) {
            fillBrokerTextField(trigger.new);
        }
        // setting current broker checkbox to true (example: Broker__c equals CYPB -> CYPBBroker__c will set to true)
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'CheckBroker') != null) {
            checkBroker(trigger.new);
        }
        // converting FxBank_CYPB_Status_Last_Change_Date__c to unix time format and saving the result in FxBank_CYPB_Status_Last_Change_Date_Unix__c
        if (TriggerAvailableMethod__c.getValues(ObjectName + DASH + FILL_CYPB_STATUS_UPDATED_UNIX) != null
                && !HelperTrigger.isRunVerificationProcessService) {
            ClientManager.fillCupbStatusUpdatedUnix(trigger.new);
        }
    }

    protected override void afterInsert() {
        // sending ESB event when Lead was created via Facebook
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'SendPreLeadEvent') != null) {
            sendPreLeadEvent(Trigger.new);
        }
        // sharing leads for partner user when new lead comes
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'ManualSharingByPartnerCodes') != null) {
            manualShareByPartnerCodes(trigger.new, null);
        }
    }

    protected override void beforeUpdate() {
        // Islamic_account__c checkbox should be set as true after merging(no matter is it master value or not)
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeIslamicAccount') != null) {
            mergeIslamicAccount(trigger.new, clones);
        }
        // FxBankCYPBStatus__c and FxBank_CYPB_Status_Last_Change_Date__c fields should be updated to the last actual value
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeFxBankCYPBStatus') != null) {
            mergeFxBankCYPBStatus(trigger.new, clones, trigger.oldMap);
        }
        // setting min custom CreatedDate during merge
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeCustomCreatedDateField') != null && mapLeadCustomDate != null) {
            updateCustomCreatedDateField(trigger.new, trigger.oldMap);
        }
        // updating AdChannel__c, Creative_name__c, AdChannelUpdatedDate__c field to the newest ones during merge process
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeCreativeNameAndAdChannel') != null && clones != null) {
            mergeCreativeNameAndAdChannelFields(trigger.new, clones, trigger.oldMap);
        }
        // Hide_From_Partner__c field value shouldn't be changed on winner Lead
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeHideFromPartnerUser') != null) {
            mergeHideFromPartnerUser(trigger.new, clones, trigger.oldMap);
        }
        // Setting BranchDiffersFromParentBranch__c field to true if FilialIdGlob__c was changed during merge process
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeBranchDiffFromParent') != null
                && clones != null) {
            mergeBranchDiffersFromParentBranch(trigger.new, clones, trigger.oldMap);
        }
        // filling BrokerText__c with the value Broker__c
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'FillBrokerTextField') != null) {
            fillBrokerTextField(trigger.new);
        }
        // adding LastRealAccountPlatform__c value to PlatformReal__c picklist field
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'LastRealAccountPlatform') != null) {
            updateLastRealAccountPlatform(
                    Filters.isChanged(
                            trigger.oldMap,
                            Filters.isNotNull(trigger.new, 'LastRealAccountPlatform__c'),
                            'LastRealAccountPlatform__c'
                    )
            );
        }
        // transfer the value of the AvailableMessenger from both Leads during the merge process
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeAvailableMessenger') != null) {
            calculateMessengersIds(trigger.newMap, trigger.oldMap, clones);
        }
        // calculating AlfaForex fields(AlfaForexClient__c, HasOptedOutOfEmail, SMS_Opt_Out__c, AlfaForexDate__c) during merge process
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeAlfaForexFields') != null) {
            calculateAlfaForexFields(trigger.new, clones);
        }
        // setting AvailableMessenger__c field(merge values from multi-select picklist)
        if (mapAvailableMessenger!=null&&!mapAvailableMessenger.isEmpty()) {
            mergeAvailableMessengerField(trigger.newMap,trigger.oldMap);
        }
        // setting Broker__c field(merge values from multi-select picklist)
        if ((mapBrokers != null && !mapBrokers.isEmpty()) || (mapFxUserClientId != null && !mapFxUserClientId.isEmpty())) {
            updateMultiPicklistField(trigger.new, trigger.oldMap);
        }
        // setting AutoTask_Batches__c field (join old and new values from AutoTask_Batches__c)
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeAutoTaskBatches') != null && clones!= null) {
            updateAutoTaskBatches(trigger.new, trigger.oldMap);
        }
        // setting Dealing Groups fields(Dealing_group_last_change__c, DealingGroupsListed__c, Dealing_group__c) during merge process
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeDealingGroups') != null && clones!= null) {
            mergeDealingGroups(trigger.new, trigger.old);
        }
        // if during merge process at least one of leads contains "Metamask Registration" field with the value TRUE, then the final lead must have this field equal to TRUE
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeMetamaskRegistration') != null && clones!= null) {
            mergeMetamaskRegistration(trigger.new, trigger.oldMap, clones);
        }
        // in merge process if one lead has unsubscribed by GDPR true, the final value will be true
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeUnsubscribedByGDPR') != null && clones!= null) {
            mergeUnsubscribedByGDPR(Trigger.new, Trigger.oldMap, clones);
        }

        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeLeadStatus') != null && clones != null) {
            mergeLeadStatus(Trigger.new, clones, Trigger.oldMap);
        }

        // in merge process split picklist values from mergable records(FxUserCountries__c field is Multi-Select picklist)
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeFxUserCountries') != null && clones != null) {
            mergeFxUserCountries(Trigger.new, clones, Trigger.oldMap);
        }

        // setting current broker checkbox to true (example: Broker__c equals CYPB -> CYPBBroker__c will set to true)
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'CheckBroker') != null) {
            checkBroker(trigger.new);
        }
        // NEED REVIEW
        if ((TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeIBPartnerCodeAndAffiliateID') != null || 
                TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergePartnerIds') != null ) && clones != null) {
            mergePartnerCodes(trigger.newMap, trigger.old, oldLeadIdsByMasterId);
        }
        // updating IBPartnerCodeOrAffiliateIDLastUpdate__c to current DateTime
        // if one of the following fields(AffiliateID__c, IBPartnerCode__c, Affiliate_Network__c, Partner_Network__c, CXD_Long__c) were changed
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'UpdatePartnerCodeLastUpdate') != null) {
            updatePartnerCodeLastUpdate(trigger.new, trigger.old);
        }
        // setting Status and OwnerId values to old ones if current Lead is Open and Converted
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'UpdateConvertedLeadStatus') != null) {
            updateConvertedLeadStatus(trigger.new, trigger.old);
        }
        // updating AlfaForexFundedDate__c to current DateTime if AlfaForexFunded__c was changed to 'yes' value and AlfaForexFundedDate__c isn't today
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'UpdateAlfaForexFundedDate') != null) {
            for (Integer i = 0; i < trigger.size; i++) {
                if (trigger.old.get(i).get('AlfaForexFunded__c') != trigger.new.get(i).get('AlfaForexFunded__c') && 
                    trigger.new.get(i).get('AlfaForexFunded__c') == 'yes' &&
                    trigger.new.get(i).get('AlfaForexFundedDate__c') != Date.today()){
                        trigger.new.get(i).put('AlfaForexFundedDate__c', Date.today());
                }
            }
        }
        // hiding clients from partners when we change partner codes (setting Hide_From_Partner__c to false)
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'UpdateHideFromPartner') != null) {
            updateHideFromPartner(trigger.new, trigger.old);
        }
        // converting FxBank_CYPB_Status_Last_Change_Date__c to unix time format and saving the result in FxBank_CYPB_Status_Last_Change_Date_Unix__c
        if (TriggerAvailableMethod__c.getValues(ObjectName + DASH + FILL_CYPB_STATUS_UPDATED_UNIX) != null
                && !HelperTrigger.isRunVerificationProcessService) {
            ClientManager.fillCupbStatusUpdatedUnix(trigger.newMap, trigger.oldMap);
        }
    }

    protected override void beforeDelete() {
        // filling in the oldPosts list for future processing
        // the chatter feed of the winning lead should contains all posts from all of the merged leads
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeChatterFeed') != null) {
            oldPosts = [select Id, ParentId, Body, Title, CreatedById, CreatedDate from FeedItem where ParentId in :trigger.old and Type = 'TextPost'];
        }
    }

    protected override void afterDelete() {
        // searching min custom CreatedDate for its setting in merge process
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeCustomCreatedDateField') != null) {
            searchMinCustomCreatedDate(trigger.old);
        }
        // filling maps to customize merge processes
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeIBPartnerCodeAndAffiliateID') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeAutoTaskBatches') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeDealingGroups') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeAvailableMessenger') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeFxBankCYPBStatus') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeAlfaForexFields') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeIslamicAccount') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'ReparentBigObjDueLeadMerge') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeMetamaskRegistration') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeBranchDiffFromParent') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeUnsubscribedByGDPR') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeLeadStatus') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeFxUserCountries') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'SendCrmLeadStatus') != null
                || TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergePartnerIds') != null
                ) {

            fillMapOldLeadIdsByMasterId(trigger.old);
        }
        // the chatter feed of the winning lead should contains all posts from all of the merged leads
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeChatterFeed') != null) {
            Map<ID, ID> feedParents = new Map<ID, ID>();
            for (Integer i = 0; i < trigger.size; i++) {
                if (trigger.old[i].get('MasterRecordId') != null) {
                    feedParents.put(trigger.old[i].Id, (ID)trigger.old[i].get('MasterRecordId'));
                }
            }
            ChatterManager.cloneFeed(feedParents, oldPosts);
        }
        // erasing values of fields "Has clones" & "Clone info" when clones are merged and no other clones remaining currently
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'SearchCloneForMerge') != null) {
            Set<Id> masterIds = new Set<Id>();
            for (Integer i = 0; i < trigger.size; i++) {
                if (trigger.old[i].get('MasterRecordId') != null) {
                    masterIds.add((ID)trigger.old[i].get('MasterRecordId'));
                }
            }
            if (!masterIds.isEmpty()) System.enqueueJob(new CloneQueue(new List<Id>(masterIds)));
        }

        Boolean isMergeBrokerField = (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeBrokerField') != null);
        Boolean isMergeAvailableMessengers = (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeAvailableMessenger') != null);

        if (isMergeBrokerField||isMergeAvailableMessengers) {
            mapBrokers = new Map<Id, String>();
            mapAvailableMessenger=new Map<Id, String>();
            mapFxUserClientId = new Map<Id, String>();
            for (Integer i = 0; i < trigger.size; i++) {
                if (trigger.old[i].get('MasterRecordId') != null) {
                    Id masterId = (ID) trigger.old[i].get('MasterRecordId');

                    if (isMergeBrokerField) {
                        String broker;
                        if (mapBrokers.get(masterId) != null) {
                            broker = mapBrokers.get(masterId);
                        }

                        broker = Utils.join(';', new List<Object>{broker, trigger.old[i].get('Broker__c')});

                        if (String.isNotBlank(broker)) {
                            mapBrokers.put(masterId, broker);
                        }
                    }
                    if(isMergeAvailableMessengers){
                        String messenger;
                        if (mapAvailableMessenger.get(masterId) != null) {
                            messenger = mapAvailableMessenger.get(masterId);
                        }
                        messenger = Utils.join(';', new List<Object>{messenger, trigger.old[i].get('AvailableMessenger__c')});

                        if (String.isNotBlank(messenger)) {
                            mapAvailableMessenger.put(masterId, messenger);
                        }
                    }
                }
            }
        }
    }

    protected override void afterUpdate() {
        // transfer of chatter when converting Lead to Account
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'ConvertLeadToAccount') != null) {

            Map<Id, Id> personIdByLeadId = new Map<Id, Id>{};

            for (Integer i = 0; i < trigger.size; i++) {
                Lead lead = (Lead)trigger.new[i];
                Lead oldLead = (Lead)trigger.old[i];
                if (!HelperTrigger.convertLeadToAccount.containsKey(lead.Id) &&
                        lead.IsConverted && !oldLead.IsConverted) {
                    HelperTrigger.convertLeadToAccount.put(lead.Id, lead);
                    personIdByLeadId.put(lead.Id, lead.ConvertedAccountId);
                }
            }

            if (personIdByLeadId.keySet().size() != 0) {
                List<FeedItem> leadPosts = [
                        select Id, ParentId, Body, Title, CreatedById, CreatedDate
                        from FeedItem
                        where
                        ParentId in :personIdByLeadId.keySet()
                        and Type = 'TextPost'];
                ChatterManager.cloneFeed(personIdByLeadId, leadPosts);
                ChatterManager.cloneTrackedChangeFeeds(personIdByLeadId);

                publishEventLeadConvert(personIdByLeadId);
            }
            // assigning Cases to Account after Lead conversion
            if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MoveCasesFromLeadToAccount') != null) {
                moveCasesToAccount(personIdByLeadId);
            }
            // creating TradingStrategyRequest__e events after Lead conversion
            if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'CreateTradeSystem') != null) {
                List<CampaignMember> campaignMembers = CampaignManager.getCampaignMemberByClientIds(new List<Id>(Trigger.newMap.keySet()));
                if(!campaignMembers.isEmpty()){
                    LeadManager.createTradeSystemAfterConversion(campaignMembers);
                }
            }
            // changing SF Id on child Big objects after Lead conversion
            if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'ReparentBigObjDueLeadConversion') != null
                    && !personIdByLeadId.isEmpty()) {
                reparentBigObjects(personIdByLeadId);
            }
        }
        // changing SF Id on child Big objects after Lead merging
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'ReparentBigObjDueLeadMerge') != null
                && oldLeadIdsByMasterId != null && !oldLeadIdsByMasterId.isEmpty()) {
            reparentBigObjectsDueLeadMerge(oldLeadIdsByMasterId, HelperTrigger.convertLeadToAccount);
        }
        // creating records(FxUser, DemoAccount, RealAccount) from related to Lead attachments
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'ConvertAttachToObject') != null &&
                Limits.getFutureCalls() < Limits.getLimitFutureCalls()) {
            Id[] accIds = new Id[]{};

            for (Integer i = 0; i < trigger.size; i++) {
                Lead lead = (Lead)trigger.new[i];
                Lead oldLead = (Lead)trigger.old[i];
                if (!HelperTrigger.convertAttachToObject.containsKey(lead.Id) &&
                        lead.IsConverted && !oldLead.IsConverted) {
                    HelperTrigger.convertAttachToObject.put(lead.Id, lead);
                    accIds.add(lead.ConvertedAccountId);
                }
            }

            if (accIds.size() != 0 && !System.isQueueable()) {
                AccountManager.createObjectsByAttachment(accIds);
            }
        }
        // changing filial info in the FxBank
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'ChangeFilialInfo') != null) {
            if (HelperTrigger.firstRunChangeFilialInfo) {
                List<Lead> leads = new List<Lead>();
                for (Integer i = 0; i < trigger.size; i++) {
                    if (trigger.old[i].get('FilialIdGlob__c') != trigger.new[i].get('FilialIdGlob__c')) {
                        leads.add((Lead)trigger.new[i]);
                    }
                }
                if (!leads.isEmpty()) {
                    ChangeFilialService.changeFilial(leads);
                    HelperTrigger.firstRunChangeFilialInfo = false;
                }
            }
        }
        // saving and updating IBPartnerCode_c/AffiliateID_c on the all related FxUsers/FxUser attachments
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'UpdateFxUserPartnerCodes') != null) {
           updateFxUserPartnerCodes(trigger.new, trigger.old, clones);
        }

        // updating cases related to current lead if Language__c field on account was changed
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'UpdateCasesLanguage') != null) {
            Set<Id> leadIds = new Set<Id>();
            for (Integer i = 0; i < Trigger.size; i ++) {
                if (trigger.new[i].get('Language__c') != trigger.old[i].get('Language__c')) leadIds.add(trigger.new[i].Id);
            }
            if (leadIds.size() > 0) {
                if (System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled()) {
                    updateCasesLanguageSync(leadIds);
                } else {
                    updateCasesLanguageAsync(leadIds);
                }
            }
        }
        // sharing leads for partner user when we update partner codes
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'ManualSharingByPartnerCodes') != null) {
            manualShareByPartnerCodes(trigger.new, trigger.old);
        }
        // sending the event for every FxUser in Lead each time when "Lead Status" is updated
        if (TriggerAvailableMethod__c.getValues(ObjectName + DASH + 'SendCrmLeadStatus') != null
                && !HelperTrigger.isBypassedMethod(ObjectName + DASH + 'SendCrmLeadStatus')) {
            List<SObject> updatedLeads = Utils.getRecordsWithChangedFields(Trigger.old, Trigger.new, new Set<String>{'Status'});
            if (clones != null) updatedLeads.addAll(getOtherMasterLeadsForSendCrmLeadStatusEvent(Utils.getSetFieldIds(updatedLeads, 'Id')));
            if (!updatedLeads.isEmpty()) {
                sendCrmLeadStatusEvent((List<Lead>) updatedLeads);
                HelperTrigger.bypassMethod(ObjectName + DASH + 'SendCrmLeadStatus');
            }
        }
        // update Related task's owners when lead's owner was changed (Publish Change_Client_Owner__e event)
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'PublishChangeClientOwnerEvent') != null) {
            List<Change_Client_Owner__e> eventsToPublish = new List<Change_Client_Owner__e>();
            List<SObject> changedOwnerLeads = Utils.getRecordsWithChangedFields(Trigger.old, Trigger.new, new Set<String>{'OwnerId'});
            for (SObject newLead : changedOwnerLeads) {
                SObject oldLead = Trigger.oldMap.get(newLead.Id);
                eventsToPublish.add(
                        new Change_Client_Owner__e(
                                SfClient_Id__c = newLead.Id,
                                NewOwnerId__c = (String) newLead.get(Lead.OwnerId),
                                OldOwnerId__c = (String) oldLead.get(Lead.OwnerId)
                        )
                );
            }
            if (!eventsToPublish.isEmpty()) {
                Utils.checkDatabaseSaveResults(
                        EventBus.publish(eventsToPublish),
                        eventsToPublish,
                        'AccountTriggerHandler.afterUpdate.AssignNewOwnerRelatedTasks',
                        true);
            }
        }
    }

    @TestVisible
    private void reparentBigObjectsDueLeadMerge(Map<Id, List<Id>> oldLeadIdsByMasterId, Map<Id, Lead> convertLeadToAccount) {
        Map<Id, Id> parentNewByParentOld = new Map<Id, Id>();

        for (Id masterId : oldLeadIdsByMasterId.keySet()) {
            List<Id> parentsOld = oldLeadIdsByMasterId.get(masterId);
            Id parentNew = convertLeadToAccount.containsKey(masterId) ? convertLeadToAccount.get(masterId).ConvertedAccountId : masterId;

            for (Id parentOld : parentsOld) {
                parentNewByParentOld.put(parentOld, parentNew);
            }
        }

        reparentBigObjects(parentNewByParentOld);
    }

    @TestVisible
    private void reparentBigObjects(Map<Id, Id> parentNewByParentOld) {
        BigObjectReparentService.saveProxies(parentNewByParentOld);
    }

    private static void updateCasesLanguageSync(Set<Id> leadIds) {
        List<Case> leadsCases = [select Id from Case where AccountId in :leadIds];
        Database.update(leadsCases);
    }

    @future
    private static void updateCasesLanguageAsync(Set<Id> leadIds) {
        updateCasesLanguageSync(leadIds);
    }

    private void updateLastRealAccountPlatform(List<Lead> input) {
        for (Lead lead : input) {
            lead.PlatformReal__c = Utils.addToMultiPicklist(lead.PlatformReal__c, lead.LastRealAccountPlatform__c);
        }
    }

    private void updateMultiPicklistField(List<Lead> newLeads, Map<Id, SObject> oldMap) {
        for (Lead lead : newLeads) {
            Lead oldLead = (Lead)oldMap.get(lead.id);
            if (mapBrokers.get(lead.id) != null) {
                lead.Broker__c = Utils.addToMultiPicklist(oldLead.Broker__c, mapBrokers.get(lead.id));
            }
        }
    }

    private void mergeAvailableMessengerField(Map<Id, SObject> newLeads, Map<Id, SObject> oldLeads) {
        for (Lead oldLead : (List< Lead>) oldLeads.values()) {
            String currentAvailableMessengers = (String) oldLead.get('AvailableMessenger__c');
            Lead newLead=(Lead)newLeads.get(oldLead.id);
            for(String availableMessenger:getMessengersIdsFieldsForMergeByMasterCard().keySet()){
             if(!String.isEmpty((String)newLead.get(getMessengersIdsFieldsForMergeByMasterCard().get(availableMessenger)))){
                 currentAvailableMessengers=Utils.addToMultiPicklist(currentAvailableMessengers,availableMessenger);
             }
            }
            newLead.put('AvailableMessenger__c',currentAvailableMessengers);
        }
    }

    private void searchMinCustomCreatedDate(List<Lead> oldLeads) {
        mapLeadCustomDate = new Map<Id, DateTime>();
        for (Lead lead : oldLeads) {
            if (lead.MasterRecordId != null) {
                if (mapLeadCustomDate.get(lead.MasterRecordId) == null) {
                    mapLeadCustomDate.put(lead.MasterRecordId, lead.RightCreatedDate__c);
                } else if (mapLeadCustomDate.get(lead.MasterRecordId) > lead.RightCreatedDate__c) {
                    mapLeadCustomDate.put(lead.MasterRecordId, lead.RightCreatedDate__c);
                }
            }
        }
    }

    private void fillMapOldLeadIdsByMasterId(List<Lead> oldLeads) {
        oldLeadIdsByMasterId = new Map<Id, List<Id>>();
        clones = new Map<Id, List<Lead>>();
        for (Lead lead : oldLeads) {
            if (lead.MasterRecordId != null) {
                if (oldLeadIdsByMasterId.get(lead.MasterRecordId) == null) {
                    oldLeadIdsByMasterId.put(lead.MasterRecordId, new List<Id>());
                    clones.put(lead.MasterRecordId, new List<Lead>());
                }
                oldLeadIdsByMasterId.get(lead.MasterRecordId).add(lead.id);
                clones.get(lead.MasterRecordId).add(lead);
            }
        }
    }

    private void updateCustomCreatedDateField(List<Lead> newLeads,Map<Id, SObject> oldMaps) {
        for (Lead lead : newLeads) {
            if (mapLeadCustomDate.get(lead.Id) != null) {
                lead.CustomCreatedDate__c = ((Lead)oldMaps.get(lead.id)).CustomCreatedDate__c;
                if (lead.CustomCreatedDate__c != null && mapLeadCustomDate.get(lead.Id) < lead.CustomCreatedDate__c) {
                    lead.CustomCreatedDate__c = mapLeadCustomDate.get(lead.Id);
                } else if (lead.CustomCreatedDate__c == null) {
                    lead.CustomCreatedDate__c = mapLeadCustomDate.get(lead.Id);
                }
            }
        }
    }

    private void calculateAlfaForexFields(List<Lead> newLeads, Map<Id, List<Lead>> clones) {
        for (Lead lead : newLeads) {
            if (clones != null && clones.get(lead.Id) != null) {
                List<Lead> allLeads = clones.get(lead.id);
                allLeads.add(lead);
                Boolean hasOptedOutOfEmail = false;
                Boolean smsOptOut = false;
                for (Lead oldLead : clones.get(lead.id)) {
                    if (oldLead.AlfaForexClient__c == true) {
                        lead.AlfaForexClient__c = true;
                    }
                    if (oldLead.HasOptedOutOfEmail == true)hasOptedOutOfEmail = true;
                    if (oldLead.SMS_Opt_Out__c == true)smsOptOut = true;
                }
                if (lead.AlfaForexClient__c == true) {
                    if (hasOptedOutOfEmail) lead.HasOptedOutOfEmail = hasOptedOutOfEmail;
                    if (smsOptOut)lead.SMS_Opt_Out__c = smsOptOut;
                }
                SObject leadWithEarliestDate = Utils.getSobjectWithCorrectDateField(allLeads, new List<String>{
                        'AlfaForexDate__c'
                }, false);
                if (leadWithEarliestDate != null) {
                    lead.AlfaForexDate__c = (Date) leadWithEarliestDate.get('AlfaForexDate__c');
                }
            }
        }
    }

    private void calculateMessengersIds(Map<Id,SObject>newLeads,Map<Id,SObject> oldLeads, Map<Id, List<Lead>> clones) {
        if(clones!=null){
            List<String> fieldsForMerge=getMessengersIdsFieldsForMergeByMasterCard().values();
            for(Lead lead:((Map<Id,Lead>)oldLeads).values()){
                Map<String, List<String>> fieldNameAndAccountsValuesForCompare = new Map<String, List<String>>();
                List<Lead> duplicates=clones.get(lead.id);
                for(String fieldForMerge:fieldsForMerge){
                    if(String.isEmpty((String)lead.get(fieldForMerge))){
                        fieldNameAndAccountsValuesForCompare.put(fieldForMerge,new List<String>());
                        for(Lead duplicate:duplicates){
                            if(duplicate.get(fieldForMerge)!=null){
                                fieldNameAndAccountsValuesForCompare.get(fieldForMerge).add((String)duplicate.get(fieldForMerge));
                            }
                        }
                    }else{
                        ((Lead)newLeads.get(lead.id)).put(fieldForMerge,lead.get(fieldForMerge));
                    }
                }
                calcMessengersIdsWhenMasterRecordValueIsNull((Lead)newLeads.get(lead.id),fieldNameAndAccountsValuesForCompare);
            }
        }
    }

    private void calcMessengersIdsWhenMasterRecordValueIsNull(Lead newLead,Map<String, List<String>> valuesMap) {
        for (String fieldName : valuesMap.keySet()) {

            for (String value : valuesMap.get(fieldName)) {
                if (value != null) {
                    newLead.put(fieldName, value);
                    break;
                }
            }
        }
    }

    public Map<String,String> getMessengersIdsFieldsForMergeByMasterCard(){
        return  new Map<String,String>{
                'Skype' =>'SkypeId__c' ,
                'WhatsApp'=> 'WhatsAppId__c',
                'Viber'=> 'ViberId__c',
                'Telegram'=> 'TelegramId__c',
                'FacebookMessenger'=>'FacebookMessengerId__c'
        };
    }

    private void mergeCreativeNameAndAdChannelFields(List<Lead> newLeads, Map<Id, List<Lead>> clones, Map<Id, SObject> oldMaps) {
        for (Lead lead : newLeads) {
            if (clones.get(lead.Id) != null) {
                lead.AdChannel__c = ((Lead)oldMaps.get(lead.id)).AdChannel__c;
                lead.Creative_name__c = ((Lead)oldMaps.get(lead.id)).Creative_name__c;
                lead.AdChannelUpdatedDate__c = ((Lead)oldMaps.get(lead.id)).AdChannelUpdatedDate__c;

                Datetime adChannelUpdatedDate = lead.AdChannelUpdatedDate__c;
                for (Lead oldLead : clones.get(lead.id)) {
                    if (oldLead.AdChannelUpdatedDate__c != null &&(adChannelUpdatedDate == null||oldLead.AdChannelUpdatedDate__c > adChannelUpdatedDate)) {
                        lead.AdChannel__c = oldLead.AdChannel__c;
                        lead.Creative_name__c = oldLead.Creative_name__c;
                        lead.AdChannelUpdatedDate__c = oldLead.AdChannelUpdatedDate__c;
                    }
                }
            }
        }
    }

    private void mergeFxBankCYPBStatus(List<Lead> newLeads, Map<Id, List<Lead>> clones, Map<Id, SObject> oldMaps) {
        for (Lead lead : newLeads) {
            if (clones != null && clones.get(lead.Id) != null) {
                Boolean containCYPB = false;
                lead.FxBank_CYPB_Status_Last_Change_Date__c = ((Lead)oldMaps.get(lead.id)).FxBank_CYPB_Status_Last_Change_Date__c;
                lead.FxBankCYPBStatus__c = ((Lead)oldMaps.get(lead.id)).FxBankCYPBStatus__c;
                if (((Lead)oldMaps.get(lead.id)).Broker__c.contains('CYPB')) containCYPB = true;

                Datetime lastStatusDate = lead.FxBank_CYPB_Status_Last_Change_Date__c;
                for (Lead oldLead : clones.get(lead.id)) {
                    if (((lastStatusDate == null || lastStatusDate < oldLead.FxBank_CYPB_Status_Last_Change_Date__c) && !containCYPB && !oldLead.Broker__c.contains('CYPB'))
                            || (!containCYPB && oldLead.Broker__c.contains('CYPB'))
                            || (lastStatusDate < oldLead.FxBank_CYPB_Status_Last_Change_Date__c && containCYPB && oldLead.Broker__c.contains('CYPB'))) {
                        lead.FxBankCYPBStatus__c = oldLead.FxBankCYPBStatus__c;
                        lead.FxBank_CYPB_Status_Last_Change_Date__c = oldLead.FxBank_CYPB_Status_Last_Change_Date__c;
                        if (oldLead.Broker__c.contains('CYPB')) containCYPB = true;
                    }
                }
            }
        }
    }

    private void publishEventLeadConvert(Map<Id, Id> personIdByLeadId) {
        List<LeadConvert__e> leadConverts = new List<LeadConvert__e>();
        for(Id leadId : personIdByLeadId.keySet()) {
            leadConverts.add(new LeadConvert__e(LeadId__c = leadId, AccountId__c = personIdByLeadId.get(leadId)));
        }
        EventBus.publish(leadConverts);
    }

    private void fillBrokerTextField(List<Lead> leads) {
        for(Lead lead : leads) {
            lead.BrokerText__c = lead.Broker__c;
        }
    }

    private void sendPreLeadEvent(List<Lead> leads) {
        List<Lead> leadsToPublish = new List<Lead>();

        for (Lead lead : leads) {
            if (lead.PreReg_Sent__c) {
                leadsToPublish.add(lead);
            }
        }

        OutboundMessageService.publishPreLeadMessage(leadsToPublish);
    }

    private void updateAutoTaskBatches(List<Lead> newLeads, Map<Id, SObject> oldMaps) {
        for (Lead lead : newLeads) {
            if (clones.get(lead.Id) != null) {
                Set<String> newAutoBatches = new Set<String>();
                for (Lead oldLead : clones.get(lead.id)) {
                    if (oldLead.AutoTask_Batches__c != null) {
                        newAutoBatches.addAll(oldLead.AutoTask_Batches__c.split(','));
                    }
                }
                if (lead.AutoTask_Batches__c != null) {
                    newAutoBatches.addAll(lead.AutoTask_Batches__c.split(','));
                }
                lead.AutoTask_Batches__c = String.join(new List<String>(newAutoBatches), ',');
            }
        }
    }

    private void mergeDealingGroups(List<Lead> newLeads, List<Lead> oldLeads) {
        Map<Id, Lead> newLeadsMap = new Map<Id, Lead>(newLeads);
        for (Lead lead : oldLeads) {
            if (clones.get(lead.Id) != null) {
                Datetime dealingGroupLastChanges = null;
                Map<String, Object> dealingGroupsListed = new Map<String, Object>();

                for (Lead oldLead : clones.get(lead.id)) {
                    dealingGroupLastChanges = checkChangesDealingGroups(dealingGroupLastChanges, dealingGroupsListed, oldLead);
                }
                dealingGroupLastChanges = checkChangesDealingGroups(dealingGroupLastChanges, dealingGroupsListed, lead);
                newLeadsMap.get(lead.Id).Dealing_group_last_change__c = dealingGroupLastChanges;

                if (!dealingGroupsListed.isEmpty()) {
                    newLeadsMap.get(lead.Id).DealingGroupsListed__c = JSON.serialize(dealingGroupsListed);

                    Set<String> groups = new Set<String>();
                    for (String key: dealingGroupsListed.keySet()) {
                        groups.add((String)dealingGroupsListed.get(key));
                    }
                    List<String> listGroups = new List<String>(groups);
                    newLeadsMap.get(lead.Id).Dealing_group__c = groups.size() == 1 ? listGroups.get(0) : 'Multiple groups';
                }
            }
        }
    }
    private Datetime checkChangesDealingGroups(Datetime dealingGroupLastChanges, Map<String, Object> dealingGroupsListed, Lead lead) {
        if (dealingGroupLastChanges == null || lead.Dealing_group_last_change__c > dealingGroupLastChanges) {
            dealingGroupLastChanges = lead.Dealing_group_last_change__c;
        }
        if (lead.DealingGroupsListed__c != null) {
            dealingGroupsListed.putAll((Map<String, Object>)JSON.deserializeUntyped(lead.DealingGroupsListed__c));
        }
        return dealingGroupLastChanges;
    }
    private void checkBroker(List<Lead> leads){

        List<Lead> leadsForUpdate = new List<Lead>();

        if (trigger.oldMap == null) leadsForUpdate = leads; else {
            for (Lead lead : leads) {
                if (lead.get('Broker__c') != trigger.oldMap.get(lead.id).get('Broker__c')) {
                    leadsForUpdate.add(lead);
                }
            }
        }

        if (leadsForUpdate.size() > 0) {

            for (Lead lead : leadsForUpdate) {
                for (Brokers_Settings__c settings : Brokers_Settings__c.getAll().values()) {
                    if (Utils.isContainsValueInMultiPicklist(string.valueOf(lead.get('Broker__c')), settings.Broker_Name_Must_Contain__c)
                            && lead.get(settings.BrokerCheckbox__c) == false) {
                        try {
                            lead.put(settings.BrokerCheckbox__c, true);
                        } catch (Exception ex) {
                            System.debug(LoggingLevel.ERROR, ex.getMessage());
                        }
                    }
                }
            }

        }
    }

    private void mergePartnerCodes(Map<Id, SObject> newLeads, List<Lead> oldLeads, Map<Id, List<Id>> oldLeadIdsByMasterId) {
        Set<Id> leadIdsForSearch = new Set<Id>();
        leadIdsForSearch.addAll(oldLeadIdsByMasterId.keySet());
        for (List<Id> leadIds : oldLeadIdsByMasterId.values()) {
            leadIdsForSearch.addAll(leadIds);
        }
        List<Attachment> fxUsersAttachments = Utils.getAttachmentByParentIdsAndDescription(new List<Id>(leadIdsForSearch), 'FxUser');
        Map<Id, Attachment> lastAttachsByMasterId = new Map<Id, Attachment>();
        for (Id masterId: oldLeadIdsByMasterId.keySet()) {
            Datetime lastFxUserDate = null;
            Attachment lastFxUser = null;
            for (Attachment att : fxUsersAttachments) {
                if ((att.ParentId == masterId || oldLeadIdsByMasterId.get(masterId).contains(att.ParentId)) && (lastFxUserDate == null || lastFxUserDate < att.CreatedDate)) {
                    lastFxUserDate = att.CreatedDate;
                    lastFxUser = att;
                }
            }
            lastAttachsByMasterId.put(masterId, lastFxUser);
        }
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeIBPartnerCodeAndAffiliateID') != null) {
            mergeIBPartnerCodeAndAffiliateID(lastAttachsByMasterId, newLeads);
        }
        if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergePartnerIds') != null) {
            if (TriggerAvailableMethod__c.getValues(ObjectName + '-' + 'MergeIBPartnerCodeAndAffiliateID') == null) {
                updateFieldsFromAttachment(lastAttachsByMasterId, newLeads, PartnerManager.PARTNER_CODE_MAP_FIELDS);
            }
            mergePartnerIds(newLeads, lastAttachsByMasterId.keySet());
        }
    }

    private void mergeIBPartnerCodeAndAffiliateID(Map<Id, Attachment> lastAttachsByMasterId, Map<Id, SObject> newLeads) {
        updateFieldsFromAttachment(lastAttachsByMasterId, newLeads, FxUserManager.PARTNER_CODE_MAP_FIELDS_FOR_ACCOUNT);
    }

    private void updateFieldsFromAttachment(Map<Id, Attachment> lastAttachsByMasterId, Map<Id, SObject> newLeads, Map<String, String> fieldsMap) {
        for (Id masterLeadId: lastAttachsByMasterId.keySet()) {
            Attachment lastAttach = lastAttachsByMasterId.get(masterLeadId);
            if (lastAttach != null) {
                FxUser__c latestFxUser = (FxUser__c) JSON.deserialize(lastAttach.Body.toString(), FxUser__c.class);
            	SObject client = newLeads.get(masterLeadId);
            	Utils.setFieldsFromToSobject(latestFxUser, client, fieldsMap);
            }
        }
    }

    private void mergePartnerIds(Map<Id, SObject> newLeads, Set<Id> masterLeadIds) {
        Set<String> partnerCodes = new Set<String>();
        Map<Id, Map<String, List<Lead>>> leadByCodeByRecordType = PartnerService.groupLeadsByPartnerCode(newLeads, masterLeadIds);

        for (Id recordTypeId : leadByCodeByRecordType.keySet()) {
            partnerCodes.addAll(leadByCodeByRecordType.get(recordTypeId).keySet());
        }

        List<Partner__c> partnerRecords = PartnerManager.getByPartnerCodes(partnerCodes);
        Map<Id, Map<String, Partner__c>> partnerByCodeByRecordType = PartnerService.groupPartnersByPartnerCode(partnerRecords);

        cleanPartnerName(newLeads.values());
        updatePartnerOnLeads(leadByCodeByRecordType, partnerByCodeByRecordType);
    }

    private void cleanPartnerName(List<SObject> leads) {
        for (SObject lead: leads) {
            Utils.cleanFields(lead, new Set<String> {'Partner_Name__c'});
        }
    }

    private void updatePartnerOnLeads(Map<Id, Map<String, List<Lead>>> leadByCodeByRecordType, Map<Id, Map<String, Partner__c>> partnerByCodeByRecordType) {
        for (Id recordTypeId : leadByCodeByRecordType.keySet()) {
            for (String partnerCode : leadByCodeByRecordType.get(recordTypeId).keySet()) {
                if (partnerByCodeByRecordType.get(recordTypeId) == null) continue;

                Partner__c partnerRecord = partnerByCodeByRecordType.get(recordTypeId)?.get(partnerCode);

                if (partnerRecord == null) continue;

                for (Lead lead : leadByCodeByRecordType.get(recordTypeId).get(partnerCode)) {
                    lead.Partner_Name__c = partnerRecord.Id;
                }
            }
        }
    }

    private void updateFxUserPartnerCodes(List<Lead> newLeads, List<Lead> oldLeads, Map<Id, List<Lead>> clones) {
        List<Lead> leadsForUpdatingFxUsers = new List<Lead>();
        if (clones != null) {
            for (Lead lead : newLeads) {
                if (clones.get(lead.id) != null && Lead.IBPartnerCodeOrAffiliateIDLastUpdate__c != null) {
                    leadsForUpdatingFxUsers.add(lead);
                }
            }
        } else {
            for (Integer i = 0; i < trigger.size; i++) {
                Lead lead = newLeads[i];
                Lead oldLead = oldLeads[i];

                if ((lead.AffiliateID__c != oldLead.AffiliateID__c
                        || lead.IBPartnerCode__c != oldLead.IBPartnerCode__c
                        || lead.Partner_Network__c != oldLead.Partner_Network__c
                        || lead.Affiliate_Network__c != oldLead.Affiliate_Network__c
                        || lead.CXD_Long__c != oldLead.CXD_Long__c
                    ) && lead.IBPartnerCodeOrAffiliateIDLastUpdate__c != null) {
                    leadsForUpdatingFxUsers.add(lead);
                }
            }
        }
        if (!leadsForUpdatingFxUsers.isEmpty()) {
            FxUserManager.updateLeadPartnerCode(new Map<Id, Lead>(leadsForUpdatingFxUsers));
        }
    }
    
    private void updatePartnerCodeLastUpdate(List<Lead> newLeads,  List<Lead> oldLeads){
        for (Integer i = 0; i < trigger.size; i++) {
            Lead lead = newLeads[i];
            Lead oldLead = oldLeads[i];

            if ((lead.AffiliateID__c != oldLead.AffiliateID__c
                    || lead.IBPartnerCode__c != oldLead.IBPartnerCode__c
                    || lead.Affiliate_Network__c != oldLead.Affiliate_Network__c
                    || lead.Partner_Network__c != oldLead.Partner_Network__c
                    || lead.CXD_Long__c != oldLead.CXD_Long__c
                )
                    && lead.IBPartnerCodeOrAffiliateIDLastUpdate__c == oldLead.IBPartnerCodeOrAffiliateIDLastUpdate__c){
                lead.put('IBPartnerCodeOrAffiliateIDLastUpdate__c',datetime.now());
            }
        }
    }

    private void updateConvertedLeadStatus(List<Lead> newLeads,  List<Lead> oldLeads){
        for (Integer i = 0; i < trigger.size; i++) {
            if (newLeads.get(i).IsConverted && newLeads.get(i).Status != oldLeads.get(i).Status && newLeads.get(i).Status == 'Open') {
                newLeads.get(i).Status = oldLeads.get(i).Status;
                newLeads.get(i).OwnerId = oldLeads.get(i).OwnerId;
            }
        }
    }

    private void moveCasesToAccount(Map<Id, Id> personIdByLeadId) {
        List<Case> leadsCases = [
                select Id, AccountId, Lead__c
                from Case
                where
                        Lead__c in :personIdByLeadId.keySet()];
        for (Case leadsCase: leadsCases) {
            leadsCase.AccountId = personIdByLeadId.get(leadsCase.Lead__c);
            leadsCase.Lead__c = null;
        }
        Database.update(leadsCases);
    }

    private void manualShareByPartnerCodes(List<Lead> newLeads,  List<Lead> oldLeads) {
        Map<Id, List<String>> shareRecords = new Map<Id, List<String>>();
        Map<Id, List<String>> shareRecordsForDeleteOnly = new Map<Id, List<String>>();
        for (Integer i = 0; i < Trigger.size; i++) {
            if (Trigger.isInsert && ((newLeads[i].AffiliateID__c != null) || (newLeads[i].IBPartnerCode__c != null))
                    || (Trigger.isUpdate && !newLeads[i].IsConverted && (
                        Utils.checkIfFieldsHasBeenChanged(oldLeads[i], newLeads[i], new Set<String>{'AffiliateID__c', 'Affiliate_Network__c', 'IBPartnerCode__c', 'Partner_Network__c'}) ||
                        Utils.checkIfFieldsHasBeenChanged(oldLeads[i], newLeads[i], new Set<String>{'OwnerId'}) ||
                        Utils.checkIfFieldsHasBeenChanged(oldLeads[i], newLeads[i], new Set<String>{'Hide_From_Partner__c'})))) {
                            if(!newLeads[i].Hide_From_Partner__c){
                                shareRecords.put(newLeads[i].Id, new List<String>{
                                    newLeads[i].AffiliateID__c, newLeads[i].Affiliate_Network__c, newLeads[i].IBPartnerCode__c, newLeads[i].Partner_Network__c
                                });
                            }else{
                                shareRecordsForDeleteOnly.put(newLeads[i].Id, new List<String>{
                                    newLeads[i].AffiliateID__c, newLeads[i].Affiliate_Network__c, newLeads[i].IBPartnerCode__c, newLeads[i].Partner_Network__c
                                });
                            }
                
            } else if (Trigger.isUpdate && ((Utils.checkIfFieldsHasBeenChanged(oldLeads[i], newLeads[i], new Set<String>{'IsConverted'}) ||
                       (Utils.checkIfFieldsHasBeenChanged(oldLeads[i], newLeads[i], new Set<String>{'Hide_From_Partner__c'}) && newLeads[i].Hide_From_Partner__c)))){
                            shareRecordsForDeleteOnly.put(newLeads[i].Id, new List<String>{
                                    newLeads[i].AffiliateID__c, newLeads[i].Affiliate_Network__c, newLeads[i].IBPartnerCode__c, newLeads[i].Partner_Network__c
                            });
            }
        }
        if (shareRecords.size() > 0) {
            SharingService.createSharingRecords('LeadShare', shareRecords, Trigger.isInsert ? false : true, 'Edit', 'Manual');
        }
        if (shareRecordsForDeleteOnly.size() > 0) {
            SharingService.createSharingRecords('LeadShare', shareRecordsForDeleteOnly, true, false, 'Edit', 'Manual');            
        }
    }

    private void mergeHideFromPartnerUser(List<Lead> newLeads, Map<Id, List<Lead>> clones, Map<Id, SObject> oldMaps) {
        for (Lead lead : newLeads) {
            if (clones != null && clones.get(lead.Id) != null) {
                lead.Hide_From_Partner__c = ((Lead)oldMaps.get(lead.id)).Hide_From_Partner__c;
            }
        }
    }

    private void updateHideFromPartner(List<Lead> newLeads,  List<Lead> oldLeads){
        for (Integer i = 0; i < trigger.size; i++) {
            Lead lead = newLeads[i];
            Lead oldLead = oldLeads[i];

            if ((lead.AffiliateID__c != oldLead.AffiliateID__c
                    || lead.IBPartnerCode__c != oldLead.IBPartnerCode__c
                    || lead.Affiliate_Network__c != oldLead.Affiliate_Network__c
                    || lead.Partner_Network__c != oldLead.Partner_Network__c
                    || lead.CXD_Long__c != oldLead.CXD_Long__c
                )
                    && lead.Hide_From_Partner__c){
                lead.put('Hide_From_Partner__c',false);
            }
        }
    }

    private void mergeIslamicAccount(List<Lead> newLeads, Map<Id, List<Lead>> clones) {
        for (Lead winnerLead : newLeads) {
            if (!winnerLead.Islamic_account__c && clones != null && clones.get(winnerLead.Id) != null) {
                for (Lead loserLead : clones.get(winnerLead.Id)) {
                    if(loserLead.Islamic_account__c) {
                        winnerLead.Islamic_account__c = true;
                        break;
                    }
                }
            }
        }
    }

    private void mergeMetamaskRegistration(List<Lead> newLeads, Map<Id, SObject> oldMaps, Map<Id, List<Lead>> clones) {
        for (Lead newLead : newLeads) {
            if (!newLead.Metamask_Registration__c && clones != null && clones.get(newLead.Id) != null) {
                List<Lead> clonesAndOldLead = new List<Lead>(clones.get(newLead.Id));
                clonesAndOldLead.add(((Lead)oldMaps.get(newLead.Id)));
                for (Lead oldLead : clonesAndOldLead) {
                    if (oldLead.Metamask_Registration__c) {
                        newLead.Metamask_Registration__c = true;
                        break;
                    }
                }
            }
        }
    }

    private void mergeBranchDiffersFromParentBranch(List<Lead> newLeads, Map<Id, List<Lead>> clones, Map<Id, SObject> oldMaps) {
        for (Lead newLead : newLeads) {
            if ((newLead.FilialIdGlob__c == (String) oldMaps.get(newLead.Id).get('FilialIdGlob__c'))
                    && clones.get(newLead.Id) != null) {
                for (Lead loser : clones.get(newLead.Id)) {
                    if (loser.FilialIdGlob__c != newLead.FilialIdGlob__c) {
                        newLead.BranchDiffersFromParentBranch__c = true;
                        break;
                    }
                }
            }
        }
    }

    private void mergeUnsubscribedByGDPR(List<Lead> newLeads, Map<Id, SObject> oldMaps, Map<Id, List<Lead>> clones) {
        for (Lead newLead : newLeads) {
            if (clones.get(newLead.Id) != null) {
                List<Lead> clonesAndOldLead = new List<Lead>(clones.get(newLead.Id));
                clonesAndOldLead.add(((Lead)oldMaps.get(newLead.Id)));
                for (Lead oldLead : clonesAndOldLead) {
                    if (oldLead.Unsubscribed_by_GDPR__c) {
                        newLead.Unsubscribed_by_GDPR__c = true;
                        newLead.DoNotCall = true;
                        newLead.SMS_Opt_Out__c = true;
                        newLead.HasOptedOutOfEmail = true;
                        break;
                    }
                }
            }
        }
    }

    private void sendCrmLeadStatusEvent(List<Lead> updatedLeads) {
        List<ESB.CrmLeadStatusMessage> leadStatusMessages = new List<ESB.CrmLeadStatusMessage>();

        Map<Id, String> leadIdToNewStatus = new Map<Id, String>();
        for (Lead lead : updatedLeads) {
            if (lead.IsConverted) continue;
            leadIdToNewStatus.put(lead.Id, lead.Status);
        }

        List<Attachment> leadFxUserAttachments = AttachmentManager.getAttachmentsByParentIdAndDescriptions(
                leadIdToNewStatus.keySet(),
                new List<String>{
                        'FxUser'
                }
        );

        for (Attachment attachment : leadFxUserAttachments) {
            String clientId = attachment.Name.remove(AttachmentManager.FX_USER_ATTACHMENT_NAME_POSTFIX);
            leadStatusMessages.add(new ESB.CrmLeadStatusMessage(clientId, leadIdToNewStatus.get(attachment.ParentId)));
        }

        OutboundMessageService.sendCrmLeadStatusEvent(leadStatusMessages);
    }

    private List<SObject> getOtherMasterLeadsForSendCrmLeadStatusEvent(Set<Id> excludedLeadIds) {
        List<SObject> otherMasterLeads = new List<Lead>();
        for (Id masterLeadId : clones.keySet()) {
            SObject masterLead = Trigger.newMap.get(masterLeadId);
            if (excludedLeadIds.contains(masterLeadId)
                    || clones.get(masterLeadId).isEmpty()
                    || masterLead == null) {
                continue;
            }
            String masterLeadStatus = (String) masterLead.get('Status');
            for (Lead loserLead : clones.get(masterLeadId)) {
                if (masterLeadStatus != loserLead.Status) otherMasterLeads.add(masterLead);
                break;
            }
        }
        return otherMasterLeads;
    }

    private void mergeLeadStatus(List<Lead> newLeads, Map<Id, List<Lead>> clones, Map<Id, SObject> oldMaps) {
        if (LeadManager.leadStatusHierarchyByName == null) {
            LeadManager.leadStatusHierarchyByName = Utils.mapByField('MasterLabel', (List<SObject>) [SELECT MasterLabel, Hierarchy_Index__c FROM LeadStatusHierarchy__mdt]);
        }

        Integer hierarchyIndex = 0;
        for (Lead newLead : newLeads) {
            if (clones.get(newLead.Id) != null) {
                List<Lead> clonesAndOldLead = new List<Lead>(clones.get(newLead.Id));
                clonesAndOldLead.add((Lead)oldMaps.get(newLead.Id));
                for (Lead oldLead : clonesAndOldLead) {
                    SObject currentStatusHierarchy = LeadManager.leadStatusHierarchyByName.get(oldLead.Status);
                    if (currentStatusHierarchy != null) {
                        Integer currentIndex = Integer.valueOf(currentStatusHierarchy.get('Hierarchy_Index__c'));
                        if (currentIndex > hierarchyIndex) {
                            newLead.Status = (String) currentStatusHierarchy.get('MasterLabel');
                            hierarchyIndex = currentIndex;
                        }
                    }
                }
                hierarchyIndex = 0;
            }
        }
    }

    private void mergeFxUserCountries(List<Lead> newLeads, Map<Id, List<Lead>> clones, Map<Id, SObject> oldMaps) {
        for (Lead newLead : newLeads) {
            String result = '';
            if (clones.get(newLead.Id) != null) {
                List<Lead> clonesAndOldLead = new List<Lead>(clones.get(newLead.Id));
                clonesAndOldLead.add(((Lead)oldMaps.get(newLead.Id)));
                for (Lead oldLead : clonesAndOldLead) {
                    result = Utils.addToMultiPicklist(result, oldLead.FxUserCountries__c);
                }
            }
            newLead.FxUserCountries__c = result;
        }
    }
}