---
format: pdf
var:
  date: "15 December 2025"
  journal: "Global Epidemiology"
  editor: "Assoc. Prof. Igor Burstyn, PhD"
  greeting: "Professor Igor Burstyn"
  manuscript-id: "GEPI-D-25-00113"
in-header: >
  \usepackage{amsmath}
  \usepackage{amssymb}
---

\pagenumbering{gobble}

We thank reviewer 2 for their constructive feedback.

## Reviewer 2

**Comment 1:**  
In the Supplementary Methods, please ensure consistency in the description of the temporal resolutions and periods used. Specifically, the sentence "Seasonal plots were generated for weekly and yearly patterns using daily and weekly data, respectively" is appropriate, but later references to "monthly data" appear inconsistent with the earlier description and may be typographical errors. Please clarify whether "weekly data" was intended instead of "monthly data."

**Response:**  
We thank the reviewer for carefully identifying this inconsistency. The references to “monthly data” were indeed typographical errors. We have clarified in the revised text that weekly data were used throughout the analysis. These corrections have been made in the supplementary file also Sections 2.5.1 and 2.5.2 of the manuscript to ensure consistency and clarity.

**Changes in the manuscript (section 2.5.1):**  

> The data was extracted as a daily time series and aggregated into weekly intervals for analysis. It includes four metrics: daily prescription dispensing, daily patients, dispensing-to-patient ratio, and eigenvector centrality. For each metric, a univariate descriptive analysis was performed, reporting the mean, median, standard deviation, and interquartile range to summarize centrality and dispersion.

**Changes in the manuscript (section 2.5.2 and supplementary file):**  

> Exploration on seasonality was done on detrended daily and weekly data by generating seasonal plots and calculating the autocorrelation (ACF) and partial autocorrelation function (PACF). Seasonal plots were generated for weekly and yearly pattern by using daily and weekly data, respectively.  To generate the seasonal plots, the data was first deconstructed based on its period. For daily data, the weekly period was used; while for weekly data, the yearly period was used. The weekly period was obtained by creating an ordered value formatted as year - week, e.g. `2018 - W01`, whereas the yearly period was an order from 2018 to 2022. We then grouped the series by its deconstructed period and visually examine seasonality as overlapping pattern in most periods. To substantiate the findings, ACF and PACF plots were used to check on statistical significance of a given pattern.

**Comment 2:**  
A few minor typographical and grammatical issues remain (e.g., "defined a receiving" instead of "defined as receiving," "patiens" instead of "patients").

**Response:**  
All identified typographical and grammatical errors have now been corrected throughout the manuscript. The corresponding revisions are reflected in Sections 2.4, 2.5.3, 2.5.6, 3.1, and 3.4 of the revised version.

**Changes in the manuscript:**  

- Section 2.4: ... This study focused on eigenvector centrality to evaluate which medications ...
- Section 2.5.3: Therefore, this study only focused ...
- Section 3.1: ... There was no clear change in prescription trends ...
- Section 3.4: ... These decomposed trends provided the reconstructed data for the subsequent analysis.