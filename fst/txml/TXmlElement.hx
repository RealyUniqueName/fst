package fst.txml;


/**
* Base TXml element
*
*/
class TXmlElement {
    /** index of this element in a collection of simila elements */
    private var _idx : Int = -1;
    /** element name */
    public var name (default,null) : String;
    /** position info for this element */
    public var pos (default,null) : TXmlPos;


    /**
    * Constructor
    *
    */
    private function new () : Void {
    }//function new()

}//class TXmlElement