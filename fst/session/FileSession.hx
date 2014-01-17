package fst.session;

import fst.exception.SessionException;
import fst.session.ISession;
import fst.tools.FSTools;
import fst.uid.Guid;
import fst.Web;
import haxe.ds.StringMap;
import haxe.Unserializer;
import sys.FileSystem;
import sys.io.File;



/**
* File-based sessions
*
*/
class FileSession implements ISession {

    /** session name */
    public var name (default,null) : String = 's';
    /** session id */
    public var id (default,null) : String = null;
    /** amount of seconds till cookie expiration tim */
    public var lifetime (default,null) : Int = 0;
    /** session domain */
    public var domain (default, null) : String = null;

    /** automatically start session if required */
    private var _autostart : Bool = false;
    /** directory for session files */
    private var _dir : String = null;
    /** session filename */
    private var _file : String = null;
    /** session data */
    private var _data : StringMap<Dynamic>;
    /** if session data was changed */
    private var _dataChanged : Bool = false;


    /**
    * Constructor
    *
    * @param sessionDirectory - where to save session files
    * @param autostart        - automatically start session on .get() and .set()
    */
    public function new (sessionDirectory:String = '/tmp', autostart:Bool = false) : Void {
        this._dir       = FSTools.ensureSlash(sessionDirectory);
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

        this.id = Web.getCookies().get(this.name);

        if( this.id == null ){
            this.id = Guid.string(false);
        }

        //read session file
        this._file = this._dir + 'fstsess_' + this.id;
        if( FileSystem.exists(this._file) ){
            var serialized : String = File.getContent(this._file);
            try{
                this._data = Unserializer.run(serialized);
            }catch(e:Dynamic){
            }
        }

        //if there is no existing data for session, create new one
        if( this._data == null ){
            this._data = new StringMap();
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

        var value : Dynamic = this._data.get(variable);
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

        this._dataChanged = true;

        this._data.set(variable, value);
    }//function set()


    /**
    * Save session data to file
    *
    */
    public function flush () : Void {
        if( !this.isActive() ) return;

        //save changed data to file
        if(  true || /* don't know how to change mtime */ this._dataChanged ){

            var serializer = new haxe.Serializer();
            serializer.useCache = true;
            serializer.serialize(this._data);
            File.saveContent(this._file, serializer.toString());

        //change mtime of session file
        }else{
        }
    }//function flush()


    /**
    * Close session. Does not save session data
    *
    */
    public function close () : Void {
        this._data = null;
        this._dataChanged = false;
    }//function close()


    /**
    * Destroy session data
    *
    */
    public function destroy () : Void {
        if( this._file != null && FileSystem.exists(this._file) ){
            this.close();
            FileSystem.deleteFile(this._file);
        }
    }//function destroy()


    /**
    * Garbage collector for expired sessions
    *
    */
    public function gc () : Void {
        //start garbage collection in 1% of requests
        if( Std.random(100) == 0 ){
            try{
                //delete outdated session files
                var now : Float = Sys.time();
                var lifetime : Float = (this.lifetime == 0 ? 24 * 3600 : this.lifetime) * 1000.0;
                //delete files older than lifetime
                for(file in FSTools.listDir(this._dir, ~/^fstsess_/, ListDir.FilesOnly)){
                    if( now - FileSystem.stat(this._dir + file).mtime.getTime() > lifetime ){
                        FileSystem.deleteFile(this._dir + file);
                    }
                }
            }catch(e:Dynamic){
            }
        }
    }//function gc()


    /**
    * If session is started and active
    *
    */
    public inline function isActive () : Bool {
        return this._data != null;
    }//function isActive

}//class FileSession