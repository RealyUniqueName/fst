package fst.controller;

import fst.Router;


/**
* Base controller
*
*/
@:autoBuild(fst.magic.ControllerBuilder.build())
class Controller {

    /** router instance */
    public var router (get,never) : Router;
    @:noCompletion private var _router : Router;
    /** request uri */
    @:noCompletion public var _request : String = '';
    /** if action for current request should be stopped */
    @:noCompletion public var _skip : Bool = false;


    /**
    * Constructor
    *
    */
    public function new () : Void {

    }//function new()


    /**
    * Called before calling actions
    *
    */
    @:noCompletion public function bootstrap () : Void {
        //code...
    }//function bootstrap()


    /**
    * Called after action was run
    *
    */
    @:noCompletion public function shutdown () : Void {
        //code...
    }//function shutdown()

#if sys
    /**
    * Send output to STDOUT
    *
    */
    @:noCompletion private function _output (view:fst.view.View) : Void {
        if( view != null ){
            Sys.print(view.getOutput());
        }
    }//function _output()
#end

    /**
    * Getter `router`.
    *
    */
    @:noCompletion private inline function get_router () : Router {
        return (this._router == null ? this._router = Router.create(this._request) : this._router);
    }//function get_router


    /**
    * Skip action for current request
    *
    */
    public function skip () : Void {
        this._skip = true;
    }//function skip()

}//class Controller