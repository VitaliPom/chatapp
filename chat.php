<?php

$file = "message.txt";
if (file_exists($file)) {
	$incoming = $_POST['message']; 
	if(!empty($incoming)){
		$file_h = fopen($file, "a");
		fwrite($file_h, $incoming."\n");
		fclose($file_h);
	}
	readfile($file);
}

?>
