package fst.txml;

import fst.txml.TXml;
import fst.txml.TXmlException;
import fst.txml.TXmlNode;
import fst.txml.TXmlPos;


using StringTools;
using fst.txml.ParsingTools;



/**
* Parser
*
*/
@:access(fst.txml)
class TXml {

    /**
    * Parse provided txml string
    *
    */
    static public inline function parse (str:String) : TXmlNode {
        var pos : TXmlPos = new TXmlPos();
        TXml._skipDeclaration(str, pos);

        return TXml._parse(str, pos);
    }//function parse()


    /**
    * Parse provided string as internal content of some node
    *
    */
    static private function _parse (str:String, pos:TXmlPos) : TXmlNode {
        var node : TXmlNode = null;

        var c    : String;
        var last : Int = str.length - 1;

        //find node start
        while(pos.index < last ){
            c = pos._advance(str);

            //found
            if( c == '<' ){
                //if this is a closing tag for previous node
                if( str.charAt(pos.index + 1) == '/'){
                    pos._revert(c);
                    return null;
                }

                node      = new TXmlNode();
                node.pos  = pos.clone();
                node.name = TXml._findName(str, pos);
                if( node.name == null ){
                    throw new TXmlException(node.pos, 'Node name expected but not found');
                }
                break;
            }
        }
        //node not found
        if( node == null ) {
            return null;
        }

        c = TXml._skipSpaces(str, pos);

        //closing node ?
        if( c == '/' ){
            c = pos._advance(str);
            if( c != '>' ){
                throw new TXmlException(pos, '">" expected, but "$c" found');
            }

        //closing tag
        }else if( c == '>' ){

            //find child nodes
            var child : TXmlNode = TXml._parse(str, pos);
            while( child != null ){
                node._children.push(child);
                child = TXml._parse(str, pos);
            }

            //look for node closing {
                c = TXml._skipSpaces(str, pos);
                if( c != '<' ){
                    throw new TXmlException(pos, '"</${node.name}>" expected but nod found');
                }
                var name : String = TXml._findName(str, pos);
                if( name != node.name ){
                    throw new TXmlException(pos, '"</${node.name}>" expected but nod found');
                }
                c = TXml._skipSpaces(str, pos)                ;
                if( c != '>' ){
                    throw new TXmlException(pos, '"</${node.name}>" expected but nod found');
                }
            //}
        }

        return node;
    }//function _parse()


    /**
    * Advance pos infos to skip xml declaration
    *
    */
    static private function _skipDeclaration (str:String, pos:TXmlPos) : Void {
        var c    : String;
        var last : Int = str.length - 1;

        //find declaration start
        while(pos.index < last ){
            c = pos._advance(str);

            //find '<'
            if( c == '<' ){
                //if next character is '?' andvance to the end of declaration
                if( str.charAt(pos.index + 1) == '?' ){
                    break;

                //otherwise rollback and continue parsing
                }else{
                    pos._revert(c);
                    return;
                }
            }
        }

        //find declaration end
        while(pos.index < last ){
            c = pos._advance(str);

            if( c == '?' && str.charAt(pos.index + 1) == '>' ){
                return;
            }
        }

        //xml declaration end was not found
        throw new TXmlException(pos, 'Xml declaration end expected but not found');
    }//function _skipDeclaration()


    /**
    * Find node name in string
    *
    */
    static private function _findName (str:String, pos:TXmlPos) : String {
        var c     : String;
        var last  : Int = str.length - 1;
        var begin : Int = -1;

        //find first character of a name
        while( pos.index < last ){
            c = pos._advance(str);

            if( c.isForName() ){
                begin = pos.index;
                break;
            }
        }

        //find the rest of a name
        if( begin >= 0 ){
            while( pos.index < last ){
                c = pos._advance(str);
                //found!
                if( c.isNotForName() ){
                    pos._revert(c);
                    return str.substring(begin, pos.index + 1);
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
    static private function _skipSpaces (str:String, pos:TXmlPos) : String {
        var c     : String;
        var last  : Int = str.length - 1;

        while( pos.index < last ){
            c = pos._advance(str);

            if( !c.isSpace() ){
                return c;
            }
        }

        throw new TXmlException(pos, 'Unexpected end of document');
        return null;
    }//function _skipSpaces()



    /**
    * Constructor
    *
    */
    private function new () : Void {
        //code...
    }//function new()


}//class TXml