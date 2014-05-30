package test;

/**
* Description
*
*/
class XMLNode {
    /** children */
    public var children : Array<XMLNode>;

    /** width */
    public var width : Float = 0;
    /** height */
    public var height : Float = 0;
    /** obj */
    public var obj : {val:Int};


    /**
    * Description
    *
    */
    public function new () : Void {
        this.children = [];
        this.obj = {val:0};
    }//function new()


    /**
    * Description
    *
    */
    public function addChild (node:XMLNode) : Void {
        this.children.push(node);
    }//function addChild()


    /**
    * Description
    *
    */
    public function removeChild (node:XMLNode) : Void {
        this.children.remove(node);
    }//function removeChild()


}//class XMLNode