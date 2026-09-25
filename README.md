# LTER SPARC Group: Material Legacy Effects

Principal Investigators: _Dr. Kai L. Kopecky, Dr. Katharine N. Suding, Dr. Ty A. Tuff, Dr. Max Castorani_

## Workflow Explanation

1. `00_download.r` -- Downloads raw data from the [Environmental Data Initiative](https://edirepository.org/) (EDI)
    - To make this work, you'll need to get an Access Key from EDI.For instructions, see either [this video](https://youtu.be/fieZSmHk2H4?si=Wo9a5GsAOYp3dnWS) or [this website](https://auth.edirepository.org)
2. `01_standardize/` -- Does site-specific wrangling to generate analysis-ready data
3. `02_make-table.r` -- Makes cross-site table for data paper

### EDI Access Key Housekeeping

Once you have an EDI Access Key, it will be easiest if you make a file that starts with "secret" (e.g., "secret_my-edi-key.md") and copy/paste the key from that file into the "Console" of your IDE when the download script interactively prompt you to do so.

**DO NOT COMMIT THIS "SECRET" FILE!** All files beginning with "secret" have been preemptively added to this repository's `.gitignore` but if you name it something else, you'll be at risk of committing it which would be bad.
