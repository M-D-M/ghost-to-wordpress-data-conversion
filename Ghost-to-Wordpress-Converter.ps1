param (
    [string]$jsonFile
)

function convertJSON() {
    $json_data = Get-Content -Encoding UTF8 -Raw -Path $jsonFile | ConvertFrom-Json

    $csv_file = "${jsonFile}.csv"
    Remove-Item $csv_file -Force -ErrorAction SilentlyContinue

    post_to_tag_mapping = $json_data.db[0].data.posts_tags
    tag_mapping = $json_data.db[0].data.tags

    ForEach($post in $json_data.db[0].data.posts) {
        $post | Select-Object id,title,slug,html,published_at,custom_excerpt,page | Export-Csv $csv_file -Append -NoTypeInformation -Force -Encoding UTF8
    }

    write-host "Finished! Csv file created: ${csv_file}"
}

if ($jsonFile -ne "") {
    convertJSON
} 
else {
    write-host "Usage: <script name> <json file path>"
}