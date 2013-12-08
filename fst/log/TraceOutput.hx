package fst.log;

import haxe.io.Output;



/**
* Default logger output for non-`sys` targets
*
*/
class TraceOuput extends Output{

    /**
    * trace string
    *
    */
    override public function writeString (s:String) : Void {
        trace(s);
    }//function writeString()

}//class TraceOuput