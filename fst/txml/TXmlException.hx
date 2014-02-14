package fst.txml;

import fst.exception.Exception;
import haxe.CallStack;
import fst.txml.TXmlPos;


/**
* TXml related exceptions
*
*/
class TXmlException extends Exception {
    // /** dummy call stack used to prevent parser exceptions from generationg callstack */
    // static private var _dummyStack : Array<StackItem> = [];


    /** position of character in xml string which caused this exception */
    public var pos (default,null) : TXmlPos;


    /**
    * Constructor
    *
    */
    public function new (pos:TXmlPos, msg:String, shiftStack:Int = 0, stack:Array<StackItem> = null) : Void {
        super(msg, shiftStack, stack);

        this.pos = pos.clone();
    }//function new()


    /**
    * Get string representation
    *
    */
    override public function toString () : String {
        var original : String = this.message;
        this.message += ' (Line:${this.pos.line + 1}, pos:${this.pos.lineIndex + 1})';
        var str : String = super.toString();
        this.message = original;

        return str;
    }//function toString()

}//class TXmlException