package fst.txml;

import fst.txml.TXmlAttribute;


/**
* Nodes
*
*/
class TXmlNode extends TXmlElement {
    /** if this instance is used at the moment */
    private var _isFree : Bool = true;
    /** children nodes */
    private var _children : Array<TXmlNode>;
    /** attributes of this node */
    private var _attributes : Array<TXmlAttribute>;
    /** another storage of the same attributes */
    private var _attrMap : Map<String, TXmlAttribute>;


    /**
    * Constructor
    *
    */
    private function new () : Void {
        super();

        this._attributes = [];
        this._children   = [];
        this._attrMap    = new Map();
    }//function new()


    /**
    * Get children of this node.
    *
    * @param name - only return children with this name
    */
    public function getChildren (name:String = null) : Array<TXmlNode> {
        //return all children
        if( name == null ){
            return this._children.copy();

        //return children with such name
        }else{
            var children : Array<TXmlNode> = [];
            for(i in 0...this._children.length){
                if( this._children[i].name == name ){
                    children.push(this._children[i]);
                }
            }
            return children;
        }
    }//function getChildren()


    /**
    * Get first child
    *
    * @param name - return first child with this name
    */
    public function getFirstChild (name:String = null) : Null<TXmlNode> {
        if( name == null ){
            if( this._children.length > 0 ){
                return this._children[0];
            }

        }else{
            for(i in 0...this._children.length){
                if( this._children[i].name == name ){
                    return this._children[i];
                }
            }
        }

        return null;
    }//function getChild()


    /**
    * Get attributes of this node
    *
    */
    public inline function getAttributes () : Array<TXmlAttribute> {
        return this._attributes.copy();
    }//function getAttributes()


    /**
    * Get attribute instance by name
    *
    */
    public inline function get (name:String) : Null<TXmlAttribute> {
        return this._attrMap.get(name);
    }//function get()


    /**
    * Get attribute value by name
    *
    */
    public inline function getValue (name:String) : Null<String> {
        var attr = this._attrMap.get(name);
        return (attr == null ? null : attr.value);
    }//function getValue()

}//class TXmlNode