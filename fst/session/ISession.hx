package fst.session;



/**
* Session interface
*
*/
interface ISession {
    /** session name */
    public var name (default,null) : String = 's';
    /** session id */
    public var id (default,default) : String = null;
    /** lifetime in seconds */
    public var lifetime (default,null) : Int = 0;
    /** session domain */
    public var domain (default, null) : String = null;


    /**
    * Set session cookie parameters
    *
    * @param name     - cookie name
    * @param lifetime - amount of seconds till cookie expiration time. 0 means "until the browser is closed"
    */
    public function configure (name:String = 's', lifetime:Int = 0, domain:String = null) : Void ;


    /**
    * Start session
    *
    */
    public function start () : Void ;


    /**
    * Get session variable
    *
    */
    public function get (variable:String, defaultValue:Dynamic = null) : Dynamic ;


    /**
    * Set session variable
    *
    */
    public function set (variable:String, value:Dynamic) : Void ;


    /**
    * Save session data in storage
    *
    */
    public function flush () : Void ;


    /**
    * Close session. Does not save session data
    *
    */
    public function close () : Void ;


    /**
    * Destroy session data
    *
    */
    public function destroy () : Void ;


    /**
    * Garbage collector for expired sessions
    *
    */
    public function gc () : Void ;


    /**
    * If session is started and active
    *
    */
    public function isActive () : Bool ;

}//interface ISession