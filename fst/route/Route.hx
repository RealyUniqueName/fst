package fst.route;

// import traits.ITrait;
// import traits.Trait;



/**
* Base class for routes
*
*/
class Route /* extends ITrait */{

    // /** route string */
    // static public var route : String = '';

    // /**
    // * Make url with specified parameters.
    // * Example: SomeRoute.makeUri({arg1 : 12, arg2 : 'hey')
    // * This is general implementation for manually created Route classes.
    // * Implementation for routes generated with config/routes.cfg is just a simple string concatenation
    // *
    // */
    // static public function makeUri (params:Dynamic<String>) : String {
    //     var uri : String = (route.charAt(route.length - 1) == '/' ? route : route + '/');

    //     for(param in Reflect.fields(params)){
    //         uri = StringTools.replace(uri, ':' + param + '/', Reflect.field(params, param) + '/');
    //     }

    //     return uri;
    // }//function makeUri()


    /**
    * Constructor
    *
    */
    public function new () : Void {
    }//function new()


    /**
    * Creates URI according to values of fields of this route and rules from config/routes.cfg
    * Built with macro
    */
    public function buildUri () : String {
        return '/';
    }//function getUri()


    /**
    * Create and handle request with this route
    *
    */
    public function invoke () : Void {
        Router.invoke(this);
    }//function invoke()


    /**
    * Check if provided uri will invoke the same route
    *
    */
    public function uriMatch (uri:String) : Bool {
        uri = StringTools.trim(uri);
        return this.buildUri() == (uri.charAt(uri.length - 1) == '/' ? uri : uri + '/');
    }//function uriMatch()

}//class Route