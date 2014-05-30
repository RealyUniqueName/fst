package fst.code;

#if macro
import fst.code.PatternList;
import fst.txml.TXmlAttribute;
import fst.txml.TXmlNode;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

#end



/**
* Description
*
*/
class CodeGenerator {
#if macro
    /** patterns */
    public var patterns : PatternList;
    /** imports */
    public var imports : Map<String,String>;


    /**
    * Constructor
    *
    */
    public function new (patterns:PatternList = null) : Void {
        this.patterns = (patterns == null ? new PatternList() : patterns);
        this.imports  = new Map();
    }//function new()


    /**
    * Description
    *
    */
    public function process (xml:TXmlNode) : Expr {
        var node : TXmlNode = xml;
        var code : Array<Expr> = [];

        var cls : String;
        while (node != null) {
            //create instance {
                cls = this.imports.get(node.name);
                if (cls == null) cls = node.name;
                var constr = this.patterns.buildCreation(cls);

                code.push(macro var parent = $constr);
            //}

            //attributes
            for (attr in node.getAttributes()) {
                code.push( this._setPropertyExpr(attr) );
            }

            // add children
            if (node.numChildren > 0) {
                var childExpr = this.process(node.firstChild);
                code.push(macro var child = $childExpr);
                code.push(this.patterns.addChild);
            }

            node = xml.nextSibling;
        }

        if (code.length > 0) {
            code.push(macro parent);
        }

        return macro $b{code};
    }//function process()


    /**
    * Add class to use in code generation
    *
    */
    public function addImport (cls:String) : Void {
        this.imports.set(cls.split('.').pop(), cls);
    }//function addImport()


    /**
    * Create expression of assigning value to object field
    *
    */
    private function _setPropertyExpr (attr:TXmlAttribute) : Expr {
        var field = attr.name.split('-');
        field.unshift('parent');

        var value : Expr = Context.parseInlineString(attr.value, Context.currentPos());
        return macro $p{field} = $value;
    }//function _setPropertyExpr()

#end
}//class CodeGenerator