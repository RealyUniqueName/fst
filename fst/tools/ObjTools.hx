package fst.tools;


/**
* Various tools to deal with dynamic objects
*
*/
class ObjTools {


    /**
    * Apply properties to object.
    * e. g. propList = {
    *                       prop1: -2,
    *                       prop2: true,
    *                       prop3: {
    *                           nested1: 'val1',
    *                           nested2: null,
    *                       },
    *                   }
    * than after calling ObjTools.apply(someObj, propList) we will get following:
    *       someObj.prop1 == -2
    *       someObj.prop2 == true
    *       someObj.prop3.nested1 == 'val1'
    *       someObj.prop3.nested2 == null
    * Note: non-scalar object properties must not be null, otherwise you'll get an exception
    * "Can't set property of Null"
    *
    * @throw Dynamic if corresponding scalar properties of `obj` and `properties` have different types
    */
    static public function apply(obj:Dynamic, properties:Dynamic) : Void {
        for(property in Reflect.fields(properties)){

            //go deeper for nested properties
            if( Type.typeof(Reflect.field(properties, property)) == TObject ){
                ObjTools.apply(Reflect.field(obj, property), Reflect.field(properties, property));

            //set scalar property
            }else{
                Reflect.setProperty(obj, property, Reflect.field(properties, property));
            }

        }//for(properties)
    }//function apply()


}//class ObjTools