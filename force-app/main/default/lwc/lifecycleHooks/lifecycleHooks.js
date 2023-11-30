import { LightningElement } from 'lwc';

export default class LifecycleHooks extends LightningElement {
    // source: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_lifecycle_hooks

    constructor() {
        super();
        console.log('-----lifecycleHooks constructor()');
    }
    
    connectedCallback() {
        console.log('-----lifecycleHooks connectedCallback()');
        
    }
    
    renderedCallback() {
        console.log('-----lifecycleHooks renderedCallback()');
        
    }
    
//    render() {
//        console.log('-----lifecycleHooks render()');
//        
//    }
    
    disconnectedCallback() {
        console.log('-----lifecycleHooks disconnectedCallback()');
        
    }
    
    errorCallback() {
        console.log('-----lifecycleHooks errorCallback()');

    }
}