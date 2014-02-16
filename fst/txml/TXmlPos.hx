package fst.txml;


using fst.txml.ParsingTools;


/**
* Position information.
* All indexes starts at zero.
*/
class TXmlPos {

    /** line number of current position */
    public var line (default,null) : Int = 0;
    /** current character index of this position related to document */
    public var index (default,null) : Int = -1;
    /** current character index of this position related to line start */
    public var lineIndex (default,null) : Int = -1;


    /**
    * Constructor
    *
    */
    private function new () : Void {

    }//function new()


    /**
    * Clone current position info
    *
    */
    public function clone () : TXmlPos {
        var pos : TXmlPos = new TXmlPos();

        pos.line      = this.line;
        pos.index     = this.index;
        pos.lineIndex = this.lineIndex;

        return pos;
    }//function clone()


    /**
    * Get string representation
    *
    */
    public function toString () : String {
        return '(line:${line + 1}, pos:${lineIndex + 1})';
    }//function toString()
}//class TXmlPos