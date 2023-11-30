import { LightningElement, api } from 'lwc';

export default class PassingInformation1_1 extends LightningElement {
    @api
    variable1_1 = 'some value 1_1';

    changeHandler1_1(event) {
        this.variable1_1 = event.target.value;
    }
}