# BlueskyPostGUI.ps1
# GUI for creating Bluesky posts with custom facets using BlueskyPostCore.ps1
# Requires: Import-Module ./BlueskyPostCore.ps1

Import-Module "$PSScriptRoot/BlueskyPostCore.ps1"

Add-Type -AssemblyName PresentationFramework

function Show-BskyPostGui {
    # Main window
    $window = New-Object Windows.Window
    $window.Title = 'Bluesky Post Creator'
    $window.Width = 600
    $window.Height = 900  # Increased height for more space
    $window.WindowStartupLocation = 'CenterScreen'

    # StackPanel for layout
    $stack = New-Object Windows.Controls.StackPanel
    $window.Content = $stack

    # Credentials section
    $credLabel = New-Object Windows.Controls.TextBlock
    $credLabel.Text = 'Enter PSBlueSky Credentials:'
    $stack.Children.Add($credLabel)
    $userBox = New-Object Windows.Controls.TextBox
    $userBox.Margin = '0,0,0,5'
    $userBox.ToolTip = 'Username or handle'
    $stack.Children.Add($userBox)
    $passBox = New-Object Windows.Controls.PasswordBox
    $passBox.Margin = '0,0,0,10'
    $passBox.ToolTip = 'App Password'
    $stack.Children.Add($passBox)

    # Get from Vault button
    $vaultBtn = New-Object Windows.Controls.Button
    $vaultBtn.Content = 'Get from Vault'
    $vaultBtn.Margin = '0,0,0,10'
    $stack.Children.Add($vaultBtn)
    # TODO: Add click event for vaultBtn to retrieve credentials from vault

    # Post text
    $postLabel = New-Object Windows.Controls.TextBlock
    $postLabel.Text = 'Post Text:'
    $stack.Children.Add($postLabel)
    $postBox = New-Object Windows.Controls.TextBox
    $postBox.Height = 60
    $postBox.AcceptsReturn = $true
    $postBox.TextWrapping = 'Wrap'
    $postBox.Margin = '0,0,0,10'
    $stack.Children.Add($postBox)

    # Facet management UI
    $facetLabel = New-Object Windows.Controls.TextBlock
    $facetLabel.Text = 'Facets:'
    $facetLabel.FontWeight = 'Bold'
    $facetLabel.Margin = '0,10,0,0'
    $stack.Children.Add($facetLabel)

    # Mention Facet
    $mentionGroup = New-Object Windows.Controls.GroupBox
    $mentionGroup.Header = 'Mention Facet'
    $mentionPanel = New-Object Windows.Controls.StackPanel
    $mentionGroup.Content = $mentionPanel
    $mentionTextLabel = New-Object Windows.Controls.TextBlock
    $mentionTextLabel.Text = 'Mention Text (from Post Text):'
    $mentionPanel.Children.Add($mentionTextLabel)
    $mentionTextBox = New-Object Windows.Controls.TextBox
    $mentionTextBox.Margin = '0,0,0,5'
    $mentionPanel.Children.Add($mentionTextBox)
    $mentionDidLabel = New-Object Windows.Controls.TextBlock
    $mentionDidLabel.Text = 'Mention DID:'
    $mentionPanel.Children.Add($mentionDidLabel)
    $mentionDidBox = New-Object Windows.Controls.TextBox
    $mentionDidBox.Margin = '0,0,0,5'
    $mentionPanel.Children.Add($mentionDidBox)
    $getDidBtn = New-Object Windows.Controls.Button
    $getDidBtn.Content = 'Get DID'
    $getDidBtn.Margin = '0,0,0,5'
    $mentionPanel.Children.Add($getDidBtn)
    $addMentionBtn = New-Object Windows.Controls.Button
    $addMentionBtn.Content = 'Add Mention Facet'
    $mentionPanel.Children.Add($addMentionBtn)
    $stack.Children.Add($mentionGroup)

    # Tag Facet
    $tagGroup = New-Object Windows.Controls.GroupBox
    $tagGroup.Header = 'Tag Facet'
    $tagPanel = New-Object Windows.Controls.StackPanel
    $tagGroup.Content = $tagPanel
    $tagTextLabel = New-Object Windows.Controls.TextBlock
    $tagTextLabel.Text = 'Tag Text (from Post Text):'
    $tagPanel.Children.Add($tagTextLabel)
    $tagTextBox = New-Object Windows.Controls.TextBox
    $tagTextBox.Margin = '0,0,0,5'
    $tagPanel.Children.Add($tagTextBox)
    $tagNameLabel = New-Object Windows.Controls.TextBlock
    $tagNameLabel.Text = 'Tag Name (one word):'
    $tagPanel.Children.Add($tagNameLabel)
    $tagNameBox = New-Object Windows.Controls.TextBox
    $tagNameBox.Margin = '0,0,0,5'
    $tagPanel.Children.Add($tagNameBox)
    $addTagBtn = New-Object Windows.Controls.Button
    $addTagBtn.Content = 'Add Tag Facet'
    $tagPanel.Children.Add($addTagBtn)
    $stack.Children.Add($tagGroup)

    # Link Facet
    $linkGroup = New-Object Windows.Controls.GroupBox
    $linkGroup.Header = 'Link Facet'
    $linkPanel = New-Object Windows.Controls.StackPanel
    $linkGroup.Content = $linkPanel
    $linkTextLabel = New-Object Windows.Controls.TextBlock
    $linkTextLabel.Text = 'Link Text (from Post Text):'
    $linkPanel.Children.Add($linkTextLabel)
    $linkTextBox = New-Object Windows.Controls.TextBox
    $linkTextBox.Margin = '0,0,0,5'
    $linkPanel.Children.Add($linkTextBox)
    $linkUriLabel = New-Object Windows.Controls.TextBlock
    $linkUriLabel.Text = 'Link URI:'
    $linkPanel.Children.Add($linkUriLabel)
    $linkUriBox = New-Object Windows.Controls.TextBox
    $linkUriBox.Margin = '0,0,0,5'
    $linkPanel.Children.Add($linkUriBox)
    $addLinkBtn = New-Object Windows.Controls.Button
    $addLinkBtn.Content = 'Add Link Facet'
    $linkPanel.Children.Add($addLinkBtn)
    $stack.Children.Add($linkGroup)

    # Facets added display (now with ListBox for selection)
    $addedFacetsLabel = New-Object Windows.Controls.TextBlock
    $addedFacetsLabel.Text = 'Facets Added:'
    $addedFacetsLabel.FontWeight = 'Bold'
    $addedFacetsLabel.Margin = '0,10,0,0'
    $stack.Children.Add($addedFacetsLabel)
    $addedFacetsList = New-Object Windows.Controls.ListBox
    $addedFacetsList.Height = 120
    $addedFacetsList.Margin = '0,0,0,10'
    $stack.Children.Add($addedFacetsList)

    # Edit/Remove buttons
    $facetBtnPanel = New-Object Windows.Controls.StackPanel
    $facetBtnPanel.Orientation = 'Horizontal'
    $removeFacetBtn = New-Object Windows.Controls.Button
    $removeFacetBtn.Content = 'Remove Selected Facet'
    $removeFacetBtn.Margin = '0,0,10,0'
    $editFacetBtn = New-Object Windows.Controls.Button
    $editFacetBtn.Content = 'Edit Selected Facet'
    $facetBtnPanel.Children.Add($removeFacetBtn)
    $facetBtnPanel.Children.Add($editFacetBtn)
    $stack.Children.Add($facetBtnPanel)

    # Facets array for session
    $global:facets = @()

    function Refresh-FacetList {
        $addedFacetsList.Items.Clear()
        $i = 0
        foreach ($f in $global:facets) {
            $type = $f.features[0].'$type' -replace 'app.bsky.richtext.facet#', ''
            $desc = "[$i] $($type): "
            switch ($type) {
                'mention' { $desc += $f.features[0].did }
                'tag' { $desc += $f.features[0].tag }
                'link' { $desc += $f.features[0].uri }
            }
            $desc += " (Text: $($f.index.byteStart)-$($f.index.byteEnd))"
            $addedFacetsList.Items.Add($desc)
            $i++
        }
    }

    # Add Mention Facet event
    $addMentionBtn.Add_Click({
            $facet = New-BskyFacet -Type 'mention' -Text $mentionTextBox.Text -Message $postBox.Text -Did $mentionDidBox.Text
            if ($facet) { $global:facets += $facet }
            Refresh-FacetList
        })
    # Add Tag Facet event
    $addTagBtn.Add_Click({
            $facet = New-BskyFacet -Type 'tag' -Text $tagTextBox.Text -Message $postBox.Text -Tag $tagNameBox.Text
            if ($facet) { $global:facets += $facet }
            Refresh-FacetList
        })
    # Add Link Facet event
    $addLinkBtn.Add_Click({
            $facet = New-BskyFacet -Type 'link' -Text $linkTextBox.Text -Message $postBox.Text -Uri $linkUriBox.Text
            if ($facet) { $global:facets += $facet }
            Refresh-FacetList
        })

    # Remove Facet event
    $removeFacetBtn.Add_Click({
            $idx = $addedFacetsList.SelectedIndex
            if ($idx -ge 0) {
                $global:facets = $global:facets[0..($idx - 1)] + $global:facets[($idx + 1)..($global:facets.Count - 1)]
                Refresh-FacetList
            }
        })

    # Edit Facet event
    $editFacetBtn.Add_Click({
            $idx = $addedFacetsList.SelectedIndex
            if ($idx -ge 0) {
                $facet = $global:facets[$idx]
                $type = $facet.features[0].'$type' -replace 'app.bsky.richtext.facet#', ''
                switch ($type) {
                    'mention' {
                        $mentionTextBox.Text = $postBox.Text.Substring($facet.index.byteStart, $facet.index.byteEnd - $facet.index.byteStart)
                        $mentionDidBox.Text = $facet.features[0].did
                    }
                    'tag' {
                        $tagTextBox.Text = $postBox.Text.Substring($facet.index.byteStart, $facet.index.byteEnd - $facet.index.byteStart)
                        $tagNameBox.Text = $facet.features[0].tag
                    }
                    'link' {
                        $linkTextBox.Text = $postBox.Text.Substring($facet.index.byteStart, $facet.index.byteEnd - $facet.index.byteStart)
                        $linkUriBox.Text = $facet.features[0].uri
                    }
                }
                # Remove the facet so user can re-add after editing
                $global:facets = $global:facets[0..($idx - 1)] + $global:facets[($idx + 1)..($global:facets.Count - 1)]
                Refresh-FacetList
            }
        })

    # Preview area
    $previewLabel = New-Object Windows.Controls.TextBlock
    $previewLabel.Text = 'Preview:'
    $stack.Children.Add($previewLabel)
    $previewBox = New-Object Windows.Controls.TextBox
    $previewBox.Height = 100
    $previewBox.IsReadOnly = $true
    $previewBox.TextWrapping = 'Wrap'
    $previewBox.Margin = '0,0,0,10'
    $stack.Children.Add($previewBox)

    # Buttons
    $btnPanel = New-Object Windows.Controls.StackPanel
    $btnPanel.Orientation = 'Horizontal'
    $stack.Children.Add($btnPanel)

    $previewBtn = New-Object Windows.Controls.Button
    $previewBtn.Content = 'Preview'
    $btnPanel.Children.Add($previewBtn)
    $postBtn = New-Object Windows.Controls.Button
    $postBtn.Content = 'Post'
    $postBtn.Margin = '10,0,0,0'
    $btnPanel.Children.Add($postBtn)

    # Preview click event
    $previewBtn.Add_Click({
            $postObj = New-BskyPostObject -Text $postBox.Text -Facets $global:facets
            $previewBox.Text = Preview-BskyPost -PostObject $postObj
        })

    # Post click event
    $postBtn.Add_Click({
            [System.Windows.MessageBox]::Show('Posting not yet implemented. Use Preview for now.')
        })

    $window.ShowDialog() | Out-Null
}

Show-BskyPostGui
