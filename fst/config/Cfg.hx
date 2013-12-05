package fst.config;

import fst.exception.ConfigException;
import fst.tools.AAccess;
import fst.tools.FSTools;
import haxe.macro.Context;
import sys.io.File;
import haxe.macro.Expr;

using StringTools;


private typedef CfgPos = {file:String,line:Int}


/**
* Parsing config files
*
*/
class Cfg {


    /**
    * Parse all config files in directory
    *
    */
    macro static public function parseAll (path:String = null) : Expr {
        var dir : String = FSTools.ensureSlash(path == null ? Magic.configPath : path);
        var cfg : AAccess = {};
        var positions : AAccess = {};

        try{
            for(file in FSTools.listDir(dir, ~/\.cfg$/, ListDir.FilesOnly)){
                var name : String = file.substr(0, file.length - 4);
                var data = Cfg.parse(dir + file);
                cfg[name] = data.cfg;
                positions[name] = data.positions;
            }
        }catch(e:ConfigException){
            Sys.println(e.message);
            Context.error('Configuration parsing failed', Context.currentPos());
        }

        return macro {config:$v{cfg}, positions:$v{positions}};
    }//function parseAll()


    /**
    * Parse config file
    *
    */
    static public function parse (file:String) : {cfg:AAccess, positions:AAccess} {
        var cfg       : AAccess = {};
        var positions : AAccess = {};

        var content : Array<String> = File.getContent(file).split('\n');

        var section : String = '';
        var line    : Int = 2;
        var name    : String = null;
        var str     : String;
        for(l in 0...content.length){
            str = content[l].trim();
            //comment
            if( str.charAt(0) == '#' ) str = ' ';

            //section header
            if( str.charAt(0) == '[' ){
                //check syntax
                if( str.charAt(str.length - 1) != ']' ){
                    throw new ConfigException('$file:$line: "]" expected but not found');
                }
                //parse completed section
                if( section.trim().length > 0 ){
                    if( name == null ){
                        throw new ConfigException('$file:$line: Name for the first section was not found');
                    }
                    var scfg = Cfg._parseSection(section, {file:file, line:line});
                    cfg[name] = scfg.cfg;
                    positions[name] = scfg.positions;
                }
                //save name for next section
                name = str.substring(1, str.length-1);
                line = l + 2;
                section = '';

            //section content
            }else{
                section += str + '\n';
            }
        }
        //parse completed section
        if( section.trim().length > 0 ){
            if( name == null ){
                throw new ConfigException('Name for the first section was not found');
            }
            var scfg = Cfg._parseSection(section, {file:file, line:line});
            cfg[name] = scfg.cfg;
            positions[name] = scfg.positions;
        }

        return {cfg:cfg, positions:positions};
    }//function parse()


    /**
    * Parse section config
    *
    */
    static public function _parseSection (content:String, pos:CfgPos) : {cfg:AAccess, positions:AAccess} {
        var lines : Array<String> = content.split('\n');

        var positions : AAccess = {};
        var cfg   : AAccess = {};
        var str   : String;
        var name  : String;
        var value : Dynamic;
        var eqPos : Int;

        for(i in 0...lines.length){
            str = lines[i].trim();
            //empty line
            if( str.length == 0 ) continue;
            //commented out line
            if( str.charAt(0) == '#' ) continue;

            eqPos = str.indexOf('=');
            //wtf line
            if( eqPos < 0 ){
                throw new ConfigException('${pos.file}:${pos.line + i}: "=" expected but not found');
            }

            name  = str.substring(0, eqPos - 1).rtrim();
            value = Cfg._parseValue(str.substr(eqPos + 1).ltrim(), {file:pos.file, line:pos.line + i});

            Cfg._assign(cfg, name.split('.'), value);
            Cfg._assign(positions, name.split('.'), {file:pos.file, line:pos.line + i});
        }

        return {cfg:cfg, positions:positions};
    }//function _parseSection()


    /**
    * Parse value to correct type
    *
    */
    static private function _parseValue (value:String, pos:CfgPos) : Dynamic {
        //if value is string
        if( value.startsWith("'") && value.endsWith("'") ){
            return value.substr(1, value.length - 2).replace("''", "'");
        }

        //if value is integer
        var int = Std.parseInt(value);
        if( int != null ) return int;

        //if value is float
        var float = Std.parseFloat(value);
        if( !Math.isNaN( float ) ) return float;

        //if value is boolean
        var bool = value.toLowerCase();
        if( bool == 'false' || bool == 'true' ) return (bool == 'true');

        //value is null
        if( value.toLowerCase() == 'null' ) return null;

        //unknown type
        throw new ConfigException('${pos.file}:${pos.line}: Unknown type of value: $value');

        return null;
    }//function _parseValue()


    /**
    * Assign property to object.
    *
    */
    static private function _assign (obj:Dynamic, name:Array<String>, value:Dynamic) : Void {
        var field : String;
        while( name.length > 1 ){
            field = name.shift();
            if( Reflect.field(obj, field) == null ){
                Reflect.setField(obj, field, {});
            }
            obj = Reflect.field(obj, field);
        }
        Reflect.setField(obj, name[0], value);
    }//function _assign()

}//class Cfg

