package fst.session;

import haxe.ds.StringMap;
import haxe.Serializer;
import haxe.Unserializer;
import sys.db.Types;


/**
* Data storage for DB-based sessions
*
*/
@:id(sid)
class SpodSessionStorage extends sys.db.Object{

     /** unique session id */
    public var sid : SString<32>;
    /** session data */
    @:skip public var data (get,set) : StringMap<Dynamic>;
    @:skip private var _data : StringMap<Dynamic>;
    /** serialized data */
    private var _datastring : SText = '';
    /** timestamp of last modification */
    public var mtime : SFloat;



    /**
    * Getter `data`.
    *
    */
    private function get_data () : StringMap<Dynamic> {
        if( this._data == null ){
            if( this._datastring == null || this._datastring.length == 0 ){
                this._data = new StringMap();
            }else{
                this._data = Unserializer.run(this._datastring);
            }
        }

        return this._data;
    }//function get_data


    /**
    * Setter `data`.
    *
    */
    private function set_data (data:StringMap<Dynamic>) : StringMap<Dynamic> {
        return this._data = data;
    }//function set_data


    /**
    * Create new record
    *
    */
    override public function insert () : Void {
        if( this._data != null ){
            this._datastring = Serializer.run(this._data);
        }

        super.insert();
    }//function insert()


    /**
    * Update record
    *
    */
    override public function update () : Void {
        if( this._data != null ){
            this._datastring = Serializer.run(this._data);
        }

        super.update();
    }//function update()


    /**
    * Check if stored data was changed
    *
    */
    public function isChanged () : Bool {
        return (this._data != null && Serializer.run(this._data) != this._datastring);
    }//function isChanged()

}//class SpodSessionStorage