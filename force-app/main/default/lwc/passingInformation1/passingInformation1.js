import { LightningElement } from 'lwc';

export default class PassingInformation1 extends LightningElement {

    variable1 = 'some value1';
    variable2 = 'some value2';

    changeHandler1(event) {
        this.variable1 = event.target.value;
    }

    myEventHandler(event) {
        console.log('-----myEventHandler()');
        console.log('-----event.variable1_2', event.variable1_2);
        console.log('-----event.detail', event.detail);
        console.log('-----event.detail', event.detail.variable1_2);
        this.variable2 = event.detail.variable1_2;
    }

}