package fst.txml;

import fst.txml.TXml;
import fst.txml.TXmlAttribute;
import fst.txml.TXmlException;
import fst.txml.TXmlNode;
import fst.txml.TXmlPos;
import haxe.CallStack;


using StringTools;
using fst.txml.MacroTools;
using fst.txml.ParsingTools;



/**
* Parser
*
*/
@:access(fst.txml)
class TXml {
    /** source string */
    private var str : String;
    /** current position of parser inside that string */
    private var pos : TXmlPos;


    /**
    * Parse provided txml string
    *
    */
    static public function parse (str:String) : TXmlNode {
        try{
            var parser : TXml = new TXml();
            parser._init(str);

            return parser._parse();

        //parsing failed
        }catch(e:TXmlException){
            var stack : Array<StackItem> = CallStack.callStack();
            stack.shift();
            throw new TXmlException(e.pos, e.message, 0, stack);

            return null;
        }
    }//function parse()


    /**
    * Constructor
    *
    */
    private function new () : Void {
        //code...
    }//function new()


    /**
    * Initialize parser for parsing this string
    *
    */
    private function _init (str:String) : Void {
        this.str = str;
        this.pos = new TXmlPos();

        this._skipDeclaration();
    }//function _init()


    /**
    * Parse provided string as internal content of some node
    *
    */
    private function _parse () : TXmlNode {
        var node : TXmlNode = this._findTagStart();
        //node not found
        if( node == null ) {
            return null;
        }

        return this._findTagEnd(node);
    }//function _parse()


    /**
    * Find node at current position
    *
    */
    private function _findTagStart () : TXmlNode {
        var idx   : Int;
        var c     : String;
        var nextc : String;
        var last  : Int = this.str.length - 1;

        //find node start
        while( this.pos.index < last ){
            c = this._skipSpaces();

            //wtf is this?
            if( c != '<' ){
                this.pos._revert(c);
                c = this._copyTillSpace();
                throw new TXmlException(this.pos, '"<" expected, but "$c" found', 0, []);

            //found node start
            }else {
                nextc = this.str.charAt(this.pos.index + 1);
                idx   = this.pos.index;

                //if this is a closing tag for previous node
                if( nextc == '/'){
                    this.pos._revert(c);
                    return null;
                }

                //if this is a comment
                if( nextc == '!' ){
                    c = this.str.substr(idx, 4);
                    if( c != '<!--' ){
                        c = '<!' + this._copyTillSpace();
                        throw new TXmlException(this.pos, '"<!--" expected, but "$c" found', 0, []);
                    }
                    this._skipComment();

                //this should be a node
                }else{
                    var node  = new TXmlNode();
                    node.pos  = this.pos.clone();
                    node.name = this._findName();
                    if( node.name == null ){
                        c = this.str.substring(idx, this.pos.index + 1);
                        throw new TXmlException(this.pos, 'Node name expected, but "$c" found', 0, []);
                    }
                    return node;
                }
            }
        }

        return null;
    }//function _findTagStart()


    /**
    * Find tag closing
    *
    */
    private function _findTagEnd (node:TXmlNode) : TXmlNode {
        var attr : TXmlAttribute = this._findAttribute();
        while( attr != null ){
            this._addAttribute(node, attr);
            attr = this._findAttribute();
        }

        var c : String = this._skipSpaces();

        //closing node ?
        if( c == '/' ){
            c = this.pos._advance(str);
            if( c != '>' ){
                throw new TXmlException(this.pos, '">" expected, but "$c" found', 0, []);
            }

        //closing tag
        }else if( c == '>' ){

            //find child nodes
            var child : TXmlNode = this._parse();
            while( child != null ){
                node._children.push(child);
                child = this._parse();
            }

            //look for node closing {
                c = this._skipSpaces();
                var idx : Int = this.pos.index;

                if( c != '<' ){
                    c +=  this._copyTillSpace();
                    throw new TXmlException(this.pos, '"</${node.name}>" expected, but "$c" found', 0, []);
                }
                c = this.pos._advance(str);
                var name : String = this._findName();
                if( c != '/' || name != node.name ){
                    c = this.str.substring(idx, this.pos.index + 1) + this._copyTillSpace();
                    throw new TXmlException(this.pos, '"</${node.name}>" expected, but "$c" found', 0, []);
                }
                c = this._skipSpaces()                ;
                if( c != '>' ){
                    c = this.str.substring(idx, this.pos.index + 1) + this._copyTillSpace();
                    throw new TXmlException(this.pos, '"</${node.name}>" expected, but "$c" found', 0, []);
                }
            //}

        //wtf is this?
        }else{
            c += this._copyTillSpace();
            throw new TXmlException(this.pos, '"</${node.name}>" expected, but "$c" found', 0, []);
        }

        return node;
    }//function _findTagEnd()


