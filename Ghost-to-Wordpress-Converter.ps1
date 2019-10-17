param (
    [string]$jsonFile
)

function convertJSON() {
    $json_data = Get-Content -Encoding UTF8 -Raw -Path $jsonFile | ConvertFrom-Json

    $csv_file = "${jsonFile}.csv"
    if (Test-Path $csv_file) {
        Remove-Item $csv_file -Force -ErrorAction Continue
    }

    $post_to_tag_mapping = $json_data.db[0].data.posts_tags
    $tag_mapping = $json_data.db[0].data.tags

    ForEach($post in $json_data.db[0].data.posts) {
        if ($post.page -ne 1) {
            # Gather tags for this post, if it is not a page
            $tag_mapping_for_this_post = $post_to_tag_mapping | Where-Object {$_.post_id -eq $post.id}
            $tags_for_this_post = $tag_mapping | Where-Object {$_.id -eq $tag_mapping_for_this_post.tag_id}

            <# 
                Add tags to this post's info; I only had posts with single tags to check this against.
                Posts with multiple tags might have an array of tags.
            #>
            $post | Add-Member -NotePropertyName "tags" -NotePropertyValue $tags_for_this_post.Name
        }

        $post | Select-Object id,title,slug,html,published_at,custom_excerpt,feature_image,tags,page | Export-Csv $csv_file -Append -NoTypeInformation -Force -Encoding UTF8
    }

    write-host "Finished! Csv file created: ${csv_file}"
}

if (($jsonFile -ne "") -and (Test-Path $jsonFile)) {
    write-host "Beginning conversion upon file ${jsonFile}..."
    convertJSON
} 
else {
    write-host "Usage: <script name> <json file path>"
}