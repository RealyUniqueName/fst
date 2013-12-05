package fst;

import fst.config.Cfg;
import fst.magic.RouteBuilder;
import fst.magic.ViewBuilder;
import fst.tools.AAccess;
import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.macro.Expr;
import fst.exception.Exception;
import haxe.macro.Type.ClassType;
import sys.FileSystem;
import Type.ValueType;

using StringTools;

typedef TBaseClass = {
    name : String,
    pack : Array<String>
}

/**
* Macro methods
*
*/
class Magic {

    /** configs path */
    static public var configPath : String = null;
    /** app config */
    static public var config : Dynamic;
    /** for internal usage by Magic.parse() */
    static private var _parseCounter : Int = 0;
    /** if current target allows to use system packages (files, sockets etc.) */
    static public var sysTarget : Bool = false;


    /**
    * Configure Fst
    *
    */
    macro static public function configure (cfgPath:String) : Void {
        Magic.sysTarget  = Context.defined('sys');
        Magic.configPath = StringTools.trim(cfgPath);
        Magic.config     = Cfg.parseAll();

        try{
            RouteBuilder.buildRoutes();
            if( Magic.sysTarget ){
                ViewBuilder.buildViews();
            }
        }catch(e:Exception){
            Sys.println(e.message);
            haxe.macro.Context.error('Build failed', haxe.macro.Context.currentPos());
        }
    }//function configure()


    /**
    * Generate fields based on params from route config
    *
    */
    static public function generateFields (values:AAccess, positions:AAccess, classField:Bool) : Array<Field> {
        var fields : Array<Field> = [];
        if( values == null ) return fields;

        var pos : Position = Context.currentPos();

        var value : Dynamic;
        for(field in values.fields()){
            value = values[field];

            var expr : ExprDef = null;
            var type : ComplexType = null;
            switch( Type.typeof(value) ){
                case TNull     :
                    expr = EConst(CIdent('null'));
                case TInt      :
                    expr = EConst(CInt(Std.string(value)));
                    type = TPath({name : 'Int', pack : [], params : [] });
                case TFloat    :
                    expr = EConst(CFloat(Std.string(value)));
                    type = TPath({name : 'Float', pack : [], params : [] });
                case TClass(c) :
                    expr = EConst(CString(value));
                    type = TPath({name : 'String', pack : [], params : [] });
                case TBool     :
                    expr = EConst(CIdent(value ? 'true' : 'false'));
                    type = TPath({name : 'Bool', pack : [], params : [] });
                case _ : throw new Exception('${positions[field].file}:${positions[field].line}: Unknown type of value');
            };

            fields.push({
                pos    : pos,
                name   : field,
                meta   : [],
                kind   : FVar(type, (classField ? {pos:pos, expr:expr} : null)),
                doc    : null,
                access : (classField ? [APublic] : [])
            });
        }

        return fields;
    }//function generateFields()


    /**
    * Check if specified class or one of its parents has this field
    *
    */
    static public function hasField (cls:haxe.macro.Type, field:String) : Bool {
        switch(cls){
            case TInst(t,_):
                var type : ClassType = t.get();
                while( type != null ){
                    for(f in type.fields.get()){
                        if( f.name == field ) return true;
                    }

                    type = (type.superClass == null ? null : type.superClass.t.get());
                }
            case _:
                throw new Exception('Only TInst is supported in Magic.hasField()');
        }

        return false;
    }//function hasField()


    /**
    * Parse provided string of haxe code and make correct position for error reporting by compiler
    *
    */
    static public function parse (code:String, pos:{file:String,line:Int}) : Expr {
        for(i in 0...pos.line){
            code = '\n' + code;
        }

        return Context.parseInlineString(
            code,
            //Magic._parseCounter is required to make `file` unique across all parses
            //otherwise Context.makePosition() always reports the same line number every time
            Context.makePosition({min:0, max:code.length, file:(Magic._parseCounter++) + ' ' + pos.file})
        );
    }//function parse()


    /**
    * Null-safe getter for a value of nested field
    *
    * @param field - like 'some.deep.nested.field'
    */
    static public function getDeep (obj:Dynamic, field:String) : Null<Dynamic> {
        var parts : Array<String> = field.split('.');

        while( parts.length > 0 ){
            field = parts.shift();
            switch( Type.typeof(obj) ){
                case TObject:
                    obj = Reflect.field(obj, field);
                case _:
                    return null;
            }
        }

        return obj;
    }//function exists()


    /**
    * Convert string represantation of classpath to TypePath structure
    *
    */
    static public function str2TypePath (className:String) : TypePath {
        var cls : Array<String> = className.split('.');
        return {
            name   : cls.pop(),
            pack   : cls,
            params : []
        };
    }//function str2TypePath()

}//class Magic