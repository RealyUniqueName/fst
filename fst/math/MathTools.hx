package fst.math;

import haxe.macro.Expr;


/**
* Several simple tools
*
*/
class MathTools {

    /**
    * Make sure provided value does not overflow minimum and maximum allowed values
    *
    */
    macro static public function clamp (value:Expr, max:Expr, min:Expr) : Expr {
        return macro ($value < $min ? $min : ($value > $max ? $max : $value));
    }//function clamp()


    /**
    * Get absolute value for provided integer value
    *   Does not check against infinities unlike std lib Math.abs()
    */
    macro static public function abs (value:Expr) : Expr {
        return macro ($value >= 0 ? $value : -$value);
    }//function abs()


    /**
    * Returns the biggest of specified values
    *
    */
    macro static public function max (values:Array<Expr>) : Expr {
        if( values.length == 0 ){
            throw new fst.exception.Exception('At least one argument required');
        }

        var e : Expr = values.pop();
        for(q in values){
            e = macro ($q > $e ? $q : $e);
        }

        return e;
    }//function max()


    /**
    * Returns the smallest of specified values
    *
    */
    macro static public function min (values:Array<Expr>) : Expr {
        if( values.length == 0 ){
            throw new fst.exception.Exception('At least one argument required');
        }

        var e : Expr = values.pop();
        for(q in values){
            e = macro ($q < $e ? $q : $e);
        }

        return e;
    }//function min()

}//class MathTools