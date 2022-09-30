import DFParser.DfParser;
import sys.io.File;
import sys.FileSystem;
import sys.io.Process;
import Sys.*;

using StringTools;

// This class won't be neofetch dependent, it'll essentially use coreutilss
class HxFetch {

    public static var possible_drives:Array<String> = ["/dev/sda1", "/dev/sda2", "/dev/sda3"];

    public static function hello():Void {
        trace("Hello");
    }

    // used for getting distro name
    // TODO: extract the distro name through filtering it in a list of distro names produced by
    // uname -a.
    public static function get_distro():String {
        var result:Process = new Process("uname", ["-a"]);
        return result.stdout.readAll().toString();
    }

    // used for getting uptime
    public static function get_uptime():String {
        return new Process("uptime").stdout.readAll().toString();
    }

    // get user name
    public static function get_user():String {
        return new Process("$USER").stdout.readAll().toString();
    }

    // kernel version
    public static function get_kernel_version():String {
        return new Process("uname", ["-r"]).stdout.readAll().toString();
    }

    // get the shell
    public static function get_shell():String {
        return new Process("$SHELL").stdout.readAll().toString();
    }

    // get the terminal emulator
    public static function get_term():String {
        return new Process("echo", ["$TERM"]).stdout.readAll().toString();
    }

    // get amount of installed pkgs, will filter this to each pkg manager later on
    public static function get_pkgs():Int {
        return 2;
    }

    // get RAM
    public static function get_ram():Int {
        return Std.parseInt(new Process("grep", ["MemTotal", "/proc/meminfo"]).stdout.readAll().toString());
    }

    public static function get_main_drive():Array<String> {
        var r:Array<{Filesystem:String, Size:String, Used:String, Avail:String, UsePct:String, MountedOn:String}> = DfParser.parse(new Process("df").stdout.readAll().toString());

        var main_drive:Drive = {
            Filesys: "",
            Avail: "",
            MountedOn: "",
            Size: "",
            UsePct: "",
            Used: ""
        };

        var largest:Int = 0;

        // find the largest partition
        for (i in r) {
            if (Std.parseInt(i.Size) > largest) {
                largest = Std.parseInt(i.Size);
                main_drive.Filesys = i.Filesystem;
                main_drive.Avail = i.Avail;
                main_drive.MountedOn = i.MountedOn;
                main_drive.Size = i.Size;
                main_drive.UsePct = i.UsePct;
                main_drive.Used = i.Used;
            }

            trace(i.Size);
        }

        return [main_drive.Filesys, main_drive.Avail, main_drive.MountedOn, main_drive.Size, main_drive.UsePct, main_drive.Used];
        
    }

    // get the distro ascii
    public static function get_ascii(distro:String):String {
        var ascii_str:String = "";
        for (i in FileSystem.readDirectory("ascii")) {
            if (i == distro + ".txt") {
                ascii_str = File.getContent("ascii/" + distro + ".txt");
            }
        }
        return ascii_str;
    }

    public static function print_fetch(distro:String) {

        // some important vars
        var ascii_lines:Array<String> = File.getContent("ascii/" + distro + ".txt").split("\n");
        var step:Int= 2;   
        var longest:Int = 0;

        // Find the longest line
        for (line in ascii_lines) {
            if (line.length > longest) {
                longest = line.length;
            }
        }

        var index:Int = 0;
        var arr_to_print:Array<String> = get_main_drive();

        // align them
        for (line in ascii_lines) {
            print(line);
            for (space in 0...(longest-line.length)+step) {
                print(" ");
            }

            if (arr_to_print[index] != null) {
                print(arr_to_print[index]);
            }

            print('\n');

            index++;
        }
       
    }
}


typedef Drive =  {
    var Filesys: String;
    var Size: String;
    var Used: String;
    var Avail: String;
    var UsePct: String;
    var MountedOn:String;
}