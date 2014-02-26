package fst.string;


using StringTools;


/**
* Various farmatting tools
*
*/
class StrFormat {

    /**
    * Format a number with grouped thousands
    *
    * @param decimals           - amount of decimal characters
    * @param decPoint           - decimal separator
    * @param thousandsSeparator
    */
    static public function number (num:Float, decimals:Int = 0, decPoint:String = '.', thousandsSeparator:String = ',') : String {
        var int : String = Std.string( Std.int(num) );
        var str : String = int.charAt(int.length - 1);

        for(i in 1...int.length){
            if( i % 3 == 0 ){
                str = thousandsSeparator + str;
            }
            str = int.charAt(int.length - i - 1) + str;
        }

        if( decimals > 0 ){
            var dec : String = Std.string(Std.int( (num - Std.int(num)) * Math.pow(10, decimals) ));

            return str + decPoint + dec.rpad('0', decimals);
        }else{
            return str;
        }
    }//function number()

}//class StrFormat