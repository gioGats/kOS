cd 'C:\Users\rgio\Documents\GitHub\KSTools\KSValidator\bin\Release\'

$ksfiles = get-childitem 'C:\Users\rgio\Documents\GitHub\kOS\v0.2\' -recurse | select-object FullName



Foreach ($i in $ksfiles) {
    .\KSValidator --file=$i
    #Write-Output $i
    #Write-Output $i.ToString().Substring($i.ToString().get_Length()-2)
    #IF ($i[-2] -eq 'ks') {
    #    Write-Output $i
    #    
    #}
}
