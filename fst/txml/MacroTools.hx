package fst.txml;

import haxe.macro.Expr;

using StringTools;

/**
* Various macro tools
*
*/
class MacroTools {

    /**
    * Check if this char is contained in string.
    *
    */
    macro static public function isIn (char:ExprOf<Int>, string:String) : ExprOf<Bool> {
        if( string.length == 0 ) return macro false;

        var c    : Int = string.fastCodeAt(string.length - 1);
        var expr : Expr = macro $char == $v{c};

        for(i in (-string.length + 2)...1){
            c = string.fastCodeAt(-i);
            expr = macro ($char == $v{c} ? true : $expr);
        }

        return expr;
    }//function isIn()


    /**
    * Get char code
    *
    */
    macro static public function code (char:ExprOf<String>) : ExprOf<Int> {
        switch(char.expr){
            case EConst(CString(c)) :
                var code : Int = c.fastCodeAt(0);
                return macro $v{code};
            case _:
                return macro StringTools.fastCodeAt($char, 0);
        };
    }//function code()


    /**
    * Convert char code to character
    *
    */
    macro static public function char (code:ExprOf<Int>) : ExprOf<String> {
        switch(code.expr){
            case EConst(CInt(c)) :
                var char : String = String.fromCharCode( Std.parseInt(c) );
                return macro $v{char};
            case _:
                return macro String.fromCharCode($code);
        };
    }//function char()

}//class MacroTools