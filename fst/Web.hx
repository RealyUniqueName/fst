package fst;

import haxe.ds.StringMap;

#if sys
typedef Web = #if neko neko.Web #elseif php php.Web #end
#else

/**
* JS target equivalent of the same class in PHP/NEKO
*
*/
class Web {


    /**
    * Get URI
    *
    */
    static public inline function getURI () : String {
        return js.Browser.location.pathname;
    }//function getURI()


    /**
    * Redirect to specified url
    *
    */
    static public inline function redirect (url:String) : Void {
        js.Browser.location.href = url;
    }//function redirect()


    /**
    * Get GET parameters.
    *
    */
    static public function getParams () : StringMap<String> {
        var get : StringMap<String> = new StringMap();

        var str = js.Browser.window.location.search.substr(1);
        var param : Array<String>;
        for(p in str.split('&')){
            param = p.split('=');
            get.set(param.shift(), param.shift());
        }

        return get;
    }//function getParams()

}//class Web


#end