import { LightningElement, api } from 'lwc';

export default class PassingInformation1_1 extends LightningElement {
    @api
    variable1_1 = 'some value 1_1';
    @api
    objVariable;

    changeHandler1_1(event) {
        this.variable1_1 = event.target.value;
        this.objVariable.val = event.target.value + '_!!!';
    }
}