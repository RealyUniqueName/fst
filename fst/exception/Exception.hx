package fst.exception;

import haxe.CallStack;


/**
* Exceptions base
*
*/
class Exception {

    /** Exception message */
    public var message (default,null) : String;
    /** Call stack of this exception */
    public var stack (default,null) : Array<StackItem>;


    /**
    * Constructor
    *
    * @param message
    * @param shiftStack - wich callstack entry to use relative to position where exception is thrown
    *                     If shiftStack == 1, exception will point to the the call of a method within
    *                     which exception was thrown
    * @param stack - use this callstack instead of current callstack
    */
    public function new (message:String, shiftStack:Int = 0, stack:Array<StackItem> = null) : Void {
        this.message = message;
        if( stack == null ){
            this.stack = CallStack.callStack();
            this.stack.splice(-4, 4 - shiftStack);
        }else{
            this.stack = stack;
        }
    }//function new()


    /**
    * Convert exception to string
    *
    */
    public function toString () : String {
        return '<' + Type.getClassName(Type.getClass(this)) + '>: ' + this.message + CallStack.toString(this.stack);
    }//function toString()

}//class Exception