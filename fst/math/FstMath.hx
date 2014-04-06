package fst.math;

import haxe.macro.Expr;


/**
* Several simple tools.
*   If result type of function is not specified, then If all arguments of this functions are Int then result will be Int also.
*   So you don't need to use Std.int() to assign it to int variable.
*   If macro functions are used inside of other macro functions they become completely type-unsafe.
*/
class FstMath {

    /**
    * Make sure provided value does not overflow minimum and maximum allowed values
    * It's up to developer to ensure min < max.
    */
    macro static public function clamp (value:ExprOf<Float>, min:ExprOf<Float>, max:ExprOf<Float>) : Expr {
        return macro ($value < $min ? $min : ($value > $max ? $max : $value));
    }//function clamp()


    /**
    * Get absolute value
    *   Does not check against infinities unlike std lib Math.abs()
    *
    */
    macro static public function abs (value:ExprOf<Float>) : Expr {
        return macro ($value < 0 ? -$value : $value);
    }//function abs()


    /**
    * Returns the biggest of specified values. Accepts any amount of arguments
    *
    */
    macro static public function max (values:Array<ExprOf<Float>>) : Expr {
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
    * Returns the smallest of specified values. Accepts any amount of arguments
    *
    */
    macro static public function min (values:Array<ExprOf<Float>>) : Expr {
        if( values.length == 0 ){
            throw new fst.exception.Exception('At least one argument required');
        }

        var e : Expr = values.pop();
        for(q in values){
            e = macro ($q < $e ? $q : $e);
        }

        return e;
    }//function min()


    /**
    * Returns base raised to the power of exp.
    * Equal to manual writing something like this: value * value * value * ... * value
    */
    macro static public function intPow (value:ExprOf<Float>, pow:Int) : Expr {
        var e : Expr = value;
        for(i in 0...(pow - 1)){
            e = macro $e * $value;
        }

        return e;
    }//function pow()


    /**
    * Convert degrees to radians
    *
    */
    macro static public function degToRad (deg:ExprOf<Float>) : ExprOf<Float> {
        var k : Float = Math.PI / 180;

        return macro $deg * $v{k};
    }//function degToRad()


    /**
    * Convert radians to degrees
    *
    */
    macro static public function radToDeg (rad:ExprOf<Float>) : ExprOf<Float> {
        var k : Float = 180 / Math.PI;

        return macro $rad * $v{k};
    }//function radToDeg()

}//class FstMath