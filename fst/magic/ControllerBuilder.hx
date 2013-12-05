package fst.magic;

import fst.magic.RouteBuilder;
import fst.magic.ViewBuilder;
import haxe.ds.StringMap;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import fst.tools.AAccess;


/**
* Macros for building controllers
*
*/
class ControllerBuilder {


    /**
    * Building controllers
    *
    */
    macro static public function build () : Array<Field> {
        if( !fst.Magic.sysTarget ) return null;

        var cls    : String = Context.getLocalClass().toString();
        var pos    : Position = Context.currentPos();
        var fields : Array<Field> = Context.getBuildFields();
        var cfg : AAccess = Magic.config.config.routes;

        var route     : Dynamic;
        var viewClass : String;
        var pack      : Array<String>;
        for(name in cfg.fields()){
            route = cfg[name];

            //this route uses this controller
            if( route.controller == cls ){
                //name of action method
                var action : String = StringTools.trim(route.action);
                action = action.substring(0, action.indexOf('('));

                //patch action method with code of view
                for(field in fields){
                    if( field.name == action ){
                        switch(field.kind){
                            case FFun({ret:r,params:p,expr:expr,args:args}):
                                //add view as optional argument
                                viewClass = ViewBuilder.createView(route.view);

                                //check if still not added{
                                    if( field.name == 'new') continue;
                                    if( args.length > 0 && args[args.length - 1].type != null
                                        && ComplexTypeTools.toString(args[args.length - 1].type) == viewClass
                                    ) continue;
                                //}

                                pack = viewClass.split('.');
                                viewClass = pack.pop();
                                args.push({
                                    value : null,
                                    type  : TPath({
                                        name   : viewClass,
                                        pack   : pack,
                                        params : []
                                    }),
                                    opt   : true,
                                    name  : 'view'
                                });

                                //output content before every 'return' expression
                                expr = ExprTools.map(expr, _insertOutputBeforeReturn);

                                switch(expr.expr){
                                    case EBlock(exprs):
                                        if( pack.length > 0 ) viewClass = pack.join('.') + '.' + viewClass;
                                        //create view instance
                                        exprs.unshift(Context.parse('if( view == null ) view = new '+ viewClass +'()', pos));
                                        //insert output as last expression of function's body
                                        exprs.push(Context.parse('this._output(view)', pos));
                                        // if( field.name == 'test' ) for(i in 0...exprs.length) trace('------------------------\n' + ExprTools.toString(exprs[i]));
                                    case _:
                                }

                                field.kind = FFun({ret:r,params:p,expr:expr,args:args});
                            case _:
                        }
                        break;
                    }
                }
            }
        }

        return fields;
    }//function build()


    /**
    * Insert view output before each 'return' expression
    *
    */
    static private function _insertOutputBeforeReturn (expr:Expr) : Expr {
        var expr : Expr = expr;

        switch(expr.expr){
            case EReturn(e):
                expr = {pos:expr.pos, expr:EBlock([Context.parse('this._output(view)', expr.pos), expr])};
            case EFunction(_,_):
            case _:
                expr = ExprTools.map(expr, _insertOutputBeforeReturn);

        }

        return expr;
    }//function _insertOutputBeforeReturn()


    /**
    * Base class for controller classes
    *
    */
    static public function baseType () : haxe.macro.Type {
        var ctrl : String = Magic.getDeep(
            Magic.config.config,
            (Magic.sysTarget ? 'app.classes.controller' : 'app.classes.js.controller')
        );

        return (
            ctrl == null
                ? Context.getType('fst.controller.Controller')
                : Context.getType(ctrl)
        );
    }//function baseType()

}//class ControllerBuilder