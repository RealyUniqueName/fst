package fst;


/**
* Fst main class
*
*/
class Fst {


    /**
    * If you don't need your own entry point, use this
    *
    */
    static public function main () : Void {
        #if neko Web.cacheModule(Fst.run); #end
        Fst.run();
    }//function main()


    /**
    * Run web request processing
    *
    */
    static public function run () : Void {
        var request = Web.getURI();
        Router.handleRequest(request);
    }//function run()


    /**
    * Output value with '<pre>' tag in web environment or with '\n' in cli environment
    *
    */
    static public function trace (value:Dynamic) : Void {
        var stack = haxe.CallStack.callStack();

        #if sys
        switch (stack[1]) {
            case haxe.CallStack.StackItem.FilePos(s,file,line):
                Sys.println(Fst.isCli() ? '$file:$line: $value' : '<pre>$file:$line: $value</pre>');
            case _:
                Sys.println(Fst.isCli() ? '$value' : '<pre>$value</pre>');
        }
        #else
            trace(value);
        #end
    }//function trace()


    /**
    * Check if module ran from command line
    *
    */
    static public inline function isCli () : Bool {
        #if neko
            return !(Web.isTora || Web.isModNeko);
        #elseif php
            return php.Lib.isCli();
        #else
            return false;
        #end
    }//function isCli()

}//class Fst
