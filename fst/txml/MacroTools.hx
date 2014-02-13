package fst.txml;

import haxe.macro.Expr;


/**
* Various macro tools
*
*/
class MacroTools {

    /**
    * Check if this char is contained in string.
    *
    */
    macro static public function isIn (char:ExprOf<String>, string:String) : ExprOf<Bool> {
        if( string.length == 0 ) return macro false;

        var s    : String = string.charAt(string.length - 1);
        var expr : Expr = macro $char == $v{s};

        for(i in (-string.length + 2)...1){
            s = string.charAt(-i);
            expr = macro ($char == $v{s} ? true : $expr);
        }

        return expr;
    }//function isIn()

}//class MacroTools