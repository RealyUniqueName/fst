package fst.session;

import fst.session.SpodSessionStorage;
import haxe.ds.StringMap;
import fst.uid.Guid;
import fst.exception.SessionException;


/**
* DB-based sessions
*
*/
class SpodSession implements ISession{
    /** req (get,never) */
    static public var req : Int = 0;

    function getreq(){
        return req++;
    }

    /** session name */
    public var name (default,null) : String = 's';
    /** session id */
    public var id (default,default) : String = null;
    /** lifetime in seconds */
    public var lifetime (default,null) : Int = 0;
    /** session domain */
    public var domain (default, null) : String = null;

    /** automatically start session if required */
    private var _autostart : Bool = false;
    /** _newSession */
    private var _newSession : Bool = true;

    /** data storage */
    private var _storage : SpodSessionStorage;


    /**
    * Create session instance
    *
    */
    public function new (autostart:Bool = false) : Void {
        this._autostart = autostart;
    }//function new()


    /**
    * Set session cookie parameters
    *
    * @param name     - cookie name
    * @param lifetime - amount of seconds till cookie expiration time. 0 means "until the browser is closed"
    */
    public function configure (name:String = 's', lifetime:Int = 0, domain:String = null) : Void {
        this.name     = name;
        this.lifetime = lifetime;
        this.domain   = domain;
    }//function configure()


    /**
    * Start session
    *
    */
    public function start () : Void {
        //already started
        if( this.isActive() ) return;

        if( this.id == null ){
            this.id = Web.getCookies().get(this.name);
        }

        //new session
        if( this.id == null ){
            this._storage = new SpodSessionStorage();
            this._storage.sid = this.id = Guid.string(false);
        //retrieve stored data
        }else{
            this._storage = SpodSessionStorage.manager.get(this.id);
            if( this._storage == null ){
                this._storage = new SpodSessionStorage();
                this._storage.sid = this.id;
            }else{
                this._newSession = false;
            }
        }

        //set session cookie
        Web.setCookie(this.name, this.id, DateTools.delta(Date.now(), this.lifetime * 1000.0), this.domain, '/');
    }//function start()


    /**
    * Get session variable value
    * Automatically starts session if required
    */
    public function get (variable:String, defaultValue:Dynamic = null) : Dynamic {
        if( !this.isActive() ){
            if( this._autostart ) {
                this.start();
            }else{
                throw new SessionException('Session is not active', 1);
            }
        }

        var value : Dynamic = this._storage.data.get(variable);
        return (value == null ? defaultValue : value);
    }//function get()


    /**
    * Set session variable value
    * Automatically starts session if required
    */
    public function set (variable:String, value:Dynamic) : Void {
        if( !this.isActive() ){
            if( this._autostart ) {
                this.start();
            }else{
                throw new SessionException('Session is not active', 1);
            }
        }

        this._storage.data.set(variable, value);
    }//function set()


    /**
    * Save session data to file
    *
    */
    public function flush () : Void {
        if( !this.isActive() ) return;

        if( this._storage.isChanged() ){
            this._storage.mtime = Date.now().getTime();

            if( this._newSession ){
                this._storage.insert();
            }else{
                this._storage.update();
            }
        }
    }//function flush()


    /**
    * Close session. Does not save session data
    *
    */
    public function close () : Void {
        this._storage = null;
    }//function close()


    /**
    * Destroy session data
    *
    */
    public function destroy () : Void {
        if( this._storage != null ){
            this._storage.delete();
            this.close();
        }
    }//function destroy()


    /**
    * Garbage collector for expired sessions
    *
    */
    public function gc () : Void {
        //start garbage collection in 1% of requests
        if( Std.random(100) == 0 ){
            var deleteTime : Float = Date.now().getTime() - this.lifetime * 1000;
            SpodSessionStorage.manager.delete($mtime < deleteTime);
        }
    }//function gc()


    /**
    * If session is started and active
    *
    */
    public inline function isActive () : Bool {
        return this._storage != null;
    }//function isActive

}//class SpodSession