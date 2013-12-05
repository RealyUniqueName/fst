package fst.db;


/**
* Base object for DB tables
*
*/
@:autoBuild(fst.db.BuildObject.build())
class Entity {


    /** if this object is just created and is still not saved in DB */
    private var __fst_isNew : Bool = true;


    /**
    * Constructor
    *
    */
    public function new () : Void {

    }//function new()


    /**
    * If object is fetched from DB this method will be used to populate object properties
    *
    */
    public function fillData (data:Dynamic) : Void {
        this.__fst_isNew = false;
    }//function fillData()


    /**
    * Insert this object in DB
    *
    */
    public function insert () : Void {
        this.__fst_isNew = false;
    }//function insert()


    /**
    * Update this object in DB
    *
    */
    public function update () : Void {
        //code...
    }//function update()


    /**
    * Insert or update this object in DB
    *
    */
    public function save () : Void {
        if( this.__fst_isNew ){
            this.insert();
        }else{
            this.update();
        }
    }//function save()


    /**
    * Get all data of this object as dynamic object
    *
    */
    public function toStruct () : Dynamic {
        return {};
    }//function toStruct()

}//class Entity