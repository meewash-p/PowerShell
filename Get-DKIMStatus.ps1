# Set-ExecutionPolicy RemoteSigned
# winrm quickconfig
# winrm get winrm/config/client/auth
# winrm set winrm/config/client/auth @{Basic="true"}

# Install-Module ExchangeOnlineManagement

Connect-ExchangeOnline

Get-DkimSigningConfig | Select Domain, Enabled, Status, IsValid | ft
