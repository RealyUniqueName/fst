package fst.db;


/**
* Base object for DB tables
*
*/
// @:autoBuild(fst.db.BuildObject.build())
@:skip class Object #if sys extends sys.db.Object #end {


    // /**
    // * Update or create object
    // *
    // */
    // public function save () : Void {
    //     #if sys
    //         // trace(this._manager.dbInfos().key);
    //     #end
    // }//function save()

#if !sys

    /**
    * Constructor for non-system targets
    *
    */
    public function new () : Void {
    }//function new()

#end

}//class Object