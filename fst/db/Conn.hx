package fst.db;

import fst.exception.db.DbException;
import haxe.CallStack;
import sys.db.Connection;
import sys.db.ResultSet;


/**
* Connection wrapper
*
*/
class Conn implements Connection{
    /** connection */
    private var _connection : Connection;


    /**
    * Constructor
    *
    */
    public function new (connection:Connection) : Void {
        this._connection = connection;
    }//function new()


    /**
    * Perform a request to DB
    *
    */
    public inline function request (query:String) : ResultSet {
        try{
            return this._connection.request(s);
        }catch(e:Dynamic){
            throw new DbException(e, 0, CallStack.exceptionStack());
            return null;
        }
    }//function request()


    /**
    * Close connection
    *
    */
    public inline function close () : Void {
        this._connection.close();
    }//function close()


    /**
    * Escape provided value
    *
    */
    public inline function escape (s:String) : String {
        return this._connection.escape(s);
    }//function escape()


    // function quote( s : String ) : String;
    // function addValue( s : StringBuf, v : Dynamic ) : Void;
    // function lastInsertId() : Int;
    // function dbName() : String;
    // function startTransaction() : Void;
    // function commit() : Void;
    // function rollback() : Void;

}//class Conn