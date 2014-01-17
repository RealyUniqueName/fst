package fst.datetime;


/**
* Arithmetics with dates and time
*
*/
class DateMath {
    /** amount of seconds in one day */
    static public inline var SECONDS_IN_DAY = 86400;
    /** amount of microseconds in one day */
    static public inline var MICROSECONDS_IN_DAY = 86400000;


    /**
    * Amount of days passed since date1 to date2
    * E.g.:
    *   if date1 = 2013-12-05, date2 = 2013-12-05 returns 0
    *   if date1 = 2013-12-05, date2 = 2013-12-07 returns 2
    *   if date1 = 2013-12-07, date2 = 2013-12-05 returns -2
    */
    static public inline function deltaDays (date1:Date, date2:Date) : Int {
        return Std.int(date2.getTime() / MICROSECONDS_IN_DAY) - Std.int(date1.getTime() / MICROSECONDS_IN_DAY);
    }//function deltaDays()


}//class DateMath