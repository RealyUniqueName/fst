package fst.txml;

using StringTools;
using fst.txml.ParsingTools;


/**
* Various tools for parsing
*
*/
@:allow(fst.txml)
class ParsingTools {

    /**
    * Check if provided character is one of space characters
    *
    */
    static public function isSpace (char:Int) : Bool {
        return MacroTools.isIn(char, ' \n\t\r');
    }//function isSpace()


    /**
    * Check if current character represents a new line
    *
    */
    static public inline function isNL (char:Int) : Bool {
        return char == MacroTools.code('\n');
    }//function isNL()


    /**
    * Check if this char can not be contained in name of xml element
    *
    */
    static public function isNotForName (char:Int) : Bool {
        return char.isSpace() || MacroTools.isIn(char, '<>!?"\'=/');
    }//function isNotForName()


    /**
    * Check if this char is suitable for name of xml element
    *
    */
    static public inline function isForName (char:Int) : Bool {
        return !char.isNotForName();
    }//function isForName()


    /**
    * Shorten string
    *
    */
    static public inline function shorten (str:String, length:Int = 10) : String {
        var nl : Int = str.indexOf('\n');
        return (nl > 0 && nl < length ? str.substring(0, nl) : str.substr(0, length));
    }//function shorten()

}//class ParsingTools