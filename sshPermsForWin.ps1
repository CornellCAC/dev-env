# DO the following in powerhsell if not already done:
# Set-ExecutionPolicy RemoteSigned


# NOTE: edit the path in this command if needed
$sshFiles=Get-ChildItem -Path C:\DevContainerHome\.ssh -Force

$sshFiles | % {
  $key = $_
  & icacls $key /c /t /inheritance:d
  & icacls $key /c /t /grant %username%:F
  & icacls $key  /c /t /remove Administrator "Authenticated Users" BUILTIN\Administrators BUILTIN Everyone System Users
}

# Verify:
$sshFiles | % {
  icacls $_
}