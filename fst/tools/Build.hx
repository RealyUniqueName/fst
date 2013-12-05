package fst.tools;

import haxe.macro.Context;
import haxe.macro.Expr;


/**
* Methods related to building app
*
*/
class Build {


    /**
    * Build date and time
    *
    * @param format - compatible with DateTools.format()
    */
    macro static public function date (format:String = '%Y-%m-%d %H:%M:%S') : ExprOf<String> {
        var str : String = DateTools.format(Date.now(), format);
        return macro $v{str};
    }//function date()


    /**
    * Id of current build. Based on build date and time.
    * Can be used for static files versioning (like css or js)
    *
    */
    macro static public function uid () : ExprOf<String> {
        var str : String = DateTools.format(Date.now(), '%Y%m%d%H%M%S');
        return macro $v{str};
    }//function uid()


    /**
    * Path to file where this method is called
    *
    */
    macro static public function dir () : Expr {
        var erFile : EReg = ~/([^\\\/]+)$/;
        var file   : String = Context.getPosInfos(Context.currentPos()).file;
        var dir    : String = erFile.replace(file, '');

        return macro $v{dir};
    }//function dir()


    /**
    * Define conditional compilation flag
    *
    */
    macro static public function define (cond:String) : Expr {
        haxe.macro.Compiler.define(cond);
        return macro {};
    }//function define()

}//class Build