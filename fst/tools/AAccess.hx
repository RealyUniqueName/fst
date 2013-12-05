package fst.tools;



/**
* Array access to dynamic objects
*
*/
abstract AAccess({}) from {} {
    public inline function fields() : Array<String> {
        return Reflect.fields(this);
    }

    public inline function has(field:String) : Bool {
        return Reflect.hasField(this, field);
    }

    @:arrayAccess @:noCompletion public inline function arrayAccess(key:String):Dynamic {
        return Reflect.field(this, key);
    }

    @:arrayAccess @:noCompletion public inline function arrayWrite<T>(key:String, value:T):T {
        Reflect.setField(this, key, value);
        return value;
    }
}