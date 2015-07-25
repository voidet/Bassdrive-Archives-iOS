<?php

$url = "http://archives.bassdrivearchive.com";

fetchDirectoryLinks("", $url);


function fetchDirectoryLinks($url, $base = "") {

  if (!$base) {
    $base = $url;
  }

  $url = $base.$url;
  $contents = file_get_contents($url);
  preg_match_All("|href=[\"'](.*?)[\"']|", $contents, $hrefs);
  
  array_shift($hrefs[1]);
  foreach ($hrefs[1] as $link) {

    

    $base = $url;
    if (!preg_match("*/$*", $link)) {
      echo $url.$link."<br />";
    } else {
      fetchDirectoryLinks($link, $base);
    }
    
  }

  return $hrefs[1];
}