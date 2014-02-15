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
    /** another storage of the same attributes */
    private var _attrMap : Map<String, TXmlAttribute>;
    /** if this node contains plain text */
    public var innerText (default,null) : String = null;
    /** parent node */
    public var parent (default,null) : TXmlNode;
    /** get next parent's child */
    public var nextSibling (get,never) : TXmlNode;
    /** get previous parent's child */
    public var previousSibling (get,never) : TXmlNode;
    /** first child in list of this node */
    public var firstChild (get,never) : TXmlNode;
    /** last child in list of this node */
    public var lastChild (get,never) : TXmlNode;


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
            return this.firstChild;

        }else{
            for(i in 0...this._children.length){
                if( this._children[i].name == name ){
                    return this._children[i];
                }
            }
        }

        return null;
    }//function getFirstChild()


    /**
    * Get last child
    *
    * @param name - return last child with this name
    */
    public function getLastChild (name:String = null) : Null<TXmlNode> {
        if( name == null ){
            return this.lastChild;

        }else{
            for(i in (-this._children.length + 1)...1){
                if( this._children[-i].name == name ){
                    return this._children[-i];
                }
            }
        }

        return null;
    }//function getLastChild()


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


    /**
    * Getter `nextSibling`.
    *
    */
    private inline function get_nextSibling () : TXmlNode {
        return (this.parent._children.length > this._idx + 1 ? this.parent._children[this._idx + 1] : null);
    }//function get_nextSibling


    /**
    * Getter `previousSibling`.
    *
    */
    private inline function get_previousSibling () : TXmlNode {
        return (this._idx > 0 ? this.parent._children[this._idx - 1] : null);
    }//function get_previousSibling


    /**
    * Getter `firstChild`.
    *
    */
    private inline function get_firstChild () : TXmlNode {
        return (this._children.length > 0 ? this._children[0] : null);
    }//function get_firstChild


    /**
    * Getter `lastChild`.
    *
    */
    private inline function get_lastChild () : TXmlNode {
        return (this._children.length > 0 ? this._children[ this._children.length - 1 ] : null);
    }//function get_lastChild

}//class TXmlNode