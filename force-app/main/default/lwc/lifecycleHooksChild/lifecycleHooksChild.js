import { LightningElement } from 'lwc';
import templateOne from "./lifecycleHooksChildTemplateOne.html";
import templateTwo from "./lifecycleHooksChildTemplateTwo.html";

export default class LifecycleHooksChild extends LightningElement {
    showTemplateOne = true;
    showTemplateTwo = true;

    constructor() {
        super();
        console.log('-----lifecycleHooks child constructor()');
    }
    
    connectedCallback() {
        console.log('-----lifecycleHooks child connectedCallback()');
    }
    
    renderedCallback() {
        console.log('-----lifecycleHooks child renderedCallback()');
    }
    
    // Переменные используемые в этом методе отслеживаются и в случае их изменения компонент перерисовывается,
    // вызываются render() и renderedCallback()
    render() {
        console.log('-----lifecycleHooks child render()');
        // this.showTemplateOne;
        // this.showTemplateTwo;
        return this.showTemplateTwo ? templateOne : templateTwo;
        //return templateTwo;
    }
    
    disconnectedCallback() {
        console.log('-----lifecycleHooks child disconnected callback')
    }
    
    errorCallback() {
        console.log('-----lifecycleHooks child errorCallback()');
    }

    switchTemplate() {
        console.log('-----lifecycleHooks child switchTemplate()');

        this.showTemplateOne = !this.showTemplateOne;
    }
}