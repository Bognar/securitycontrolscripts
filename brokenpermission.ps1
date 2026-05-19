# 1. Create a dedicated test directory "Insecure Service Executables: If a service runs as SYSTEM but the executable file itself allows "Modify" or "Write" permissions for the Everyone or Authenticated Users group, an attacker can simply replace service.exe with a malicious payload and restart the machine."
$TestDir = "C:\InsecureServiceTest"
New-Item -ItemType Directory -Path $TestDir -Force

# 2. Create a dummy text file renamed to an .exe (safe placeholder)
$ServicePath = "$TestDir\MockService.exe"
New-Item -ItemType File -Path $ServicePath -Force
Set-Content -Path $ServicePath -Value "This is a dummy service executable for security testing purposes."

# 3. Create a mock Windows Service that points to this file
# Note: The service won't successfully start since it's just text, but the configuration will exist.
New-Service -Name "MockInsecureService" -BinaryPathName $ServicePath -StartupType Manual

# 4. EXPLOIT SIMULATION SETUP: Give the 'Everyone' group Full Control (Write/Modify) permissions
$Acl = Get-Acl -Path $ServicePath
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl -Path $ServicePath $Acl

Write-Host "[+] Mock environment set up successfully." -ForegroundColor Green
Write-Host "[!] The file at $ServicePath is now insecurely writeable by anyone." -ForegroundColor Yellow



# 2. Attempt to overwrite the service executable as a low-privileged user run this script from normal user priviledge powershell
try {
    Set-Content -Path "C:\InsecureServiceTest\MockService.exe" -Value "Vulnerability Confirmed: Standard user successfully modified the service binary."
    Write-Host "[!] SUCCESS: The file was modified. Your system is vulnerable to Insecure Service Executable hijacking." -ForegroundColor Red
} catch {
    Write-Host "[+] FAILED: Access Denied. The system blocked the modification." -ForegroundColor Green

# 3. Remove the mock service
Remove-Service -Name "MockInsecureService"
sc.exe delete "MockInsecureService"

# Delete the test directory and dummy binary
Remove-Item -Path "C:\InsecureServiceTest" -Recurse -Force


Write-Host "[+] Test environment completely cleaned up and removed." -ForegroundColor Green