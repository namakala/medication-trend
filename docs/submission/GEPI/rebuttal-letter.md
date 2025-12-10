---
format: pdf
var:
  date: "10 December 2025"
  journal: "Global Epidemiology"
  editor: "Assoc. Prof. Igor Burstyn, PhD"
  greeting: "Professor Igor Burstyn"
  manuscript-id: "GEPI-D-25-00113"
in-header: >
  \usepackage{amsmath}
  \usepackage{amssymb}
---

\pagenumbering{gobble}

Aly Lamuri  
University of Groningen  

{{< meta var.editor >}}  
{{< meta var.journal >}}  

{{< meta var.date >}}  

**Dear {{< meta var.greeting >}},**

Thank you for the opportunity to revise and resubmit our original research article entitled *"A temporal network analysis of drug co-prescription during antidepressants and anxiolytics dispensing in the Netherlands from 2018 to 2022"* (Manuscript ID: **{{< meta var.manuscript-id >}}**). We would like to express our gratitude for the reviewers for their constructive feedback, which has been important in enhancing the quality of our manuscript. Attached, please find detailed responses to each comment. All revisions in the manuscript are highlighted and noted by page and line numbers.

Yours sincerely,

\vspace{3em}

Aly Lamuri, PhD Candidate  

**On behalf of other co-authors:**  
Spyros Balafas  
Eelko Hak  
Jens H. Bos  
Frederike Jörg  
Talitha L. Feenstra  

\pagebreak

We thank both reviewers for their constructive feedback.

## Reviewer 1

**Comment 1:**  
The study was performed based on a pharmacy database. The authors should introduce more details about the prescription behavior of local patients. for example, the main route of obtaining drugs, hospital or pharmacy?

**Response:**  
We appreciate the reviewer’s suggestion to clarify prescription behaviors in our study context. The primary route of medication dispensing in our setting is through community pharmacies based on physician's prescriptions. Community pharmacy dispensings constitute the main data source for this study. The database does not include records of in-hospital medication dispensing or over-the-counter (OTC) medications. We have added these details to the section 2.1 (paragraph 1) to provide better context regarding the data source and patient prescription behavior.

**Changes in the manuscript:**  

> All data in this study originated from the University of Groningen IADB.nl, a dynamic pharmacy database containing prescription records since 1994. The database covers approximately 128 community pharmacies serving over one million patients and was accessed on the 20^th^ of September 2023. In the Netherlands, the primary route of obtaining prescription medications is through community pharmacies, as physicians issue prescriptions that are almost exclusively dispensed in these settings. Consequently, the database provides a comprehensive longitudinal record for each individual, supported by high patient-pharmacy commitment. All patients are recorded in the database, irrespective of health care insurance, where the prescription rates, age, and gender are generalizable to represent the Netherlands. Each record includes the dispensing date, quantity, dose regimen, number of days prescribed, prescribing physician, and the corresponding Anatomical Therapeutic Chemical (ATC) code. Medication dispensed during hospitalization and over-the-counter drugs are not captured, but prescription medication records in community pharmacies are otherwise complete.

**Comment 2:**  
Was the full information of database used? Or only part? This should be specified in the methods.

**Response:**  
We agree this could be clarified. Only a subset of the database was used for this analysis. Specifically, we extracted anonymized patient identifiers, prescription start and end dates, and ATC codes. Other individual-level variables that are not required to build DPN were not requested to satisfy data minimization requirements. We have now clarified this in section 2.1 (paragraph 2) of the revised manuscript.

**Changes in the manuscript:**  

> This analysis includes daily drug administration from a static cohort of adults aged 18 to 65 years and prescribed anxiolytics or antidepressants at least once in the period 2018-2022. For this study, only a subset of the database was used to construct the DPN: anonymized patient identifiers, age, prescription start and end dates, and ATC codes. No additional individual-level data were included to align general data minimization requirements. Other demographic or clinical information available in the database was not extracted.

**Comment 3:**  
The expected $C_e$ should be provided, or no comparison can be made.

