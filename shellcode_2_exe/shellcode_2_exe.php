<?php
/*
Author: david@idefense.com

Purpose: shellcode_2_exe.php

	Shellcode 2 exe is a small php script used to generate
	executables on the fly for shellcode you submit to it
	through a web form.

	This technique provides an easy way to analyze new
	shellcode buffers in your debugger of choice. Note that
	this techniques demands that the shellcode you are analyzing
	does not use any predefined function offsets that would only
	be valid if evecuting within the target processes address space.

	In todays arena of modern position independant shellcodes this
	limitation is usually not a problem.

	Husk.exe is the base template used for generated executables.
	
	Note that the husk template includes a function call to WSAStartup
        to load winsock services. Thisis necessary with some shellcodes
        that assume this has already taken place in the target process.

License: Copyright (C) 2005 David Zimmer <david@idefense.com, dzzie@yahoo.com>

         This program is free software; you can redistribute it and/or modify it
         under the terms of the GNU General Public License as published by the Free
         Software Foundation; either version 2 of the License, or (at your option)
         any later version.

         This program is distributed in the hope that it will be useful, but WITHOUT
         ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
         FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
         more details.

         You should have received a copy of the GNU General Public License along with
         this program; if not, write to the Free Software Foundation, Inc., 59 Temple
         Place, Suite 330, Boston, MA 02111-1307 USA
         
*/

$arr = array_merge(&$_ENV,&$_GET,&$_POST,&$_COOKIE,&$_SESSION);
while(list($key) = each($arr)) unset(${$key});

error_reporting(0);

$shellcode = $_POST["shellcode"];
$bytesOnly = $_POST["bytesOnly"];

if($bytesOnly=="on") $bytesOnly=1;
 else $bytesOnly=0;
  
if( strlen($shellcode) > 0 ){  generateFile($shellcode,$bytesOnly);}
 else{outputForm(0);}

 
//***********************************************************

function generateFile($shellcode, $bytesOnly){
    
	$shellcode = trim($shellcode);
 	$shellcode = str_replace("\n", "", $shellcode);
 	$shellcode = str_replace("\r", "", $shellcode);
 	$shellcode = str_replace('"', "", $shellcode);
 	$shellcode = str_replace("'", "", $shellcode);
 	$shellcode = str_replace("\t", "", $shellcode);
 	$shellcode = str_replace(" ", "", $shellcode);
 	$shellcode = str_replace("+", "", $shellcode);
 	$shellcode = str_replace(";", "", $shellcode);
 	
 	if(stristr($shellcode, "%u")){  //IE html type %u____ payload 
		$tmp = explode("%u",$shellcode);
		$shellcode = '';
	    for($i=0;$i<count($tmp);$i++){
	        $shellcode = $shellcode . swapToBytes($tmp[$i]);
	    }
	}
	elseif(stristr($shellcode,"\x")){ //C String type buffer
		$tmp = explode("\x", substr($shellcode,2)) ; //remove first \x to fill elem 0
		$shellcode = HexArrayToString($tmp);
	}
	else{ //assume they are raw hex values either 909090 or 90 90 90 (spaces nixed at top to unify)
		$tmp = explode(" ", SpaceOutHex($shellcode));
		$shellcode = HexArrayToString($tmp);
	}			
	
    if($bytesOnly==1){
	    $husk = $shellcode;
	    $fname = "bytes.sc";
    }
    else{
		$husk = getHusk();
    	$husk = substr($husk,0,0x1020).$shellcode.substr($husk, (0x1020+strlen($shellcode)) ); 
    	$fname = "shellcode.exe_";
    }

    header("HTTP/1.0 200 OK");
    header("Content-type: application/octet-stream",true);
    header("Content-Transfer-Encoding: binary",true);
    header("Content-length: ".strlen($husk),true);
    header("Content-Disposition: inline; filename=".$fname,true);
     
    print $husk;


}

function swapToBytes($x){
	if(strlen($x) == 0){ return "";}
	if(strlen($x)!=4) {
			print "Data does not match %u encoding:" .$x. " strlen:".strlen($x) ;
			die(0);
	}
	
	$a = substr($x,0,2);
	$b = substr($x,2,4);
	
	return chr(hexdec($b)) . chr(hexdec($a));
}

function getHusk(){
	$filename = "husk.exe";
	$fd = fopen ($filename, "rb");
	$contents = fread ($fd, filesize ($filename));
	fclose ($fd);
	return $contents;
}

function SpaceOutHex($x){
	$z='';
    for($i=0;$i<strlen($x);$i+=2){
        $z = $z . substr($x,$i,2) . " ";
    }
    return $z;
}

function HexArrayToString($ary){
	$ret='';
	for($i=0;$i<count($ary);$i++){
		if(strlen($ary[$i]) > 0){
			$ret = $ret . chr(hexdec($ary[$i]));
		}
	}
	return $ret;		
}


function outputForm($d){
    
    ?>

    <html>
    <body bgcolor=white><br><br><br>
    <center>
    <script>
    	function dohelp(){
	    	alert( "Currently supports 3 shellcode data formats:\n\n"+
	    	       "1) %u urlencoded IE shellcode payloads\n"+
	    	       "2) \\x style C strings\n"+
	    	       "3) raw hex strings with no spaces ex. 9090EB15\n\n"+	    
	    	       "Paste in your shellcode and hit submit..it will decode\n"+
	    	        "it and throw it into an exe husk so you can then play\n"+
	    	       "with it directly in your favorite debugger.\n\n"+
	    	       "Works great for modern shellcode that loads all its own\n"+
	    	       "imports and does not contain any hardcoded offsets\n\n"+
	    	       "NOTE: IE does not always play well with the Bytes Only option\n"+
	    	       "if you have a problem add a null byte to the end of your code\n"+
	    	       "or try another browser like Firefox."
	    	     );
    	}
    </script>
    
    <form method=post action="shellcode_2_exe.php">
      <table bordercolor=black cellpadding=3 cellspacing=0 border=1 style="font-family:arial;color:black;font-size:14pt;">
         <tr><td height=40 valign=center align=center>Shellcode 2 EXE</td></tr>
         <tr><td>
           <table>
             <tr><td width=50 colspan=2>Shellcode:</td></tr>
             <tr><td colspan=2> 
             	<textarea name=shellcode cols=50 rows=20></textarea>
             </td></tr>
             <tr><td><a href="javascript:dohelp()">help</a> &nbsp; <input type=checkbox name=bytesOnly> Bytes Only (no exe shell) </td>
                 <td align=right><input type=submit value=submit></td>
             </tr>
           </table>
         </td></tr>
      </table>
    </form>
       
    <?
}