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


    // /**
    // * Advance position infos to the next character of this string
    // *
    // * @return - next character of this string
    // */
    // private function _advance (string:String) : Int {
    //     if( string.length <= this.index + 1 ){
    //         throw new fst.txml.TXmlException(this, 'Unexpected end of string');
    //     }

    //     var c : Int = string.fastCodeAt(this.index + 1);

    //     if( c.isNL() ){
    //         this.line ++;
    //         this.lineIndex = 0;
    //     }else{
    //         this.lineIndex ++;
    //     }
    //     this.index ++;

    //     return c;
    // }//function _advance()


    // /**
    // * Revert position
    // *
    // */
    // private function _revert (char:String) : Void {
    //     if( char.isNL() ){
    //         this.line --;
    //     }

    //     this.lineIndex --;
    //     this.index --;
    // }//function _revert()


    // /**
    // * Revert position infos to specified index
    // *
    // */
    // private inline function _revertTo (str:String, to:Int) : Void {
    //     while( this.index > to ){
    //         this._revert( str.charAt(this.index) );
    //     }
    // }//function _revertTo()


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
        return '(line:${line + 1}, pos:${index + 1})';
    }//function toString()
}//class TXmlPos