import { createElement } from 'lwc';
import ActiveJobPostings from 'c/activeJobPostings';
import {getActiveJobPostings} from 'lightning/uiRecordApi';
const mokegetJobPostings = require("./data/getJobPostings.json");
describe('c-active-job-postings', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test("test wire funcnility" , ()=>{
        const element = createElement("c-active-job-postings" , {is:ActiveJobPostings});
        document.body.appendChild(element);
        getActiveJobPostings.emit(mokegetJobPostings);

        return Promise.resolve().then(()=>{
            const content = element.shadowRoot.querySelector(".content");
            
        }
    })

});