#!/bin/bash

# ==== (INFO)

# This script gathers urls for all subdomains of the provided targets.

# Variables imported from "consts/commonVariables.sh" (These variables are common in several scripts)
# - $UrlResults
# - $SubdomainResults
# - $baseDir
# - $jsUrls
# ==== (INFO)(END)



# ===============================
# ===============================



# --- (INIT)

# File containing domains to enumerate subdomains for
domainFile=$1

# Importing file responsbile for, decorated ouput.
source consts/functions.sh
# Importing file responsible for, holding variables common in several scripts
source consts/commonVariables.sh


# Filenames to save results of url enumeration

    # Passive enumeration
        waybackurls_Passive_UrlResults='waybackurls.txt'
        gau_Passive_UrlResults='gau.txt'
        waymore_Passive_UrlResults='waymore.txt'
    
    # Active enumeration
        katana_Active_UrlResults='katana.txt'
        hakrawler_Active_UrlResults='hakrawler.txt'
    
    # Organise
        urlsArranged='urlsArranged.txt'

# Temporary path to save tempoprary subdomains enumeration files (In real it is permanent, I mean it doesn't gets removed)

    temp_UrlResults_Path='.tmp/urls'

# --- (INIT)(END)



# ===============================
# ===============================



# --- (Passive URL gathering)

