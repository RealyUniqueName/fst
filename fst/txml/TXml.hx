package fst.txml;

import fst.txml.TXml;
import fst.txml.TXmlAttribute;
import fst.txml.TXmlException;
import fst.txml.TXmlNode;
import fst.txml.TXmlPos;
import haxe.CallStack;


using StringTools;
// using fst.txml.MacroTools;
using fst.txml.ParsingTools;


/**
* (Truncated) XML parser with positons info.
*   Does not support namespaces, CDATA. Values of attributes must be enclosed in double quotes.
*
* TXml is:
*   ~1.5 times slower than std Xml parser on cpp
*   ~10 times slower on neko
*   ~3 times slower on flash (tested in 11.2 32bit linux stand alone player)
*   = on js (tested in Chrome 32.0)
* But TXml has pos infos and verbose error reporting and behaves identically on all platforms :)
*/
@:access(fst.txml)
class TXml {
    /** source string */
    private var str : String;
    /** current position of parser inside that string */
    private var pos : TXmlPos;
    /** last index for iteration over characters in string */
    private var _lastIdx : Int = 0;

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
        this._lastIdx = str.length - 1;

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
        var c     : Int;
        var nextc : Int;

        //find node start
        while( this.pos.index < this._lastIdx ){
            c = this._skipSpaces();

            //wtf is this?
            if( c != MacroTools.code('<') ){
                this._revertPos();
                idx = this.pos.index;
                var s : String = this._copyTillSpace().shorten();
                this._revertPosTo(idx);
                throw new TXmlException(this.pos, '"<" expected, but "$s" found', 0, []);

            //found node start
            }else {
                nextc = this.str.fastCodeAt(this.pos.index + 1);
                idx   = this.pos.index;

                //if this is a closing tag for previous node
                if( nextc == MacroTools.code('/') ){
                    this._revertPos();
                    return null;
                }

                //if this is a comment
                if( nextc == MacroTools.code('!') ){
                    if( this.str.substr(idx, 4) != '<!--' ){
                        var s : String = ('<!' + this._copyTillSpace()).shorten();
                        throw new TXmlException(this.pos, '"<!--" expected, but "$s" found', 0, []);
                    }
                    this._skipComment();

                //this should be a node
                }else{
                    var node  = new TXmlNode();
                    node.pos  = this.pos.clone();
                    node.name = this._findName();
                    if( node.name == null ){
                        var s : String = this.str.substring(idx, this.pos.index + 1).shorten();
                        this._revertPosTo(idx);
                        throw new TXmlException(this.pos, 'Node name expected, but "$s" found', 0, []);
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

        var c : Int = this._skipSpaces();

        //closing node ?
        if( c == MacroTools.code('/') ){
            c = this._advancePos();
            if( c != MacroTools.code('>') ){
                throw new TXmlException(this.pos, '">" expected, but "' + MacroTools.char(c) +'" found', 0, []);
            }

        //closing tag
        }else if( c == MacroTools.code('>') ){

            var valuePos : TXmlPos = this.pos.clone();
            var idx : Int = this.pos.index + 1;
            c = this._skipSpaces();

            //look for simple text content
            if( c != MacroTools.code('<') ){
                node.value = this.str.substring(idx, pos.index + 1) + this._copyTill(MacroTools.code('<'), false);
                c = this._advancePos();

                while( c != MacroTools.code('/') ){
                    node.value += '<' + MacroTools.char(c) + this._copyTill(MacroTools.code('<'), false);
                    //check we have enough chars for tag closing
                    if( this._lastIdx <= this.pos.index ){
                        throw new TXmlException(this.pos, '"</${node.name}>" expected, but end of document found', 0, []);
                    }
                    c = this.str.fastCodeAt(this.pos.index + 1);
                }
                node.value = node.value.htmlUnescape();
                this._revertPos();

                node.valuePos = valuePos;

            // look for child nodes
            }else{
                this._revertPos();
                //find child nodes
                var child : TXmlNode = this._parse();
                while( child != null ){
                    child._idx   = node._children.push(child) - 1;
                    child.parent = node;
                    child = this._parse();
                }
            }

            //look for node closing {
                c = this._skipSpaces();
                idx = this.pos.index;

                //simple text content?
                if( c != MacroTools.code('<') ){
                    var s : String = (MacroTools.char(c) + this._copyTillSpace()).shorten();
                    throw new TXmlException(this.pos, '"</${node.name}>" expected, but "$s" found', 0, []);
                }
                c = this._advancePos();
                var name : String = this._findName();
                if( c != MacroTools.code('/') || name != node.name ){
                    var s : String = (this.str.substring(idx, this.pos.index + 1) + this._copyTillSpace()).shorten();
                    this._revertPosTo(idx);
                    throw new TXmlException(this.pos, '"</${node.name}>" expected, but "$s" found', 0, []);
                }
                c = this._skipSpaces();
                if( c != MacroTools.code('>') ){
                    var s : String = (this.str.substring(idx, this.pos.index + 1) + this._copyTillSpace()).shorten();
                    this._revertPosTo(idx);
                    throw new TXmlException(this.pos, '"</${node.name}>" expected, but "$s" found', 0, []);
                }
            //}

        //wtf is this?
        }else{
            var s : String = (MacroTools.char(c) + this._copyTillSpace()).shorten();
            throw new TXmlException(this.pos, '"</${node.name}>" expected, but "$s" found', 0, []);
        }

        return node;
    }//function _findTagEnd()


    /**
    * Advance pos infos to skip xml declaration
    *
    */
    private function _skipDeclaration () : Void {
        var c    : Int;

        //find declaration start
        while( this.pos.index < this._lastIdx ){
            c = this._advancePos();

            //find '<'
            if( c == MacroTools.code('<') ){
                //if next character is '?' andvance to the end of declaration
                if( this.str.fastCodeAt(this.pos.index + 1) == MacroTools.code('?') ){
                    break;

                //otherwise rollback and continue parsing
                }else{
                    this._revertPos();
                    return;
                }
            }
        }

        //find declaration end
        while( this.pos.index < this._lastIdx ){
            c = this._advancePos();

            if( c == MacroTools.code('?') && this.str.fastCodeAt(this.pos.index + 1) == MacroTools.code('>') ){
                this._advancePos();
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
        var c     : Int;
        var begin : Int = -1;

        //find first character of a name
        while( this.pos.index < this._lastIdx ){
            c = this._advancePos();

            if( c.isForName() ){
                begin = this.pos.index;
                break;
            }
        }

        //find the rest of a name
        if( begin >= 0 ){
            while( this.pos.index < this._lastIdx ){
                c = this._advancePos();
                //found!
                if( c.isNotForName() ){
                    this._revertPos();
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
    private function _skipSpaces () : Int {
        var c : Int;

        while( this.pos.index < this._lastIdx ){
            c = this._advancePos();

            if( !c.isSpace() ){
                return c;
            }
        }

        throw new TXmlException(this.pos, 'Unexpected end of document', 0, []);
        return -1;
    }//function _skipSpaces()


    /**
    * Advance to the end of a comment
    *
    */
    private function _skipComment () : Void {
        var c : Int;

        while( this.pos.index < this._lastIdx ){
            c = this._advancePos();
            //found end of comment
            if( c == MacroTools.code('-') && this.str.substr(this.pos.index, 3) == '-->' ){
                this._advancePos();
                this._advancePos();
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
        var c    : Int;
        var copy : StringBuf = new StringBuf();

        while( this.pos.index < this._lastIdx ){
            c = this._advancePos();

            //found space character
            if( c.isSpace() ){
                break;
            }else{
                copy.addChar(c);
            }
        };

        return copy.toString();
    }//function _copyTillSpace()


    /**
    * Get a copy of string starting from current pos and ending before next specified character
    *
    * @param char
    * @param setPosBefore - set final position before that "char" or at that "char"
    */
    private function _copyTill (char:Int, setPosBefore:Bool = true) : String {
        var c    : Int;
        var copy : StringBuf = new StringBuf();

        while( this.pos.index < this._lastIdx ){
            c = this._advancePos();

            //found space character
            if( c == char ){
                if( setPosBefore ){
                    this._revertPos();
                }
                break;
            }else{
                copy.addChar(c);
            }
        };

        return copy.toString();
    }//function _copyTill()


    /**
    * Find attribute in current position
    *
    */
    private function _findAttribute () : Null<TXmlAttribute> {
        var c : Int = this._skipSpaces();
        //end of tag ?
        if( MacroTools.isIn(c, '/>') ){
            this._revertPos();
            return null;
        }
        this._revertPos();

        if( c.isNotForName() ){
            throw new TXmlException(this.pos, 'Unexpected "' + MacroTools.char(c) + '"');
        }

        var attrPos : TXmlPos = this.pos.clone();
        var name    : String = this._findName();
        if( name == null ) {
            return null;
        }

        //find '='
        c = this._skipSpaces();
        if( c != MacroTools.code('=') ){
            var errPos : TXmlPos = this.pos.clone();
            var s : String = (MacroTools.char(c) + this._copyTillSpace()).shorten();
            throw new TXmlException(errPos, '"=" expected, but "$s" found', 0, []);
        }

        var idx   : Int = this.pos.index;
        c = this._skipSpaces();

        var valuePos : TXmlPos = this.pos.clone();
        var value    : String = null;

        //find value
        if( c == MacroTools.code('"') ){
            value = this._copyTill(MacroTools.code('"'), false).htmlUnescape();
        }
        if( value == null ){
            var s : String = (this.str.substring(idx, pos.index + 1) + this._copyTillSpace()).shorten();
            throw new TXmlException(attrPos, 'Attribute value expected, but "$s" found', 0, []);
        }

        var attr = new TXmlAttribute();
        attr.pos      = attrPos;
        attr.name     = name;
        attr.value    = value;
        attr.valuePos = valuePos;

        return attr;
    }//function _findAttribute()


    /**
    * Add attribute to this node
    *
    */
    private function _addAttribute (node:TXmlNode, attr:TXmlAttribute) : Void {
        //check if such attribute already exists
        if( node._attrMap.get(attr.name) != null ){
            throw new TXmlException(this.pos, 'Duplicated attribute name: "${attr.name}"', 0, []);
        }


        attr._idx = node._attributes.push(attr);
        node._attrMap.set(attr.name, attr);
    }//function _addAttribute()


    /**
    * Advance position infos to the next character of this string
    *
    * @return - next character of this string
    */
    private function _advancePos () : Int {
        if( pos.index  >= this._lastIdx ){
            throw new fst.txml.TXmlException(this.pos, 'Unexpected end of document');
        }

        var c : Int = this.str.fastCodeAt(this.pos.index + 1);

        if( c.isNL() ){
            this.pos.line ++;
            this.pos.lineIndex = 0;
        }else{
            this.pos.lineIndex ++;
        }
        this.pos.index ++;

        return c;
    }//function _advancePos()


    /**
    * Revert position
    *
    */
    private function _revertPos () : Void {
        var char : Int = this.str.fastCodeAt(this.pos.index);

        if( char.isNL() ){
            this.pos.line --;
        }

        this.pos.lineIndex --;
        this.pos.index --;
    }//function _revertPos()


    /**
    * Revert position infos to specified index
    *
    */
    private inline function _revertPosTo (to:Int) : Void {
        while( this.pos.index > to ){
            this._revertPos();
        }
    }//function _revertPosTo()

}//class TXml