# A temporal network analysis of drug co-prescription around
antidepressants and anxiolytics uses

Aly Lamuri, Spyros Balafas, Eelko Hak, Jens H. Bos, Frederike
Jörg, Talitha L. Feenstra

**Background:** Networks have been used in different scientific fields
to model complex systems. In medicine and epidemiology, drug
prescription networks (DPN) have been proposed as a modeling tool for
studying the temporal dynamics of medication co-prescription within a
population.

**Objectives:**  
This study aims to assess the structural characteristics of temporal
DPNs, derived from daily co-prescriptions between treatments for mental
health conditions and other therapeutic drug classes, as recorded in
pharmacy dispensing database.

**Methods:** For exploratory time series analysis, and network
construction, we utilized the IADB.nl database that collects
prescriptions from 128 pharmacies in the Netherlands. A closed cohort
with at least one prescription of anxiolytics/antidepressants dispensed
anywhere from 2018 to 2022 was extracted. The drug prescription was
evaluated daily using anatomical therapeutic chemical (ATC)
classification, where psychopharmaca was evaluated at ATC level 4, drugs
for the nervous system at ATC level 3, and other medications at ATC
level 1, distinguished into a total of 24 therapeutic medication
classes. Symmetric daily dose-adjusted co-prescriptions were used to
construct time-varying DPNs as undirected graphs. Subsequently,
eigenvector centrality ($c_e$) was computed as a measure of relative
nodal importance, which reflects the degree of medication concurrence in
a network. The number of prescriptions ($n_c$), number of patients,
claim-to-patient ratio, and eigenvector centrality were extracted as
weekly-aggregated time-series data. Singular spectrum analysis was
performed to decompose the data into its constituting trend, harmonics,
and noise components.

**Results:** Antidepressants (ATC `N06A`, $c_e$: 0.09, $n_c$: 28,993)
and anxiolytics (`N05B`, $c_e$: 0.05, $n_c$: 14,061) are psychopharmaca
with high eigenvector centrality. These classes of medication are likely
to be co-prescribed apart from other medications. Further groups with
high eigenvector centrality were medications for alimentary and
metabolism (`A01-A16`, $c_e$: 0.16, $n_c$: 53,602), blood (`B01-B06`,
$c_e$: 0.09, $n_c$: 13,310), cardiovascular (`C01-C10`, $c_e$: 0.15,
$n_c$: 44,802), analgesics (`N02`, $c_e$: 0.06, $n_c$: 13,847), and
respiratory (`R01-R07`, $c_e$: 0.1, $n_c$: 25,034). Among the seven
medication groups with high eigenvector centrality, only antidepressants
showed a positive time trend for both eigenvector centrality and actual
number of claims.

**Discussion:** Seven medication therapy classes, three of which are
psychopharmaca, had a high eigenvector centrality, indicating
concurrence with other medication groups on a population level in the
group of antidepressant or anxiolytic users. Positive time trends in
both eigenvector centrality and dispensing suggest that increasing uses
of antidepressants was related to co-prescription with other medication
classes. Constructing a prescription network enriches the exploratory
analysis of medication use at the population level.
