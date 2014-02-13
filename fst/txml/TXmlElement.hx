package fst.txml;


/**
* Base TXml element
*
*/
class TXmlElement {

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