**Response:**  
We thank the reviewer for requesting this clarification. The expected $C_e$ value was implicitly represented as $\frac{1}{n}$, where $n$ denotes the total number of medication classes. In our case, $n$ = 24, and therefore the expected $C_e$ equals $\frac{1}{24}$. We have now explicitly stated this in the section 2.5.5 to ensure clarity and facilitate comparison.

**Changes in the manuscript:**  

> Since the sum of all eigenvector centralities $c_i$ in equation 5 equals 1, the expected eigenvector centrality $C_e$ for each node in a uniformly connected network is $\frac{1}{n}$, where $n$ is 24, representing the total number of nodes. In such a network, each node has an equal probability of being connected to any other, and thus no node is more "influential" than another. This expected value, $\frac{1}{24}$, serves as a baseline under a null model of uniform connectivity. Assuming eigenvector centrality scores approximately follow a normal distribution, we applied a one-sample Student's T-test with Bonferroni correction to assess how much each eigenvector centrality differs from the expected values. Nodes with $c_i$ greater than $\frac{1}{24}$ were categorized as having high eigenvector centrality, and those below the expected value were considered low.

**Comment 4:**  
There was COVID 19 epidemic in 2020. Would this influence the dispensing volume?

**Response:**  
We appreciate the reviewer’s thoughtful question. Based on our data, the COVID-19 pandemic did not substantially affect the overall dispensing volume. The total number of prescriptions for all medication classes remained relatively stable across the study period: 2018 – 2,215,195; 2019 – 2,279,405; 2020 – 2,279,204; 2021 – 2,224,839; and 2022 – 2,151,496. These figures indicate no significant deviation in dispensing trends for all medications during 2020. We have added this information to section 3.1 for completeness and explain this is as expected, since pharmacies stayed operational during the pandemic.

**Changes in the manuscript:**  

> IADB recorded 149,071 patients with at least one dispensing of antidepressants or anxiolytics within five years of data extraction. Table 1 captures the demographical dynamics of the population from 2018 to 2022. The ratio of male to female only varied slightly, and the average age steadily increased over the year. These findings imply that the population demography stays relatively stable overtime without any indication of sudden changes. Importantly, the COVID-19 pandemic in 2020 did not substantially influence dispensing volumes because the community pharmacy remained in service as a part of nationwide policy. There was no significant disruption in prescription trends during and after the pandemic, with an average of 2,230,028 in annual dispensing for all medication classes (SD: 47,478, IQR: 64,009).

**Comment 5:**  
Figure 1. more detailed caption should be provided to better read the figure.

**Response:**  
Thank you for this suggestion. We have revised and expanded the Figure 1 caption to provide clearer descriptions of the figure elements and to facilitate interpretation. The updated caption now reads as follows:

**Changes in the manuscript:**  

> Figure 1. Singular spectrum analysis (SSA)-based decomposition of antidepressant dispensing volumes 2018-2022. The SSA separates the original time-series into the overall trend, residuals, and 25 oscillatory components (F1-F25). The green line represents the reconstructed time-series using the trend component along with the first two oscillatory functions (F1 and F2), highlighting the primary pattern in dispensing over time.

**Comment 6:**  
Figure 2. What does the vertical dash line represent?

**Response:**  
Indeed this has to be clarified. The vertical dashed line in Figure 2 represents the expected $C_e$ value, which equals $\frac{1}{24}$ in our analysis (corresponding to the total of 24 medication classes). We have clarified this in the figure caption in the revised manuscript.

**Changes in the manuscript:**  

> Figure 2. Clusters of medications showing significant co-prescription patterns for antidepressnts and anxiolytics. The vertical dashed line indicates the expected eigenvector centrality, calculated as 1/24. This line provides a reference for identifying medication classes with eigenvector centrality exceeding the threshold. 

# Reviewer 2

