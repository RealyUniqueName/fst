package fst.uid;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end



/**
* Simple GUID implementation
*
*/
class Guid {

    /** allowed characters */
    static private var _chars : String = '0123456789ABCDEF';


    /**
    * Generate string GUID
    *
    * @param hyphens - whether to insert hyphens between char groups
    */
    static public function string (hyphens:Bool = true) : String {
        if( hyphens ){
            return _rand(8) + '-' + _rand(4) + '-' + _rand(4) + '-' + _rand(4) + '-' + _rand(12);
        }else{
            return _rand(32);
        }
    }//function string()


    /**
    * Generate expression of required amount of random characters
    *
    */
    macro static private function _rand (count:Int) : Expr {
        return Context.parse(
            [for(i in 0...count) '_chars.charAt(Std.random(16))'].join(' + '),
            Context.currentPos()
        );
    }//function _rand()


}//class Guid