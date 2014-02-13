package fst.txml;

import fst.txml.TXmlAttribute;


/**
* Nodes
*
*/
class TXmlNode extends TXmlElement {

    /** children nodes */
    private var _children : Array<TXmlNode>;
    /** attributes of this node */
    private var _attributes : Array<TXmlAttribute>;


    /**
    * Constructor
    *
    */
    private function new () : Void {
        super();

        this._attributes = [];
        this._children   = [];
    }//function new()


    /**
    * Get children of this node
    *
    */
    public function getChildren () : Array<TXmlNode> {
        return this._children.copy();
    }//function getChildren()


    /**
    * Get attributes of this node
    *
    */
    public function getAttributes () : Array<TXmlAttribute> {
        return this._attributes.copy();
    }//function getAttributes()

}//class TXmlNode