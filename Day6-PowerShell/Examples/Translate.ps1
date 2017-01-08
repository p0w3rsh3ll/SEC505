
param ($into = "German")

filter translate ([String] $into = "German") 
{
	$word = $_
	switch ($into) {
	      French  {"La "  + $word + "ette..."}
	      Greek   {"Oi "  + $word + "tai;"   }
	      German  {"Das " + $word + "en!"    }
	      English {"The " + $word + ", dude!"}
	}
}

$input | translate -into $into


