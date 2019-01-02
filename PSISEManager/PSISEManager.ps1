$addon=[PSISEAddon]::new("PS ISE Manager","This addon displays addons so you can enable or disable them",$null,"",{ 
		  
        function show-PSISEManager(){
            #Basic Form
             Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.Application]::EnableVisualStyles()

            $Form                            = New-Object system.Windows.Forms.Form
            $Form.ClientSize                 = '350,400'
            $Form.text                       = "PS ISE Manager"
            $Form.TopMost                    = $false

            $Label1                          = New-Object system.Windows.Forms.Label
            $Label1.text                     = "Addons"
            $Label1.AutoSize                 = $true
            $Label1.width                    = 20
            $Label1.height                   = 10
            $Label1.location                 = New-Object System.Drawing.Point(15,15)
            $Label1.Font                     = 'Microsoft Sans Serif,10'

            $ListBoxAddons                   = New-Object system.Windows.Forms.ListBox
            $ListBoxAddons.width             = 200
            $ListBoxAddons.height            = 200
            $ListBoxAddons.location          = New-Object System.Drawing.Point(15,35)

            $Checkbox_Addon_Enabled          = New-Object system.Windows.Forms.CheckBox
            $Checkbox_Addon_Enabled.text     = "Enabled"
            $Checkbox_Addon_Enabled.AutoSize  = $false
            $Checkbox_Addon_Enabled.width    = 75
            $Checkbox_Addon_Enabled.height   = 20
            $Checkbox_Addon_Enabled.location  = New-Object System.Drawing.Point(20,348)
            $Checkbox_Addon_Enabled.Font     = 'Microsoft Sans Serif,10'
            $Checkbox_Addon_Enabled.Visible = $false

            $Label_Addon_Name                = New-Object system.Windows.Forms.Label
            $Label_Addon_Name.AutoSize       = $true
            $Label_Addon_Name.width          = 25
            $Label_Addon_Name.height         = 10
            $Label_Addon_Name.location       = New-Object System.Drawing.Point(20,250)
            $Label_Addon_Name.Font           = 'Microsoft Sans Serif,10,style=Bold'

            $Label_Addon_Description         = New-Object system.Windows.Forms.Label
            $Label_Addon_Description.MaximumSize = [System.Drawing.Size]::new(300,0)
            $Label_Addon_Description.AutoSize  = $true
            $Label_Addon_Description.location  = New-Object System.Drawing.Point(20,275)
            $Label_Addon_Description.Font    = 'Microsoft Sans Serif,10'

            $Button_Save                     = New-Object system.Windows.Forms.Button
            $Button_Save.text                = "Save"
            $Button_Save.width               = 60
            $Button_Save.height              = 30
            $Button_Save.location            = New-Object System.Drawing.Point(180,350)
            $Button_Save.Font                = 'Microsoft Sans Serif,10'

            $Button_Cancel                   = New-Object system.Windows.Forms.Button
            $Button_Cancel.text              = "Cancel"
            $Button_Cancel.width             = 60
            $Button_Cancel.height            = 30
            $Button_Cancel.location          = New-Object System.Drawing.Point(270,350)
            $Button_Cancel.Font              = 'Microsoft Sans Serif,10'

            $Form.controls.AddRange(@($Checkbox_Addon_Enabled,$ListBoxAddons,$Label1,$Label_Addon_Name,$Label_Addon_Description,$Button_Save,$Button_Cancel))


            ###
            $PSISEAddonsPath = "$($env:USERPROFILE)\MY Documents\windowspowershell\PSISEAddons" 
	        $PSISEAddonFiles =get-childitem $PSISEAddonsPath -Include *.addon -File -Recurse 
	        $PSISEAddons=@()
	        foreach($file in $PSISEAddonFiles){ 
            $addon=[PSISEAddon]::new((Import-Clixml $file.FullName))
            if($file.name -ne "PSISEManager.addon"){
		        $PSISEAddons+=[pscustomobject]@{name=$addon.name
                                                Description=$addon.Description
                                                Menu=$addon.MenuName 
                                                Action=$addon.action
                                                Shortcut=$addon.ShortCut
                                                Enabled=$addon.Enabled
                                                addon=$addon
                                                File=$file.FullName}
                                                }
	        }
            $addoncount=0 
	        foreach($addon in $PSISEAddons.addon){
                $addon

                [void] $ListBoxAddons.Items.Add($addon.getName())

             $addoncount++
		        } 
           
             $ListBoxAddons.add_SelectedIndexChanged({ 
                 $selectedaddon= $PSISEAddons|Where-Object {$_.name -eq "$($ListBoxAddons.SelectedItems)"}
                 if($selectedaddon){
                     $Label_Addon_Name.Text = $selectedAddon.name
                     $Label_Addon_Description.Text = $selectedAddon.description
                     $Checkbox_Addon_Enabled.Visible=$true
                     $Checkbox_Addon_Enabled.Checked=$selectedAddon.Enabled
                 }

             })

             $Checkbox_Addon_Enabled.Add_CheckStateChanged({
              $selectedaddon= $PSISEAddons|Where-Object {$_.name -eq "$($ListBoxAddons.SelectedItems)"}
                if($Checkbox_Addon_Enabled.Checked){
                    $selectedaddon.addon.Enable()
                }
                else{
                    $selectedaddon.addon.disable()
                }

             })

             $Button_Save.Add_Click({
                $addoncount=0 
                foreach($addon in $PSISEAddons)
                {
                Write-Progress -Activity "Processing $($addon.name) - $($addon.file)" -Status "$addoncount / $($PSISEAddons.count)" -PercentComplete (($addoncount / $($PSISEAddons.count))*100)
                $addon.addon | Export-Clixml "$($addon.file)"
                $addoncount++
                }
                Write-Progress -activity "done" -completed
                initialize-PSISEAddons
                $form.close()
               })

               $Button_Cancel.Add_Click({
   
                $form.close()
               })



	         $form.ShowDialog()
        
        }
        show-PSISEManager 


},$true) 
 
<#
$addon| Export-Clixml "C:\Users\zachary.fischer.SPINO\Documents\DEV\PS-ISE-Addons\PSISEAddons\PSISEManager\PSISEManager.addon"


$test =Import-Clixml "\$($addon.GetName().Replace(" ","_")).xml"
#$test.GetType()

 $importaddon=[PSISEAddon]::new($test)

 $test.action
 #> 
 
 
 
 
