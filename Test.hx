package ;

import fst.code.CodeGenerator;
import fst.txml.TXmlNode;
import haxe.macro.Expr;


/**
* Description
*
*/
class Test {

    static public var gen : CodeGenerator;


    /**
    * Initialization macro
    *
    */
    macro static public function initMacro () : Void {
        gen = new CodeGenerator();
        gen.pattern.addChild = macro parent.addChild(child);
    }//function initMacro()


    /**
    * Description
    *
    */
    macro static public function build (str:String) : Expr {
        var xml : TXmlNode = fst.txml.TXml.parse(str);
        var e = gen.process(xml);

        return e;
    }//function build()


    /**
    * Description
    *
    */
    static public function main () : Void {
        // var str = '
        //     <Node>
        //         <Node width="12" height="12" />
        //     </Node>
        // ';

        var n = Test.build('
            <Node>
                <Node width="12" height="12" />
            </Node>
        ');
        trace(n);

    }//function main()


}//class Test



/**
* Description
*
*/
class Node {
    /** children */
    public var children : Array<Node>;

    /**
    * Description
    *
    */
    public function new () : Void {
        this.children = [];
    }//function new()


    /**
    * Description
    *
    */
    public function addChild (node:Node) : Void {
        this.children.push(node);
    }//function addChild()


    /**
    * Description
    *
    */
    public function removeChild (node:Node) : Void {
        this.children.remove(node);
    }//function removeChild()


}//class Node