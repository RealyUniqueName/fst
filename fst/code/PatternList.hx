package fst.code;

import haxe.macro.Expr;

using haxe.macro.Tools;
using fst.code.Tools;

/**
* Code patterns to use in code generation
*
*/
class PatternList {

    /** class */
    public var classPlaceholder : String = 'Node';
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
        this.create   = macro new Node();
    }//function new()


    /**
    * Build expressions which will create class instance
    *
    */
    public function buildCreation (cls:String) : Expr {
        return this.create.replace(this.classPlaceholder, cls);
    }//function buildCreation()




}//class PatternList