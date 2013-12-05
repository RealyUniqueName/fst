package fst.magic;


import fst.tools.AAccess;
import fst.tools.FSTools;
import haxe.ds.StringMap;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.ExprOf;
import fst.exception.Exception;
import haxe.macro.Context;
import haxe.macro.Expr;


using StringTools;

/**
* Macros for routes building
*
*/
class RouteBuilder {


    /**
    * Build fst.Router class
    *
    */
    macro static public function buildRouter () : Array<Field> {
        if( Context.defined('display') ) return null;

        var cfg : AAccess = Magic.config.config.routes;
        var positions : AAccess = Magic.config.positions.routes;

        var pos    = Context.currentPos();
        var cls    = Context.getLocalClass().get();
        var fields = Context.getBuildFields();

        for(field in fields){
            if( field.name != 'handleRequest' && field.name != 'getRoute' ) continue;

            switch(field.kind){
                case FFun(fn):
                    switch(fn.expr.expr){
                        case EBlock(exprs):
                            for(name in cfg.fields()){
                                var data : Dynamic = cfg[name];
                                if( RouteBuilder._skipRoute(data) ) continue;

                                var uri : String = FSTools.ensureSlash(data.uri);
                                var mparts = uri.split('/');
                                if( mparts[0] == '' ) mparts.shift();
                                if( mparts[mparts.length - 1] == '' ) mparts.pop();

                                var eChecks : Array<Expr> = [];
                                var args    : Array<String> = [];
                                var param   : AAccess = data.param;
                                var ppos    : AAccess = positions[name].param;
                                for(i in 0...mparts.length ){
                                    if( mparts[i].charAt(0) == ':' ){
                                        var arg = mparts[i].substr(1);
                                        args.push(arg);
                                        var value = param[arg];
                                        switch(Type.typeof(value)){
                                            case TNull     :
                                                eChecks.push(Magic.parse('var $arg = null', ppos[arg]));
                                            case TInt      :
                                                eChecks.push(Magic.parse('var $arg : Int = (!match || Std.parseInt(parts[$i]) == null ? $value : Std.parseInt(parts[$i]))', ppos[arg]));
                                            case TFloat    :
                                                eChecks.push(Magic.parse('var $arg : Float = (!match || Math.isNaN(Std.parseFloat(parts[$i])) ? $value : Std.parseFloat(parts[$i]))', ppos[arg]));
                                            case TClass(c) :
                                                eChecks.push(Magic.parse('var $arg : String = parts[$i]', ppos[arg]));
                                            case TBool     :
                                                eChecks.push(Magic.parse('var $arg : Bool = (match && parts[$i].toLowerCase() == "true")', ppos[arg]));
                                            case _ : throw new Exception('${ppos[arg].file}:${ppos[arg].line}: Unknown type of value');
                                        }
                                    }else{
                                        eChecks.push(macro if(match && parts[$v{i}] != $v{mparts[i]}) match = false);
                                    }
                                }

                                if(  field.name == 'handleRequest' ){
                                    var newCtrl = Magic.parse('var c = new ${data.controller}()', positions[name].controller);
                                    var act     = Magic.parse('c.${data.action}', positions[name].action);
                                    eChecks.push(macro if( match ) {
                                        ${newCtrl}
                                        c._request = request;
                                        c.bootstrap();
                                        if( !c._skip ) ${act}
                                        c.shutdown();
                                        return;
                                    });
                                }else if( field.name == 'getRoute' ){
                                    eChecks.push(Context.parse('if( match ){
                                        var route = new fst.route.'+ RouteBuilder.route2ClassName(name) +'();' +
                                        [for(arg in args) 'route.$arg = $arg;'].join('\n')
                                        + '
                                        return route;
                                    }', pos));
                                }

                                var checks = {expr:EBlock(eChecks), pos:pos};

                                exprs.push(macro
                                    if( parts.length == $v{mparts.length} ){
                                        match = true;
                                        $checks;
                                    }
                                );
                            }
                            //if no route matched this request
                            if( field.name == 'getRoute' ){
                                exprs.push(macro return null);
                            }
                            fn.expr.expr = EBlock(exprs);
                            field.kind = FFun(fn);
                        case _:
                    }
                case _:
            }//switch(field.kind)
        }

        return fields;
    }//function buildRouter()


    /**
    * Build routes from config/routes.cfg
    *
    */
    static public function buildRoutes () : Void {
        var routes    : AAccess = Magic.config.config.routes;
        var positions : AAccess = Magic.config.positions.routes;

        var pos : Position = Context.currentPos();

        var route    : Dynamic;
        var cls      : String;
        var uri      : String;
        var fields   : Array<Field>;

        for(name in routes.fields()){
            route = routes[name];
            _checkRouteConfig(name, route);

            cls    = RouteBuilder.route2ClassName(name);
            uri    = FSTools.ensureSlash(route.uri);

            //variables
            fields = Magic.generateFields(route.param, positions[name].param, true);

            //static var uri
            fields.push({
                pos    : pos,
                name   : 'uri',
                meta   : [],
                kind   : FVar(
                    TPath({name : 'String', pack : [], params : [] }),
                    {pos:pos, expr:EConst(CString(uri))}
                ),
                doc    : 'route uri from routes.cfg',
                access : [AStatic, APublic]
            });

            //makeUri(), buildUri() and other methods
            for(method in _generateMethods(uri, route, positions[name])){
                fields.push(method);
            }

            var type : TypeDefinition = {
                pos      : pos,
                params   : [],
                pack     : ['fst', 'route'],
                name     : cls,
                meta     : [],
                kind     : TDClass({name : 'Route', pack : ['fst', 'route'], params : [] }, [], false),
                isExtern : false,
                fields   : fields
            };

            Context.defineType(type);
        }//for(name in routes)
    }//function buildRoutes()


    /**
    * Throw exceptions if route config is invalid
    *
    */
    static private inline function _checkRouteConfig (name:String, route:AAccess) : Void {
        if( !route.has('uri') ) throw new Exception('Error in routes config: a "uri" parameter is missing in "$name" section');
        if( !route.has('controller') ) throw new Exception('Error in routes config: a "controller" parameter is missing in "$name" section');
        if( !route.has('action') ) throw new Exception('Error in routes config: a "action" parameter is missing in "$name" section');
    }//function _checkRouteConfig()


    /**
    * Generate makeUri() and buildUri() methods for route classes
    *
    */
    static private function _generateMethods (uri:String, route:Dynamic, positions:Dynamic) : Array<Field> {
        var pos : Position = Context.currentPos();

        //method content{
            var makeUri : Array<Expr> = [macro var uri : String = ''];
            makeUri.push(
                macro if( params == null ) {
                    params = $v{route.param};
                }
            );
            var parts   : Array<String> = uri.split('/');
            //remove empty part after last '/'
            if( parts[parts.length - 1].length == 0 ) parts.pop();

            for(i in 0...parts.length){
                //insert argument
                if( parts[i].length > 0 && parts[i].charAt(0) == ':' ){
                    var arg : String = parts[i].substr(1);
                    makeUri.push(macro uri += params.$arg + '/');
                //insert constant string
                }else{
                    makeUri.push(macro uri += '${parts[i]}/');
                }
            }

            makeUri.push(macro return uri);
        //}

        //arguments for makeUri
        var args : Array<Field> = Magic.generateFields(route.param, positions.param, false);

        return [
        //makeUri()
        {
            pos    : pos,
            name   : 'makeUri',
            meta   : [],
            kind   : FFun({
                ret    : TPath({name : 'String', pack : [], params : [] }),
                params : [],
                args   : [{
                    name  : 'params',
                    opt   : true,
                    value : null,
                    type  : TAnonymous(args)
                }],
                expr : {expr : EBlock(makeUri), pos : pos}
            }),
            doc    : 'Make uri string for this route',
            access : [AStatic, APublic]
        },
        //buildUri()
        {
            pos    : pos,
            name   : 'buildUri',
            meta   : [],
            kind   : FFun({
                ret    : TPath({name : 'String', pack : [], params : [] }),
                params : [],
                args   : [],
                expr : {expr : EBlock([macro return makeUri(this)]), pos : pos}
            }),
            doc    : 'Creates URI according to values of fields of this route and rules from routes.cfg',
            access : [AOverride, APublic]
        }
        ];
    }//function _generateMethods()


    /**
    * Create class name based on route name from routes.cfg
    *
    */
    static public inline function route2ClassName (name:String) : String {
        return name.substr(0, 1).toUpperCase() + name.substr(1);// + 'Route';
    }//function route2ClassName()


    /**
    * Check if we need to skip this route during code generation of fst.Router
    *
    */
    static private function _skipRoute (data:Dynamic) : Bool {
        if( Magic.sysTarget ) return false;

        try{
            Context.getModule(data.controller);

            var controller = Context.getType(data.controller);
            var action     = StringTools.trim(data.action);
            action = action.substring(0, action.indexOf('('));

            return !Magic.hasField(controller, action);
        }catch(e:Dynamic){
            return true;
        }
    }//function _skipRoute()

}//class RouteBuilder