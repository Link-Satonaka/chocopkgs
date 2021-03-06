Import-Module au

$releases = 'https://api.github.com/repos/AntiMicro/antimicro/releases/latest'
$headers = @{
    'User-Agent' = 'AeliusSaionji'
    'Accept' = 'application/vnd.github.v3+json'
}

function global:au_SearchReplace {
  @{
    ".\tools\chocolateyinstall.ps1" = @{
      "(?i)(^\s*[$]?checksumType\s*=\s*)('.*')" = "`${1}'$($Latest.ChecksumType32)'"
      "(?i)(^\s*[$]?checksum\s*=\s*)('.*')"     = "`${1}'$($Latest.Checksum32)'"
      "(?i)(^\s*[$]?url\s*=\s*)('.*')"          = "`${1}'$($Latest.URL32)'"
    }
  }
}

function global:au_BeforeUpdate {}

function global:au_GetLatest {
  $restAPI = Invoke-RestMethod $releases -Headers $headers
  $Matches = $null
  $restAPI.tag_name -match '(\d+\.?)+'
  $version = $Matches[0]
  $url32 = $restAPI.assets | Where-Object { ($_.content_type -eq 'application/zip') `
    -and ($_.name -notlike '*nosse*' ) } `
    | Select-Object -First 1 -ExpandProperty browser_download_url

  return @{ Version = $version; URL32 = $url32 }
}

Update-Package
