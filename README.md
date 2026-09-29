# Life After Death: A Harmonized Dataset of Live and Dead Foundation Species Across Marine and Terrestrial Ecosystems

![Paper DOI](https://img.shields.io/badge/Paper%20TBD-green.svg) [![Code DOI](https://img.shields.io/badge/Code%20DOI-10.5281/zenodo.23023582-orange.svg)](https://doi.org/10.5281/zenodo.23023582) ![Data DOI](https://img.shields.io/badge/Data%20TBD-blue.svg)

[Kai L. Kopecky](https://orcid.org/0000-0002-0021-3087), [Nicholas J. Lyon](https://orcid.org/0000-0003-3905-1078), [Audrey Barker Plotkin](https://orcid.org/0000-0002-4473-9785), [David M. Bell](https://orcid.org/0000-0002-2673-5836), [Max C. N. Castorani](https://orcid.org/0000-0002-7372-9359), [David Huang](https://orcid.org/0009-0004-1846-0088), [Jill F. Johnstone](https://orcid.org/0000-0001-6131-9339), [John S. Kominoski](https://orcid.org/0000-0002-0978-3326), [Jesse B. Nippert](https://orcid.org/0000-0002-7939-342X), [Christopher J. Nytch](https://orcid.org/0000-0003-1181-2250), [Steven C. Pennings](https://orcid.org/0000-0003-4757-7125), [Daniel C. Reed](https://orcid.org/0000-0003-3015-8717), [Aaron B. Shiels](https://orcid.org/0000-0002-6774-4560), [Ty Tuff](https://orcid.org/0000-0001-5249-5197), [Katharine N. Suding](https://orcid.org/0000-0002-5357-0176)

## Workflow Explanation

1. `00_download.r` -- Downloads raw data from the [Environmental Data Initiative](https://edirepository.org/) (EDI)
    - To make this work, you'll need to get an Access Key from EDI.For instructions, see either [this video](https://youtu.be/fieZSmHk2H4?si=Wo9a5GsAOYp3dnWS) or [this website](https://auth.edirepository.org)
2. `01_standardize.r` -- Does site-specific wrangling to generate analysis-ready data
    - Actual wrangling code for each site is in the eponymous scripts in the `01_standardize/` _folder_
3. `02_make-table.r` -- Makes cross-site table for data paper

### EDI Access Key Housekeeping

Once you have an EDI Access Key, it will be easiest if you make a file that starts with "secret" (e.g., "secret_my-edi-key.md") and copy/paste the key from that file into the "Console" of your IDE when the download script interactively prompt you to do so.

**DO NOT COMMIT THIS "SECRET" FILE!** All files beginning with "secret" have been preemptively added to this repository's `.gitignore` but if you name it something else, you'll be at risk of committing it which would be bad.

### Supplementary Info

For more information on this working group, see [our page](https://lternet.edu/working-groups/life-after-death-how-legacies-of-dead-foundation-species-influence-ecological-processes-across-marine-and-terrestrial-ecosystems/) on the LTER Network website.
