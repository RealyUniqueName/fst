package fst.txml;

import fst.exception.Exception;
import haxe.CallStack;
import fst.txml.TXmlPos;


/**
* TXml related exceptions
*
*/
class TXmlException extends Exception {
    /** dummy call stack used to prevent parser exceptions from generationg callstack */
    static private var _dummyStack : Array<StackItem> = [];


    /** position of character in xml string which caused this exception */
    public var pos (default,null) : TXmlPos;


    /**
    * Constructor
    *
    */
    public function new (pos:TXmlPos, msg:String) : Void {
        super(msg, 0, TXmlException._dummyStack);

        this.pos = pos.clone();
    }//function new()

}//class TXmlException