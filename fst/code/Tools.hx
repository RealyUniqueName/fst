package fst.code;

import haxe.macro.Expr;

using haxe.macro.Tools;
using fst.code.Tools;


/**
* Various tools for expression generation
*
*/
class Tools {


    /**
    * Generate TypePath based on string
    *
    */
    static public function typePath (str:String) : Null<TypePath> {
        var pack : Array<String> = str.split('.');
        return {
            name   : pack.pop(),
            pack   : pack,
            params : []
        };
    }//function typePath()


    /**
    * Check if TypePaths are equal
    *
    */
    static public function equal<T:(TypePath)> (t1:T, t2:T) : Bool {
        return (t1.name == t2.name && t1.pack.join('.') == t2.pack.join('.'));
    }//function equalTypePath()


    /**
    * Replace all occurencies of `str` identifier in `expr` by `by`
    *
    */
    static public function replace (expr:Expr, str:String, by:String) : Expr {
        return switch (expr.expr) {

            case ENew(t,p) :
                var typePath : TypePath = str.typePath();
                var e;
                if (t.equal(typePath)) {
                    var tp = by.typePath();
                    tp.params = t.params;
                    e = ENew(tp, [for(i in 0...p.length) p[i].replace(str, by)]);
                } else {
                    e = ENew(t, [for(i in 0...p.length) p[i].replace(str, by)]);
                }
                {expr:e, pos:expr.pos};

            case EConst(CIdent(s)):
                if (s == str) {
                    var field = by.split('.');
                    expr.expr = (macro $p{field}).expr;
                    expr;
                } else {
                    expr;
                }

            case EField(e,field):
                if (expr.toString() == str) {
                    var e = str.split('.').toFieldExpr();
                    e.pos = expr.pos;
                    expr;
                } else {
                    expr.map(Tools.replace.bind(_, str,by));
                }

            // TODO
            // case EFunction(name,f):
            // case ECast(e,t):
            // case EDisplayNew(t):
            // ECheckType(e,t):
            // EMeta(m,e):

            case _:
                expr.map(Tools.replace.bind(_, str,by));
        }
    }//function _replace()

}//class Tools