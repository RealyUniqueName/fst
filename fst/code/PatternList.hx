package fst.code;

import haxe.macro.Expr;


/**
* Code patterns to use in code generation
*
*/
class PatternList {

    /** add child node to parent */
    public var addChild : Expr;
    /** create new node instance */
    public var create : Expr;


    /**
    * Constructor
    *
    */
    public function new () : Void {
        this.addChild = macro parent.addChild(child);
        // this.create   = macro new Cls();
    }//function new()

}//class PatternList