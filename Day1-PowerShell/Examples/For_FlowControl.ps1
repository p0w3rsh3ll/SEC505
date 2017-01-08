
For ( $i = 0 ; $i -le 20 ; $i++ ) {
	"Now at $i"
}




For ( $( $i=0; $j=0; $ps=@(get-process|select-object name)); 
      $( $ps.count -ge ($i + $j) ) ; 
      $( $i += 2 ; $j++ ) 
    ) 
{
	$ps[$i]
}
 
