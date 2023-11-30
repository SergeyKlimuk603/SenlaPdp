import { LightningElement, api } from 'lwc';

export default class PassingInformation1_2 extends LightningElement {
    @api
    variable1_2 = 'some value 1_2';

    changeHandler1_2(event) {
        this.variable1_2 = event.target.value;
        const myEvent = new CustomEvent('myevent', {variable1_2: event.target.value});
        this.dispatchEvent(myEvent);
    }
}