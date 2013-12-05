package fst.http;

import fst.Web;



/**
* HTTP headers
*
*/
class Header {


    /**
    * Content-type
    *
    */
    static public inline function contentType (mime:String, charset:String = null) : Void {
        Web.setHeader('Content-Type', mime + (charset == null ? '' : ';charset=$charset'));
    }//function contentType()


    /**
    * Location (redirect)
    *
    */
    static public inline function location (uri:String) : Void {
        Web.redirect(uri);
    }//function location()

}//class Header