**Comment 1:**  
Age-stratified analysis (e.g., $< 65$ vs. $\geq 65$ years) Older adults tend to have more comorbidities and are therefore at higher risk of polypharmacy. Conducting a subgroup analysis based on age—such as $<65$ vs. $\geq 65$ years—could provide further clinical insight. Comparing DPN structures across age strata might reveal different co-prescription dynamics within high-risk populations.

Consider defining a polypharmacy subgroup prior to DPN analysis In many epidemiological and clinical studies, polypharmacy has been defined as the concurrent use of five or more medications for at least 30 days. Identifying a subgroup based on such a definition and then applying DPN analysis specifically to that cohort might help elucidate drug-drug association patterns in a clinically significant context.

**Response:**  
We thank the reviewer for these valuable suggestions regarding subgroup analyses. We agree that both age-stratified and polypharmacy-based subgroup analyses are important for understanding differential co-prescription patterns among high-risk populations. As described in Section 2.5.6 of the Methods and reported in Section 3.5 (paragraph 2 and 3), we conducted the additional  subgroup analyses that were feasible within the constraints of our dataset and study design. These results have been added to the  revised manuscript and inform on age and polypharmacy specific results.

**Changes in the manuscript:**  

- Section 2.5.6:  

  > Subgroup analyses were conducted by first categorizing the population into two age groups: $< 65$ and $\geq 65$ years. The second categorization was based on general polypharmacy, defined a receiving $\geq 5$ medications for at least 30 consecutive days. These subgroup classifications were combined to form three comparison pairs: $< 65$ vs. $\geq 65$ years; non-polypharmacy vs. polypharmacy; and the non-polypharmacy group aged $< 65$ years vs. the polypharmacy group aged $\geq 65$ years. A DPN was generated for each subgroup to calculate its respective eigenvector centrality.

- Section 3.5, paragraph 2 and 3:  

  > The distribution of eigenvector centralities exhibited a central peak at intermediate values and heavy tails at both extremes, reflecting the temporal fluctuations of node influence. This pattern arose from the recursive nature of eigenvector centrality, where each node's importance depends on the importance of its neighbors. Aggregating centrality value over time captures the evolving dynamics of the network, where nodes occasionally attain a relatively higher or lower centrality. In contrast, the width of the distribution remained relatively stable, indicating that many co-prescription connections persisted consistently over time.
  > 
  > The eigenvector centrality patterns shown in Figure 2 also highlight the distribution of several subgroups, each distinguished by color. Most subgroup distribution largely overlapped with the general population, represented by the gray density curves. However, two subgroups consistently diverged from this overall pattern: the polypharmacy group and the subset of polypharmacy patiens aged $\geq 65$ years. These subgroups exhibited higher eigenvector centralities across four medication classes, demonstrating a more tightly connected co-prescription patterns within these groups. In addition, the $\geq 65$ years subgroup showed elevated eigenvector centralities in three medication classes, although its magnitude was smaller than that observed in the broader polypharmacy population.

**Comment 2:**  
Abbreviations used in tables and figures (e.g., SD, IQR, ACF, PACF) should be fully spelled out at first use or included in the respective footnotes.

**Response:**  
All abbreviations have now been fully spelled out at first use in the main text, tables, figures, and the supplementary material to ensure clarity for readers.

**Changes in the supplementary:**  

> Exploration on seasonality was done on detrended daily and weekly data by generating seasonal plots and calculating the autocorrelation (ACF) and partial autocorrelation function (PACF). Seasonal plots were generated for weekly and yearly pattern by using daily and weekly data, respectively.  To generate the seasonal plots, the data was first deconstructed based on its period. For daily data, the weekly period was used; while for monthly data, the yearly period was used. The weekly period was obtained by creating an ordered value formatted as year - week, e.g. `2018 - W01`. Similarly, monthly period was obtained by creating an ordered value formatted as year - month, e.g. `2018 - M01`. We then grouped the series by its deconstructed period and visually examine seasonality as overlapping pattern in most periods. To substantiate the findings, ACF and PACF plots were used to check on statistical significance of a given pattern.
