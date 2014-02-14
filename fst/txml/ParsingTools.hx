package fst.txml;


using fst.txml.MacroTools;
using fst.txml.ParsingTools;

/**
* Various tools for parsing
*
*/
@:allow(txml)
class ParsingTools {

    /**
    * Check if provided character is one of space characters
    *
    */
    static public function isSpace (char:String) : Bool {
        return char.isIn(' \n\t\r');
    }//function isSpace()


    /**
    * Check if current character represents a new line
    *
    */
    static public inline function isNL (char:String) : Bool {
        return char == '\n';
    }//function isNL()


    /**
    * Check if this char can not be contained in name of xml element
    *
    */
    static public function isNotForName (char:String) : Bool {
        return char.isSpace() || char.isIn('<>!?"\'=/');
    }//function isNotForName()


    /**
    * Check if this char is suitable for name of xml element
    *
    */
    static public inline function isForName (char:String) : Bool {
        return !char.isNotForName();
    }//function isForName()


}//class ParsingTools