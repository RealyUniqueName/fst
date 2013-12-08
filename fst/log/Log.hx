package fst.log;

import haxe.io.Output;


/**
* :TODO:
* Implement syslog
*/


/**
* Base logger
*
*/
class Log {
    /**
    * Message priorities accroding to RFC 3164 {
    */
        /** Emergency: system is unusable */
        static public inline var PRI_EMERG = 0;
        /** Alert: action must be taken immediately */
        static public inline var PRI_ALERT = 1;
        /** Critical: critical conditions */
        static public inline var PRI_CRIT = 2;
        /** Error: error conditions */
        static public inline var PRI_ERR = 3;
        /** Warning: warning conditions */
        static public inline var PRI_WARN = 4;
        /** Notice: normal but significant condition */
        static public inline var PRI_NOTICE = 5;
        /** Informational: informational messages */
        static public inline var PRI_INFO = 6;
        /** Debug: debug-level messages */
        static public inline var PRI_DEBUG = 7;
    /**
    * }
    */


    /** where to send log messages */
    private var _out : Output;


    /**
    * Constructor
    *
    * @param out - where to send messages. Defaults to Sys.stderr() for system targets and to trace() for other targets.
    */
    public function new (out:Output = null) : Void {
        if( out == null ){
            #if sys
                this._out = Sys.stderr();
            #else
                this._out = new TraceOutput();
            #end
        }else{
            this._out = out;
        }
    }//function new()


    /**
    * Log message
    *
    */
    public function log (priority:Int, message:String) : Void {
        this._out.writeString(DateTools.format(Date.now(), '%Y-%m-%d %H:%M:%S') +': $message\n');
    }//function log()


    /**
    * Log emergency level message
    *
    */
    public function emerg (message:String) : Void {
        this.log(PRI_EMERG, message);
    }//function emerge()


    /**
    * Log alert level message
    *
    */
    public function alert (message) : Void {
        this.log(PRI_ALERT, message);
    }//function alert()


    /**
    * Log critical level message
    *
    */
    public function crit (message:String) : Void {
        this.log(PRI_CRIT, message);
    }//function crit()


    /**
    * Log error level message
    *
    */
    public function err (message:String) : Void {
        this.log(PRI_ERR, message);
    }//function err()


    /**
    * Log warning level message
    *
    */
    public function warn (message:String) : Void {
        this.log(PRI_WARN, message);
    }//function warn()


    /**
    * Log notice level message
    *
    */
    public function notice (message:String) : Void {
        this.log(PRI_NOTICE, message);
    }//function notice()


    /**
    * Log notice level message
    *
    */
    public function info (message:String) : Void {
        this.log(PRI_INFO, message);
    }//function info()


    /**
    * Log debug level message
    *
    */
    public function debug (message:String) : Void {
        this.log(PRI_DEBUG, message);
    }//function debug()

}//class Log