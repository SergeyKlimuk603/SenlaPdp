import { LightningElement } from 'lwc';
import templateOne from "./lifecycleHooksParent.html";

export default class LifecycleHooksParent extends LightningElement {
    show = true;
    handleShowHide() {
        console.log('-----lifecycleHooks parent handleShowHide()');
        this.show = !this.show;
    }

    handleButton() {
        console.log('-----lifecycleHooks parent handleButton()');
    }

    constructor() {
        super();
        console.log('-----lifecycleHooks parent constructor()');
    }
    
    connectedCallback() {
        console.log('-----lifecycleHooks parent connectedCallback()');
    }
    
    renderedCallback() {
        console.log('-----lifecycleHooks parent renderedCallback()');
    }
    
    render() {
        console.log('-----lifecycleHooks parent render()');
        return templateOne;
    }
    
    disconnectedCallback() {
        console.log('-----lifecycleHooks parent disconnected callback')
    }
    
    errorCallback() {
        console.log('-----lifecycleHooks parent errorCallback()');
    }
}