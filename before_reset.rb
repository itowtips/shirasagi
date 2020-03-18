# dump translate text caches
system("mongodump --db ss -c=translate_text_caches --out translate_text_caches")

# dump translate site settings
system("mongoexport --db ss -c=ss_sites --out ss_sites.json --jsonArray")