passive() {
    (
        # if [ -f "${temp_UrlResults_Path}/${waybackurls_Passive_UrlResults}" ]; then
        #     print_message "$GREEN" "Waybackurls results are already there: $(cat "${temp_UrlResults_Path}/${waybackurls_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # else
            # cp ${SubdomainResults} temp_subdomains_wayback.txt && 
            cat ${SubdomainResults} | waybackurls > ${waybackurls_Passive_UrlResults} 2> /dev/null

            print_message "$GREEN" "Waybackurls: $(cat "${waybackurls_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # fi
    ) &
    (
        # if [ -f "${temp_UrlResults_Path}/${gau_Passive_UrlResults}" ]; then
        #     print_message "$GREEN" "Gau results are already there: $(cat "${temp_UrlResults_Path}/${gau_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # else
            # cp ${SubdomainResults} temp_subdomains_gau.txt && 
            cat ${SubdomainResults} | gau > ${gau_Passive_UrlResults} 2> /dev/null

            print_message "$GREEN" "Gau: $(cat "${gau_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # fi
    ) &
    (
        # if [ -f "${temp_UrlResults_Path}/${waymore_Passive_UrlResults}" ]; then
        #     print_message "$GREEN" "Waymore results are already there: $(cat "${temp_UrlResults_Path}/${waymore_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # else
            # cp ${SubdomainResults} temp_subdomains_waymore.txt && 
            cat ${domainFile} | sed 's/^/https:\/\//' > ${tempFile}
            waymore -n -xwm -urlr 0 -r 2 -i ${tempFile} -mode U -oU ${waymore_Passive_UrlResults} 2> /dev/null 1> /dev/null
            rm ${tempFile} 2> /dev/null
            print_message "$GREEN" "Waymore: $(cat "${waymore_Passive_UrlResults}" 2> /dev/null | wc -l)"
        # fi
    ) &
    
    wait

    # rm temp_subdomains_wayback.txt temp_subdomains_gau.txt temp_subdomains_waymore.txt 2> /dev/null
}

# --- (Passive URL gathering)(END)



# ===============================
# ===============================



# --- (Active URL gathering)

active() {
    (
        # if [ -f "${temp_UrlResults_Path}/${katana_Active_UrlResults}" ]; then
        #     print_message "$GREEN" "Katana results are already there: $(cat "${temp_UrlResults_Path}/${katana_Active_UrlResults}" 2> /dev/null | wc -l)"
        # else
            katana -u ${SubdomainResults} -o ${katana_Active_UrlResults} -silent -hl -nc -d 5 -aff -retry 2 -iqp -c 20 -p 20 -xhr -jc -kf -ef css,jpg,jpeg,png,svg,img,gif,mp4,flv,ogv,webm,webp,mov,mp3,m4a,m4p,scss,tif,tiff,ttf,otf,woff,woff2,bmp,ico,eot,htc,rtf,swf,image 1> /dev/null

            print_message "$GREEN" "Katana: $(cat "${katana_Active_UrlResults}" 2> /dev/null | wc -l)"
        # fi
    ) &

    (
        # if [ -f "${temp_UrlResults_Path}/${hakrawler_Active_UrlResults}" ]; then
        #     print_message "$GREEN" "Hakrawler results are already there: $(cat "${temp_UrlResults_Path}/${hakrawler_Active_UrlResults}" 2> /dev/null | wc -l)"
        # else
            cat ${SubdomainResults} | hakrawler -d 5 -insecure -subs -t 40 > ${hakrawler_Active_UrlResults} 2> /dev/null

            print_message "$GREEN" "Hakrawler: $(cat "${hakrawler_Active_UrlResults}" 2> /dev/null | wc -l)"
        # fi
    ) & 
    
    wait

}

# --- (Active URL gathering)(END)



# ===============================
# ===============================



# --- (Funtion to organise mess)

organise(){

    # Sorting and combining results
    print_message "$GREEN" "Organising collected urls"
    cat ${waybackurls_Passive_UrlResults} ${gau_Passive_UrlResults} ${waymore_Passive_UrlResults} ${katana_Active_UrlResults} ${hakrawler_Active_UrlResults} 2> /dev/null | sort -u >> ${UrlResults}

    # Appending results from previous scan if present (previous scan results are stored in temporary directory) 
    cat ${temp_UrlResults_Path}/${waybackurls_Passive_UrlResults} ${temp_UrlResults_Path}/${gau_Passive_UrlResults} ${temp_UrlResults_Path}/${waymore_Passive_UrlResults} ${temp_UrlResults_Path}/${katana_Active_UrlResults} ${temp_UrlResults_Path}/${hakrawler_Active_UrlResults} 2> /dev/null | sort -u >> ${UrlResults}

    # Sorting results again
    sort -u ${UrlResults} -o ${UrlResults} 1> /dev/null
    
    # Separating Js and json urls
    cat ${UrlResults} | grep -F .js | cut -d "?" -f 1 | sort -u >> ${jsUrls} 1> /dev/null

    # Moving unnecessary to temporary directory
    mv ${waybackurls_Passive_UrlResults} ${gau_Passive_UrlResults} ${waymore_Passive_UrlResults} ${katana_Active_UrlResults} ${hakrawler_Active_UrlResults} ${tempFile} ${temp_UrlResults_Path} 2> /dev/null
    
# Arranging urls according to their extensions
    # Array of file extensions to search for
    extensions=("~" "7z" "ace" "action" "aliases" "arc" "arj" "asc" "aws/config" "aws/credentials" "babelrc" "backup" "bak" "bas" "bash" "bash_profile" "bashrc" "bat" "bin" "bk" "bkp" "blade" "build" "buildignore" "buildpath" "bz" "bz2" "bzrconfig" "bzrignore" "c" "c++" "c$" "cab" "cache" "cc" "cer" "cfg" "cfignore" "cgi" "circleci" "class" "cls" "cnf" "commitlintrc" "conf" "config" "cpio" "cpp" "cpp$" "cred" "credentials" "crt" "cs" "cs^" "csh" "csr" "csv" "csvignore" "ctl" "ctp" "cxx" "dat" "data" "db" "db3" "deb" "der" "dir" "dist" "dll" "dmg" "dmp" "do" "dob" "docker" "docker-compose.yaml" "docker-compose.yml" "dockerfile" "dockerignore" "dockerrc" "docx" "DS_Store" "ear" "editorconfig" "ejs" "ejs^" "eml" "env" "env.development" "env.local" "env.production" "env.test" "erb" "eslintignore" "eslintrc" "exe" "factories" "fish" "freemarker" "frm" "ftl" "functions" "git" "gitattributes" "gitignore" "gitmodules" "go" "gpg" "gradle" "gz" "h" "h++" "haml" "handlebars" "hbs" "helmfile" "helmignore" "hgignore" "hgrc" "hh" "hjson" "hqx" "htaccess" "htmllintrc" "htpasswd" "huskyrc" "hxx" "idea" "ignore" "img" "inc" "inf" "ini" "iso" "jade" "jar" "java" "jenkinsfile" "jks" "jnlp" "json5" "jsx" "kbdx" "kdb" "kdbx" "key" "keychain" "ksh" "kube/config" "lck" "ldf" "less" "lintstagedrc" "lock" "log" "lst" "lz" "lzh" "lzma" "lzo" "m2" "markdown" "markdownlint" "md" "mdf" "mdx" "mercurial-hgignore" "metadata" "mkd" "mkdown" "msg" "mustache" "mvn" "mysql" "mysql-connect" "netrc" "npmignore" "npmrc" "nrg" "nunjucks" "nz" "old" "openvpn" "orig" "ost" "out" "ova" "ovpn" "p12" "p7b" "p7c" "pak" "pea" "pem" "pfx" "pgp" "pgsql" "php3" "php4" "php5" "php7" "pid" "pkcs12" "pkg" "pl" "pm" "pom" "ppdf" "ppk" "pptx" "prefs" "prettierrc" "profile" "project" "properties" "ps1" "pst" "ptxt" "pug" "pwd" "pxml" "py" "pyc" "pyd" "pyo" "pyx" "rake" "rar" "raw" "rb" "rc" "renv" "rhtml" "ron" "rpm" "rs" "rspec" "rst" "rsx" "ru" "s7z" "sar" "sass" "save" "sea" "secrets" "settings" "sfx" "sh" "sit" "sitx" "slugignore" "sm" "smx" "sql" "sqlite" "sqlite3" "styl" "stylelintrc" "swap" "swm" "swo" "swp" "tag.gz" "tar" "tar.bz2" "tar.gz" "tar.gz.xz" "tar.xz" "tar.xz.gz" "tbz2" "tcsh" "temp" "terraformrc" "test" "tfignore" "tgz" "tlz" "tmp" "todo" "toml" "tpl" "travis.yml" "ts" "tsx" "twig" "uue" "vb" "vbproj" "vbs" "vm" "vmdk" "vs" "vscode" "vtl" "vue" "war" "watchmanconfig" "webconfig" "webinfo" "webproj" "wim" "wsgi" "xar" "xlsx" "xmi" "xsql" "xz" "yaml" "yarnrc" "yml" "Z" "zip" "zoo" "zsh" "zshrc" "txt")

    # Loop through each extension
    for ext in "${extensions[@]}"; do
        arrangedUrls=$(grep -E "\.${ext}(\?.*)?$" urls.txt)
        if [ -n "$arrangedUrls" ]; then
            echo "================(.${ext})" >> "$urlsArranged"
            echo "" >> "$urlsArranged"

            # Append each line of arrangedUrls to the file if URL is returning 200 OK
            while IFS= read -r line; do
                # Check if URL returns 200 OK
                statusCode=$(curl -o /dev/null -s -w "%{http_code}" "$line")
                if [ "$statusCode" -eq 200 ]; then
                    echo "$line" >> "$urlsArranged"
                fi
            done <<< "$arrangedUrls"

            # Add extra newlines for spacing
            echo "" >> "$urlsArranged"
            echo "" >> "$urlsArranged"
        fi
    done
    
    print_message "$GREEN" "Organising finished"
}

# --- (Funtion to organise mess)(END)



# ===============================
# ===============================



# --- (Kinda main function code)

# Used for-loop specifically, don't switch to while-loop, it was having some problems with waymore tool
for domain in $(cat "$domainFile"); do
    dir="results/$domain"
    cd "$dir"
    mkdir -p ${temp_UrlResults_Path}


    # Message main
    printf '\t%s[%s]%s\t%s' "$ORANGE" "$domain" "$RESET" "$timeDate"

    if ! [[ "$(cat ${UrlResults} 2> /dev/null |wc -l)" -eq 0 ]]; then
        print_message "$GREEN" "URL results are already there: $(cat "${UrlResults}" 2> /dev/null | wc -l)"
    else
        if [ "$2" == "passive" ]; then
            passive
            organise
        elif [ "$2" == "active" ]; then
            active
            organise
        elif [ "$2" == "both" ]; then
            passive
            active
            organise
        else
            passive
            organise
        fi
    fi
    # Message last
    printf '\t%s[Found: %s]%s\t%s' "$GREEN" "$(cat ${UrlResults} 2> /dev/null | wc -l)" "$RESET" "$timeDate"
    # Go back to base directory at last 
    cd "$baseDir"
done

# --- (Kinda main function code)(END)