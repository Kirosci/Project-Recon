read domain
dir=$(head -1 $domain)
cd $dir || exit 1


ip=$(dig +short $domain)

asn=$(whois -h whois.cymru.com "-v $ip" | sed -n '3p' | awk '{print "AS" $1}')

