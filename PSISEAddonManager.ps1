
function initialize-PSISEAddons () {
	#$psProfilePath = "$($env:USERPROFILE)\MY Documents\windowspowershell\" 
	$PSISEAddonsPath = "$($env:USERPROFILE)\MY Documents\windowspowershell\PSISEAddons"
	$PSISEAddonFiles = Get-ChildItem $PSISEAddonsPath -Include *.addon -File -Recurse
	$PSISEAddons = @()

	$PSISEMenu = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Where({ $_.DisplayName -eq "PS-ISE-Addons" })[0]
	if ($PSISEMenu) {
		$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Remove($PSISEMenu)
	}
	foreach ($file in $PSISEAddonFiles) {
		$PSISEAddons += [PSISEAddon]::new((Import-Clixml $file.FullName))
	}
	$addoncount = 0
	foreach ($addon in $PSISEAddons) {

		Write-Progress -Activity "Processing $($addon.getName)" -Status "$addoncount / $($PSISEAddons.count)" -PercentComplete (($addoncount / $($PSISEAddons.count)) * 100)
		if ($addon.enabled)
		{
			Write-Progress -Activity "Installing $($addon.getName)" -Status "$addoncount / $($PSISEAddons.count)" -PercentComplete (($addoncount / $($PSISEAddons.count)) * 100)
			$addon.AddToISE($psISE)

		}
		$addoncount++
	}
	Write-Progress -Activity "Done" -Completed
}



function install-PSISEAddons ($directory) {

	$psProfilePath = "$($env:USERPROFILE)\MY Documents\windowspowershell\"
	$psProfilePS1Path = "$($env:USERPROFILE)\MY Documents\windowspowershell\Microsoft.PowerShellISE_profile.ps1"
	$psProfile = Get-Content $psProfilePS1Path
	if (!(Test-Path "$($psProfilePath)PSISEAddons\")) {
		Copy-Item $directory -Destination "$($psProfilePath)PSISEAddons\" -Recurse -Force

	}
	if (!($psProfile.Contains("Import-Module `"`$(`$env:USERPROFILE)\MY Documents\windowspowershell\PSISEAddons\Init_PSISEAddonManager.ps1`""))) {
		$psProfile += "Import-Module `"`$(`$env:USERPROFILE)\MY Documents\windowspowershell\PSISEAddons\Init_PSISEAddonManager.ps1`""
		$psProfile | Out-File $psProfilePS1Path

		"Import-Module `"`$(`$env:USERPROFILE)\MY Documents\windowspowershell\PSISEAddons\PSISEAddonManager.ps1`" `n
        initialize-PSISEAddons" | Out-File "$($psProfilePath)\PSISEAddons\Init_PSISEAddonManager.ps1"

	}

}
<#
install-PSISEAddons $pwd
#>

class PSISEAddon
{
	################## 
	# Properties 
	################## 
	[string]
	$name
	# "CodeTabber" 

	[string]
	$Description
	# "addon formats current file with tabs" 

	[string]
	$MenuName
	# "Name of Submenu" 

	[string]
	$ShortCut
	# "CTRL+Shift+T" 

	[bool]
	$Enabled
	# is this this visible in the menu 

	[scriptblock]
	$action
	# {run Code when clicked in menu} 

	################## 
	# Constructors 
	################## 
	PSISEAddon ([string]$name,[string]$description,[string]$shortcut,[string]$MenuName,[scriptblock]$action,[bool]$enabled) {
		$this.Name = $name
		$this.description = $description
		$this.shortcut = $shortcut
		$this.MenuName = $MenuName
		$this.action = $action
		$this.enabled = $enabled

	}

	PSISEAddon ($PSISEAddon) {
		if ($PSISEAddon.psobject.TypeNames[0] -eq "Deserialized.PSISEAddon") {


			$this.Name = $PSISEAddon.Name
			$this.description = $PSISEAddon.description
			$this.shortcut = $PSISEAddon.shortcut
			$this.MenuName = $PSISEAddon.MenuName
			$this.action = [scriptblock]::Create($PSISEAddon.action)
			$this.enabled = $PSISEAddon.enabled
		}
		else {
			Write-Error "$PSISEAddon must be a Deserialized.PSISEAddon"
		}
	}

	################## 
	# sets 
	################## 
	[void] SetName ([string]$name) {
		$this.Name = $name
	}
	[void] SetDescription ([string]$Description) {
		$this.description = $Description
	}
	[void] SetShortcut ([string]$shortcut) {
		$this.shortcut = $shortcut
	}
	[void] SetAction ([scriptblock]$Action) {
		$this.action = $Action
	}
	[void] Enable () {
		$this.enabled = $true
	}
	[void] Disable () {
		$this.enabled = $false
	}

	################## 
	# Gets 
	################## 
	[string] GetName () {
		return $this.Name
	}
	[string] GetDescription () {
		return $this.description
	}
	[string] GetShortcut () {
		return $this.shortcut
	}
	[string] GetMenuName () {
		return $this.MenuName
	}
	[string] GetActionDefinition () {
		return $this.action.ToString()
	}

	################## 
	# Do Stuff 
	################## 
	[void] AddToISE ($ISE) {
		#$ISE should be passed $psise 
		if ($this.enabled) {
			$PSISEMenu = $ISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Where({ $_.DisplayName -eq "PS-ISE-Addons" })[0]
			if (!($PSISEMenu))
			{
				$PSISEMenu = $ISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("PS-ISE-Addons",$null,$null)
			}
			#$ISE.CurrentPowerShellTab.AddOnsMenu.Submenus 
			if ($this.MenuName)
			{
				$menu = $PSISEMenu.Where({ $_.DisplayName -eq "$($this.MenuName)" })[0]
				if (!($menu))
				{
					$menu = $PSISEMenu.Submenus.Add("$($this.MenuName)",$null,$null)
				}
			}
			else {
				$menu = $PSISEMenu
			}

			$ExistingMenuItem = $menu.Submenus.Where({ $_.DisplayName -eq "$($this.name)" })[0]
			if ($ExistingMenuItem) {
				$menu.Submenus.Remove($ExistingMenuItem)
			}
			if ($this.shortcut -ne "") {
				$sc = $this.shortcut
			}
			else {
				$sc = $null
			}
			$menu.Submenus.Add("$($this.name)",$this.action,$sc)
		}
		else {
			Write-Error "This addon is not enabled"
		}
	}


}

<#
$menu = $psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("PS-ISE-Addons",$null,$null) 
$menu.Submenus.Add("Display PS-ISE-Addon Manager",{ show-PSISEAddonManager },$null) 
$psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Removeat(1)
#>
