<#

ignore this file just me hacking away, this doesn't work, see FunkyFacets.ps1


$postText = @"
just Ignore this, just playing with #PSBlueSky, multi-line strings and Markdown style links
[Home of the PowerShell Young Team](https://powershellyoungteam.github.io/)

#messingabout
"@#>


<#
#New-BskyPost $postText   -Verbose

#https://docs.bsky.app/blog/create-post

#>
######### THIS WORKS!!!!
# https://bsky.app/profile/poshyoungteam.bsky.social/post/3lj4rdci6mv2r

# Define the post text
$postText = "Hello Darry Borrans! direct from Invoke-RestMethod with funky facets"
$facets = @()
$facets = @(
    @{
        index    = @{
            byteStart = 7
            byteEnd   = 18
        }
        features = @(
            @{
                "$type" = "app.bsky.richtext.facet#mention"
                did     = "did:plc:hfgp6pj3akhqxntgqwramlbg"
            }
        )
    }
)
# Create the record data
$record = @{
    "$type"     = "app.bsky.feed.post"
    "text"      = $postText
    "createdAt" = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
    "facets"    = $facets
}

# Create the full data object including the repo and collection
$postData = @{
    "repo"       = "did:plc:k54achhksfhvlp5jd3rzv32h"  # Replace with your actual DID
    "collection" = "app.bsky.feed.post"  # Specify the collection
    "record"     = $record
}

# Convert the post data to JSON with increased depth
$postDataJson = $postData | ConvertTo-Json -Depth 10

# Get the headers for the API request
$headers = (Get-BskySession).CreateHeader()

_newFacetLink

# Post to Bluesky using the API
Invoke-RestMethod -Uri "https://bsky.social/xrpc/com.atproto.repo.createRecord" -Method Post -Body $postDataJson -Headers $headers