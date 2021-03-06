package fst;

import fst.route.Route;


// using StringTools;


/**
* Routes resolving
*
*/
@:build(fst.magic.RouteBuilder.buildRouter())
class Router {
    /** currently processed request */
    public var request (default,null) : String = '';


    /**
    * Find corresponding route and execute action
    *
    */
    static public function handleRequest (request:String) : Void {
        var parts : Array<String> = StringTools.trim(request).split('/');
        if( parts[0] == '' ) parts.shift();
        if( parts[parts.length - 1] == '' ) parts.pop();
        var requestHandled : Bool = false;
        var match : Bool;

        //the rest of function body is generated by macro
    }//function handleRequest()


    /**
    * Create and execute request according to provided route
    *
    */
    static public function invoke (route:Route) : Void {
        Router.handleRequest(route.buildUri());
    }//function invoke()


    /**
    * Create router instance for provided request uri
    *
    */
    static public function create (request:String) : Router {
        var router = new Router();
        router.request = request;

        return router;
    }//function create()


    /**
    * Constructor
    *
    */
    private function new () : Void {

    }//function new()


    /**
    * Get route instance for current request
    * Built with macro
    *
    */
    public function getRoute () : Route {
        var parts : Array<String> = StringTools.trim(request).split('/');
        if( parts[0] == '' ) parts.shift();
        if( parts[parts.length - 1] == '' ) parts.pop();
        var match : Bool;

        //the rest of function body is generated by macro
    }//function getRoute()


}//class Router