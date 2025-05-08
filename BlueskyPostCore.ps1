# BlueskyPostCore.ps1
# Core logic for creating and posting Bluesky posts with custom facets
# Requires: PSBlueSky module, FunkyFacetLink function

function FunkyFacetLink {
    # this was nabbed from PSBlueSky (_newFacetLink in helpers.ps1)
    # https://docs.bsky.app/docs/advanced-guides/post-richtext
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'The Bluesky message with the links')]
        [string]$Message,
        [Parameter(Mandatory, HelpMessage = 'The text of the link')]
        [string]$Text,
        [Parameter(HelpMessage = 'The URI of the link')]
        [string]$Uri,
        [Parameter(HelpMessage = 'The DID of the mention')]
        [string]$DiD,
        [Parameter(HelpMessage = 'The Tag text')]
        [string]$Tag,
        [ValidateSet('link', 'mention', 'tag')]
        [string]$FacetType = 'link'
    )

    $PSDefaultParameterValues['_verbose:block'] = 'PRIVATE'
    $feature = Switch ($FacetType) {
        'link' {
            [PSCustomObject]@{
                '$type' = 'app.bsky.richtext.facet#link'
                uri     = $Uri
            }
        }
        'mention' {
            [PSCustomObject]@{
                '$type' = 'app.bsky.richtext.facet#mention'
                did     = $DiD
            }
        }
        'tag' {
            [PSCustomObject]@{
                '$type' = 'app.bsky.richtext.facet#tag'
                tag     = $Tag
            }
        }
    }

    if ($text -match '\[|\]|\(\)') {
        $text = [regex]::Escape($text)
    }
    #the comparison test is case-sensitive
    if (([regex]$Text).IsMatch($Message)) {
        #properties of the facet object are also case-sensitive
        $m = ([regex]$Text).match($Message)
        [PSCustomObject]@{
            index    = [ordered]@{
                byteStart = $m.index
                byteEnd   = ($m.length) + ($m.index)
            }
            features = @(
                $feature
            )
        }
    }
    else {
        Write-Warning ("Text not found: $Text in $Message")
    }
}

function Get-BskyCredentials {
    param(
        [switch]$FromVault,
        [string]$VaultName = 'PowerShell',
        [string]$SecretName = 'BlueSky'
    )
    if ($FromVault) {
        if (Get-Command Get-Secret -ErrorAction SilentlyContinue) {
            try {
                return Get-Secret -Vault $VaultName -Name $SecretName
            }
            catch {
                Write-Warning "Could not retrieve secret from vault. Falling back to manual entry."
            }
        }
        else {
            Write-Warning "SecretManagement module not available. Falling back to manual entry."
        }
    }
    # Manual entry fallback
    return Get-Credential -Message "Enter your BlueSky credentials"
}

function Find-BskyUserDid {
    param(
        [string]$Username
    )
    $user = Find-BskyUser -UserName $Username | Select-Object -First 1
    if ($user -and $user.Did) {
        return $user.Did
    }
    else {
        Write-Warning "User not found or DID not available."
        return $null
    }
}

function New-BskyFacet {
    param(
        [string]$Type, # mention, tag, link
        [string]$Text,
        [string]$Message,
        [string]$Did,
        [string]$Tag,
        [string]$Uri
    )
    FunkyFacetLink -FacetType $Type -Text $Text -Message $Message -Did $Did -Tag $Tag -Uri $Uri
}

function New-BskyPostObject {
    param(
        [string]$Text,
        [array]$Facets
    )
    [ordered]@{
        '$type'     = 'app.bsky.feed.post'
        'text'      = $Text
        'createdAt' = (Get-Date -Format 'o')
        'facets'    = $Facets
    }
}

function Preview-BskyPost {
    param(
        [hashtable]$PostObject
    )
    # Simple preview (can be improved)
    $PostObject | ConvertTo-Json -Depth 7 | Out-String
}

function Publish-BskyPost {
    param(
        [hashtable]$PostObject,
        [pscredential]$Credentials
    )
    # Start session if not already started
    $session = Get-BskySession -ErrorAction SilentlyContinue
    if (-not $session) {
        Start-BskySession -Credential $Credentials | Out-Null
    }
    # Post using PSBluesky
    $result = New-BskyPost -Message $PostObject['text'] -Facets $PostObject['facets']
    return $result
}

function Open-BskyPostInBrowser {
    param(
        [string]$PostUri
    )
    Start-Process $PostUri
}

Export-ModuleMember -Function *
