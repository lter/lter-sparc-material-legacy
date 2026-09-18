# # Load in data and filter for observations wiht Study ID 'OHJA'
# hja.downed_wood <- read_csv("Data/Andrews Forest/Coarse woody debris/TD01204.csv") %>%
#   clean_names() %>%
#   filter(studyid == "OHJA")

# # Summarize deadwood metrics by plot
# hja.downed_wood.summary <- hja.downed_wood %>%
#   group_by(stand, plot, year) %>%
#   summarize(total_volume = sum(wvol),
#             total_mass = sum(wmass),
#             total_cover = sum(pcover),
#             total_area = sum(surfarea))

# write_csv(hja.downed_wood.summary, "Data/Andrews Forest/Coarse woody debris/OHJA_downed wood summary.csv")

# [KK]: my code here produces "OHJA_downed wood summary.csv", but it looks like there was a modification to this by Dave (maybe just in excel?) that resulted in second version called "OHJA_downed wood summary_v2.csv...Dave explained it like this:".

# [DB]: One other point, I had to collapse a few stands into a single stand/plot due to some oddities in our database structure. 
# [DB]: Specifically, these were RS04, RS05, RS07, RS08, RS10, RS12, RS14, RS15, RS16, RS18.