    /**
    * Advance pos infos to skip xml declaration
    *
    */
    private function _skipDeclaration () : Void {
        var c    : String;
        var last : Int = this.str.length - 1;

        //find declaration start
        while( this.pos.index < last ){
            c = this.pos._advance(str);

            //find '<'
            if( c == '<' ){
                //if next character is '?' andvance to the end of declaration
                if( this.str.charAt(this.pos.index + 1) == '?' ){
                    break;

                //otherwise rollback and continue parsing
                }else{
                    this.pos._revert(c);
                    return;
                }
            }
        }

        //find declaration end
        while( this.pos.index < last ){
            c = this.pos._advance(str);

            if( c == '?' && this.str.charAt(this.pos.index + 1) == '>' ){
                return;
            }
        }

        //xml declaration end was not found
        throw new TXmlException(this.pos, 'Xml declaration end expected but not found', 0, []);
    }//function _skipDeclaration()


    /**
    * Find name fro node or attribute
    *
    */
    private function _findName () : String {
        var c     : String;
        var last  : Int = this.str.length - 1;
        var begin : Int = -1;

        //find first character of a name
        while( this.pos.index < last ){
            c = this.pos._advance(str);

            if( c.isForName() ){
                begin = this.pos.index;
                break;
            }
        }

        //find the rest of a name
        if( begin >= 0 ){
            while( this.pos.index < last ){
                c = this.pos._advance(str);
                //found!
                if( c.isNotForName() ){
                    this.pos._revert(c);
                    return this.str.substring(begin, this.pos.index + 1);
                }
            }
        }

        //name was not found
        return null;
    }//function _findName()


    /**
    * Skip space characters and return first non-space character encountered
    *
    */
    private function _skipSpaces () : String {
        var c     : String;
        var last  : Int = this.str.length - 1;

        while( this.pos.index < last ){
            c = this.pos._advance(str);

            if( !c.isSpace() ){
                return c;
            }
        }

        throw new TXmlException(this.pos, 'Unexpected end of document', 0, []);
        return null;
    }//function _skipSpaces()


    /**
    * Advance to the end of a comment
    *
    */
    private function _skipComment () : Void {
        var c     : String;
        var last  : Int = this.str.length - 1;

        while( this.pos.index < last ){
            c = this.pos._advance(str);
            //found end of comment
            if( c == '-' && this.str.substr(this.pos.index, 3) == '-->' ){
                this.pos._advance(str);
                this.pos._advance(str);
                return;
            }
        }

        throw new TXmlException(this.pos, '"-->" expected, but end of document found', 0, []);
        return null;
    }//function _skipComment()


    /**
    * Get a copy of string starting from current pos and ending before noext space character
    *
    */
    private function _copyTillSpace () : String {
        var c    : String;
        var copy : String = '';
        var last : Int = this.str.length - 1;

        while( this.pos.index < last ){
            c = this.pos._advance(str);

            //found space character
            if( c.isSpace() ){
                break;
            }else{
                copy += c;
            }
        };

        return copy;
    }//function _copyTillSpace()


    /**
    * Find attribute in current position
    *
    */
    private function _findAttribute () : Null<TXmlAttribute> {
        var c : String = this._skipSpaces();
        //end of tag ?
        if( c.isIn('/>') ){
            pos._revert(c);
            return null;
        }
        pos._revert(c);

        var name : String = this._findName();
        if( name == null ) {
            return null;
        }

        c = this._skipSpaces();
        if( c != '=' ){
            c += this._copyTillSpace();
            throw new TXmlException(this.pos, '"=" expected, but "$c" found', 0, []);
        }

        var idx   : Int = pos.index;
        var value : String = this._findValue();
        if( value == null ){
            c = str.substring(idx, pos.index + 1);
            throw new TXmlException(pos, 'Attribute value expected, but "$c" found', 0, []);
        }

        var attr : TXmlAttribute = new TXmlAttribute();
        attr.name  = name;
        attr.value = value;

        return attr;
    }//function _findAttribute()


    /**
    * Find value for attribute in current position
    *
    */
    private function _findValue () : String {
        var c     : String;
        var last  : Int = this.str.length - 1;
        var begin : Int = -1;

        //find first double quote
        while( this.pos.index < last ){
            c = this.pos._advance(str);

            if( c == '"' ){
                begin = this.pos.index + 1;
                break;
            }
        }

        //find second double quote
        if( begin >= 0 ){
            while( this.pos.index < last ){
                c = this.pos._advance(str);

                if( c == '"' ){
                    return this.str.substring(begin, this.pos.index).htmlUnescape();
                }
            }
        }

        //value was not found
        return null;
    }//function _findValue()


    /**
    * Add attribute to this node
    *
    */
    private function _addAttribute (node:TXmlNode, attr:TXmlAttribute) : Void {
        //check if such attribute already exists
        if( node._attrMap.get(attr.name) != null ){
            throw new TXmlException(this.pos, 'Duplicated attribute name: "${attr.name}"', 0, []);
        }

        node._attributes.push(attr);
        node._attrMap.set(attr.name, attr);
    }//function _addAttribute()


}//class TXml