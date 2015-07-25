<?php

$url = "http://archives.bassdrivearchive.com/";
$sets = [];

fetchDirectoryLinks("", $url, $sets);

echo json_encode($sets);

function fetchDirectoryLinks($url, $base = "", &$sets) {

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
      $sets[] = $url.$link;
    } else {
      fetchDirectoryLinks($link, $base, $sets[$url.$link]);
    }
    
  }

  return $sets;
}