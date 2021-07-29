process download_db {
    label 'download_db'
    output:
        path("*.json.gz")
    script:
    """
    wget -O genbank-k31.lca.json.gz https://osf.io/4f8n3/download
    """
}

