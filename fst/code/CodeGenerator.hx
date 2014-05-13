package fst.code;

import fst.txml.TXmlNode;
import haxe.macro.Expr;




/**
* Description
*
*/
class CodeGenerator {
    /** pattern */
    public var pattern : PatternList;

    /**
    * Constructor
    *
    */
    public function new () : Void {
        this.pattern = new PatternList();
    }//function new()


    /**
    * Description
    *
    */
    public function process (xml:TXmlNode) : Expr {
        var node : TXmlNode = xml;
        var code : Array<Expr> = [];

        while (node != null) {


            this.process(node.firstChild);
            node = xml.nextSibling;
        }

        code.push(macro 0);

        return macro $b{code};
    }//function process()

}//class CodeGenerator