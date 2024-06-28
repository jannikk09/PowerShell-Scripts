$userName = "Admin"
$userexist = (Get-LocalUser).Name -Contains $userName
if($userexist) {
  try{ 
     Remove-LocalUser -Name $username
     Exit 0
   }   
  Catch {
     Write-error $_
     Exit 1
   }
}
