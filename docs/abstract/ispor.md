# Eigenvector centrality as a metric of polypharmacy signifies
antidepressants as a central hub of the psychopharmaca co-prescription
network

Aly Lamuri, Frederike Jörg, Eelko Hak, Jens H. Bos, Talitha L. Feenstra

**Background:** Mental health disorders are prevalent comorbidities
affecting nearly two billion people worldwide. People with chronic
diseases are at a higher risk of having mental health issues, which in
turn potentially worsen their overall well-being.

**Objectives:**  
Evaluate the interrelatedness of mental health problems with other
diagnoses, reflected as an importance score of medication uses relative
to other medications recorded in a medication claim registry.

**Methods:** Exploratory time-series analysis was performed using the
University of Groningen prescription database, IADB.nl. A static cohort
with at least one prescription of psychopharmaca from 2018 to 2022 was
extracted. The prescription was evaluated daily using anatomical
therapeutic chemical (ATC) classification, where psychopharmaca was
evaluated at ATC level 3, drugs for the nervous system at ATC level 2,
and other medications at ATC level 1, distinguished into a total of 24
medication classes. A drug prescription network was constructed as an
undirected graph to capture dose-adjusted co-prescription. Eigenvector
centrality ($c_e$) was computed as a measure of relative nodal
importance, which reflects the degree of medication concurrence in a
network. The number of medication claims ($n_c$), number of patients,
claim-to-patient ratio, and eigenvector centrality were extracted as
weekly-aggregated time-series data. Singular spectrum analysis was
performed to decompose the data into its constituting trend,
periodicity, and white noises.

**Results:** Antidepressants (ATC `N06A`, $c_e$: 0.11, $n_c$: 28,993),
antipsychotics (`N05A`, $c_e$: 0.07, $n_c$: 14,027), and anxiolytics
(`N05B`, $c_e$: 0.08, $n_c$: 14,061) are psychopharmaca with high
eigenvector centrality. These classes of medication are likely to be
co-prescribed alongside other medications. Further groups with high
eigenvector centrality were medications for alimentary and metabolism
(`A01-A16`, $c_e$: 0.15, $n_c$: 53,602), blood (`B01-B06`, $c_e$: 0.06,
$n_c$: 13,310), cardiovascular (`C01-C10`, $c_e$: 0.14, $n_c$: 44,802),
analgesics (`N02`, $c_e$: 0.09, $n_c$: 13,847), and respiratory
(`R01-R07`, $c_e$: 0.09, $n_c$: 25,034). Among eight medications with
high eigenvector centrality, only antidepressants had a positive time
trend for both eigenvector centrality and actual number of claims.

**Discussion:** Eight medications, three of which are psychopharmaca,
have a high eigenvector centrality, implying its concurrence on a
population level. Positive time trends in both eigenvector centrality
and claims suggest that increasing uses of antidepressants are related
to co-prescription with other medication classes. Constructing a
medication claim network enriches the exploratory analysis of medication
use at the population level.
