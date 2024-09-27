import { LightningElement , track,api , wire} from 'lwc';
import getCandidates from '@salesforce/apex/lwcPracticeData.getCandidates';
export default class LwcPractice extends LightningElement {

    //   @track candidates ;
    limit=2;
    candidates;
    @api myValue;

    @wire(getCandidates,{limitCandidate : '$limit'}) 
    wireGetCandidates(data,error){
        if(data){
            console.log('data',JSON.stringify(data));
            this.candidates = data;
        }else{
            console.log(error);
        }
    }

    handleChange(event){
        this.limit = event.target.value;

        // this.loadCanidates();
        console.log(this.limit);
    }
    //    loadCanidates(){
    //     getCandidates({limitCandidate : this.limit}).then(
    //         result =>{
    //             this.candidates =result;
    //         }
    //     )
    //    }
}