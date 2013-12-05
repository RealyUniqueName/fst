package fst.controller;

import fst.session.ISession;
import fst.view.Layout;
import fst.view.View;



/**
* Controller with commonly required properties like layout and session
*
*/
class WebController extends haxe.macro.MacroType<[fst.magic.ControllerBuilder.baseType()]>{


    /** page layout */
    public var layout : Layout;
    /** web visitor's session */
    public var session : ISession;


    /**
    * Send html to browser
    *
    */
    @:noCompletion override private function _output (view:View) : Void {
        if( view != null && this.layout != null ){
            this.layout.content = view.getOutput();
        }

        super._output(this.layout == null ? view : this.layout);
    }//function _output()


    /**
    * Called after action was run
    *
    */
    override public function shutdown () : Void {
        super.shutdown();

        if( this.session != null && this.session.isActive() ){
            this.session.flush();
            this.session.gc();
        }
    }//function shutdown()

}//class WebController