$addon=[PSISEAddon]::new("Tab File","This addon will format the current file with appropriate Tabbing",$null,"Formatting",{ 
		 
		function format-CurrentFile_Tabs(){ 
			$formattedCode=(format-code_tabs -code $psise.CurrentFile.Editor.Text); 
			 
			if($formattedCode){ 
				$psise.CurrentFile.Editor.Text=$formattedCode 
			} 
		} 
		 
		function format-code_tabs(){ 
			param([String]$code) 
			 
			$Err = $null 
			$parsedCode=[System.Management.Automation.PSParser]::Tokenize($code,[ref]$Err) 
			 
			<###
Check for ERRORS
https://github.com/DTW-DanWard/PowerShell-Beautifier/blob/master/src/DTW.PS.Beautifier.Main.psm1
Lines 418-436ish
###> 
			 
			if ($null -ne $Err -and $Err.Count){ 
				Write-Error -Message "Something Went wrong, likely invalid powershell formatting in code" 
			} 
			else 
			{ 
				$groupdepth=0 
				$newGroupdepth=0 
				$CodeString="" 
				$line="" 
				$lineStart=0 
				$lineEnd=0 
				#Write-host "--------------------------------------------------" 
				foreach($item in $parsedCode){ 
					$lineEnd=$item.start+$item.Length 
					if($item.Type -eq "NewLine"){ 
						$line=$code.Substring($linestart,($lineEnd-$linestart)).Trim() 
						$OutLine="" 
						if($newGroupdepth -lt $groupdepth){ 
							$groupdepth=$newGroupdepth 
						} 
						for($i=0;$i -lt $groupdepth;$i++){ 
							$OutLine+="`t" 
						} 
						$OutLine+="$line `n" 
						$CodeString+=$outline 
						$linestart=$lineEnd 
						#write-host "$groupdepth::$OutLine" 
						$groupdepth=$newGroupdepth 
					} 
					if($item.Type -eq "GroupStart"){ 
						$newGroupdepth++ 
					} 
					if($item.Type -eq "GroupEnd"){ 
						$newGroupdepth-- 
					} 
				} 
				$line=$code.Substring($linestart,($lineEnd-$linestart)).Trim() 
				$OutLine="" 
				if($newGroupdepth -lt $groupdepth){ 
					$groupdepth=$newGroupdepth 
				} 
				for($i=0;$i -lt $groupdepth;$i++){ 
					$OutLine+="`t" 
				} 
				$OutLine+="$line `n" 
				$CodeString+=$outline 
				$linestart=$lineEnd 
				#write-host "$groupdepth::$OutLine" 
				$groupdepth=$newGroupdepth 
				 
				return $CodeString 
			} 
		} 
		 
		format-CurrentFile_Tabs 
		 
		 
},$true) 
 
<#
$addon| Export-Clixml "\$($addon.GetName().Replace(" ","_")).xml"


$test =Import-Clixml "\$($addon.GetName().Replace(" ","_")).xml"
#$test.GetType()

 $importaddon=[PSISEAddon]::new($test)

 $test.action
 #> 
 
 
 
 
