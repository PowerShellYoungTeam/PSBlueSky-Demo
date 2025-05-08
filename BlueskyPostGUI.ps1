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
    $window.Height = 700
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

    # Facet management (simple for now)
    $facetLabel = New-Object Windows.Controls.TextBlock
    $facetLabel.Text = 'Facets (mention/tag/link):'
    $stack.Children.Add($facetLabel)
    $facetBox = New-Object Windows.Controls.TextBox
    $facetBox.ToolTip = 'Describe facets here or use future facet GUI'
    $facetBox.Margin = '0,0,0,10'
    $stack.Children.Add($facetBox)

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
            $facets = @() # TODO: Parse $facetBox.Text into facet objects
            $postObj = New-BskyPostObject -Text $postBox.Text -Facets $facets
            $previewBox.Text = Preview-BskyPost -PostObject $postObj
        })

    # Post click event
    $postBtn.Add_Click({
            [System.Windows.MessageBox]::Show('Posting not yet implemented. Use Preview for now.')
        })

    $window.ShowDialog() | Out-Null
}

Show-BskyPostGui
