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
        gen.addImport('test.XMLNode');
        gen.patterns.addChild = macro parent.addChild(child);
        // gen.patterns.create = macro Type.createInstance(Node, []);
        // gen.patterns.create = macro new Node();
    }//function initMacro()


    /**
    * Description
    *
    */
    macro static public function build (str:String) : Expr {
        var xml : TXmlNode = fst.txml.TXml.parse(str);
        var e = gen.process(xml);
trace(haxe.macro.ExprTools.toString(e));
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
            <XMLNode obj-val="10">
                <XMLNode width="12" height="12" />
            </XMLNode>
        ');
        trace(n);

    }//function main()


}//class Test

