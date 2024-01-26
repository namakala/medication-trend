
# Source of data

The data is obtained from [IADB](https://iadb.nl/) with a restricted
access. After obtaining the access, you may read the following
[documentation](https://apodat.iadb.nl/voorbeelden/iadb_vars.html)
describing standard IADB variables.

# Getting started

Most of the works in this repository, especially the `R` scripts, should
be directly reproducible. You’ll need
[`git`](https://git-scm.com/downloads),
[`R`](https://www.r-project.org/),
[`quarto`](https://quarto.org/docs/download/), and more conveniently
[RStudio IDE](https://posit.co/downloads/) installed and running well in
your system. You simply need to fork/clone this repository using RStudio
by following [this tutorial, start right away from
`Step 2`](https://book.cds101.com/using-rstudio-server-to-clone-a-github-repo-as-a-new-project.html#step---2).
Using terminal in linux/MacOS, you can issue the following command:

    quarto tools install tinytex

This command will install `tinytex` in your path, which is required to
compile quarto documents as latex/pdf. Afterwards, in your RStudio
command line, you can copy paste the following code to setup your
working directory:

    install.packages("renv") # Only need to run this step if `renv` is not installed

This step will install `renv` package, which will help you set up the
`R` environment. Please note that `renv` helps tracking, versioning, and
updating packages I used throughout the analysis.

    renv::restore()

This step will read `renv.lock` file and install required packages to
your local machine. When all packages loaded properly (make sure there’s
no error at all), you *have to* restart your R session. Then, you should
be able to proceed with:

    targets::tar_make()

This step will read `_targets.R` file, where I systematically draft all
of the analysis steps. Once it’s done running, you will find the
rendered document (either in `html` or `pdf`) inside the `draft`
directory.

# What’s this all about?

This is the analysis pipeline for conducting analysis in an umbrella
review. The complete flow can be viewed in the following `mermaid`
diagram:

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x5b3426b4c7fa7dbc([""Started""]):::started
    x5b3426b4c7fa7dbc([""Started""]):::started --- x4b0c520b8bc07c5b([""Errored""]):::errored
    x4b0c520b8bc07c5b([""Errored""]):::errored --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- x70a5fa6bea6f298d[""Pattern""]:::none
    x70a5fa6bea6f298d[""Pattern""]:::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xa117c043e8f9b503>"vizMonth"]:::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xfc9293f408401e5e>"vizAutocor"]:::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xab29c0af1a4e1af0>"vizArima"]:::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x203d559dcf99559c>"vizDot"]:::uptodate
    x97c70e20651b3e03>"genColor"]:::uptodate --> x1e87c6f89e191de7>"setStripColor"]:::uptodate
    x97c70e20651b3e03>"genColor"]:::uptodate --> xfc9293f408401e5e>"vizAutocor"]:::uptodate
    x97c70e20651b3e03>"genColor"]:::uptodate --> x203d559dcf99559c>"vizDot"]:::uptodate
    xaba6069a563b12e8>"getNeuroMeds"]:::uptodate --> x1e87c6f89e191de7>"setStripColor"]:::uptodate
    xaba6069a563b12e8>"getNeuroMeds"]:::uptodate --> xc04d85957c4a84d0>"setGroupFactor"]:::uptodate
    xaba6069a563b12e8>"getNeuroMeds"]:::uptodate --> x6c212354357aadc8>"mergeTS"]:::uptodate
    x1e87c6f89e191de7>"setStripColor"]:::uptodate --> xfc9293f408401e5e>"vizAutocor"]:::uptodate
    x1e87c6f89e191de7>"setStripColor"]:::uptodate --> x203d559dcf99559c>"vizDot"]:::uptodate
    xc366d1d8806979f6>"genLabel"]:::uptodate --> x970b27788a81a7b0>"mkMatrix"]:::uptodate
    xeb859985bc1ac4aa>"aggregateTS"]:::uptodate --> x6c212354357aadc8>"mergeTS"]:::uptodate
    xc04d85957c4a84d0>"setGroupFactor"]:::uptodate --> x6c212354357aadc8>"mergeTS"]:::uptodate
    xa117c043e8f9b503>"vizMonth"]:::uptodate --> xb9f54242cee3597e>"vizPolar"]:::uptodate
    xb9f54242cee3597e>"vizPolar"]:::uptodate --> x2a89da525d1cc153>"describe"]:::uptodate
    x59afdd7893d2ce9b>"describeMean"]:::uptodate --> x2a89da525d1cc153>"describe"]:::uptodate
    x970b27788a81a7b0>"mkMatrix"]:::uptodate --> x9ca1aa7607080a7b>"mkGraph"]:::uptodate
    x4e58fb85b5f553b2>"groupAtc"]:::uptodate --> x7514d3a2992ccd63>"splitAtc"]:::uptodate
    xb5a1412177d32e97>"vizPair"]:::uptodate --> x2a89da525d1cc153>"describe"]:::uptodate
    xec523c05a7988872>"pairByRow"]:::uptodate --> x970b27788a81a7b0>"mkMatrix"]:::uptodate
    xf2831b13ede46eac(["iadb_metrics"]):::uptodate --> x161c318befd047bc(["ts_quarter"]):::uptodate
    x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate --> x161c318befd047bc(["ts_quarter"]):::uptodate
    x6c212354357aadc8>"mergeTS"]:::uptodate --> x161c318befd047bc(["ts_quarter"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x75194963d4e125a5(["decom_ts_week_1.month_loess_pagerank"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x75194963d4e125a5(["decom_ts_week_1.month_loess_pagerank"]):::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> x2fa7893b9e204626["ts_diff2_adf_week"]:::uptodate
    xa81f3ac85c3ab6fc(["ts_diff2_week"]):::uptodate --> x2fa7893b9e204626["ts_diff2_adf_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x2fa7893b9e204626["ts_diff2_adf_week"]:::uptodate
    xd663dbf13bc7985e["plt_pacf_day"]:::uptodate --> x91895ac9fc912426["fig_pacf_day"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x91895ac9fc912426["fig_pacf_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x91895ac9fc912426["fig_pacf_day"]:::uptodate
    x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate --> xa43e6b5b1b499bca["mod_arima_eval_n_claim"]:::uptodate
    x685ff5739109ee80(["ts_diff_day"]):::uptodate --> x0d9b06f0646ca4fd["plt_acf_diff_day"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x0d9b06f0646ca4fd["plt_acf_diff_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x0d9b06f0646ca4fd["plt_acf_diff_day"]:::uptodate
    x177fd622fb419be5(["decom_ts_month_1.year_classic_n_claim"]):::uptodate --> xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::uptodate
    x26f0e6d9c84feda3(["decom_ts_week_1.month_classic_pagerank"]):::uptodate --> xf979fd14621ad008(["plt_decom_ts_week_1.month_classic_pagerank"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xf979fd14621ad008(["plt_decom_ts_week_1.month_classic_pagerank"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xf979fd14621ad008(["plt_decom_ts_week_1.month_classic_pagerank"]):::uptodate
    x31faa9d48477f81b(["ts_diff_week"]):::uptodate --> x37afaee2bd3e651d["plt_pacf_diff_week"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x37afaee2bd3e651d["plt_pacf_diff_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x37afaee2bd3e651d["plt_pacf_diff_week"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x3e1db942d8fb6918(["decom_ts_day_1.week_loess_n_claim"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x3e1db942d8fb6918(["decom_ts_day_1.week_loess_n_claim"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xe29768ff9b12a046(["decom_ts_week_1.month_classic_eigen"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xe29768ff9b12a046(["decom_ts_week_1.month_classic_eigen"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xdfb8fbeb1ccf7a84(["decom_ts_day_1.week_classic_pagerank"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xdfb8fbeb1ccf7a84(["decom_ts_day_1.week_classic_pagerank"]):::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> xb035523f702a18f0["plt_polar_eigen"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> xb035523f702a18f0["plt_polar_eigen"]:::uptodate
    xb9f54242cee3597e>"vizPolar"]:::uptodate --> xb035523f702a18f0["plt_polar_eigen"]:::uptodate
    x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate --> xdec7d06ab7bbbc50["mod_arima_forecast_n_claim"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> x8d4989d190572307["plt_pacf_diff_month"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x8d4989d190572307["plt_pacf_diff_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x8d4989d190572307["plt_pacf_diff_month"]:::uptodate
    xf2831b13ede46eac(["iadb_metrics"]):::uptodate --> x14bcf0b7ef5959f1(["ts_month"]):::uptodate
    x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate --> x14bcf0b7ef5959f1(["ts_month"]):::uptodate
    x6c212354357aadc8>"mergeTS"]:::uptodate --> x14bcf0b7ef5959f1(["ts_month"]):::uptodate
    x9ca1aa7607080a7b>"mkGraph"]:::uptodate --> x278d817c06f60e98["iadb_graph"]:::uptodate
    xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate --> x278d817c06f60e98["iadb_graph"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x7dbb58def017efbe(["report_arima"]):::errored
    x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::errored
    x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::errored
    x11abd7770785b634["mod_arima_eval_claim2patient"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::errored
    x91a77d5b4dfa50f4["mod_arima_eval_eigen"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::errored
    xa43e6b5b1b499bca["mod_arima_eval_n_claim"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::errored
    x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::errored
    x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::errored
    x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::errored
    x55a0e476a043137e["plt_arima_forecast_n_claim"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::errored
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x1ed9cd4bb202a9cd(["decom_ts_month_1.year_classic_eigen"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x1ed9cd4bb202a9cd(["decom_ts_month_1.year_classic_eigen"]):::uptodate
    x6c570eed1079677b>"fitModel"]:::uptodate --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate
    xe29768ff9b12a046(["decom_ts_week_1.month_classic_eigen"]):::uptodate --> x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::uptodate
    x6c570eed1079677b>"fitModel"]:::uptodate --> x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x26f0e6d9c84feda3(["decom_ts_week_1.month_classic_pagerank"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x26f0e6d9c84feda3(["decom_ts_week_1.month_classic_pagerank"]):::uptodate
    x26d978ef372a4baa(["ts_diff_quarter"]):::uptodate --> x7cf3f71d2288fde1["plt_acf_diff_quarter"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x7cf3f71d2288fde1["plt_acf_diff_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x7cf3f71d2288fde1["plt_acf_diff_quarter"]:::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x14741661dc71d34f(["ts_diff2_month"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x14741661dc71d34f(["ts_diff2_month"]):::uptodate
    x771a367f0ef7807a>"iterby"]:::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x7514d3a2992ccd63>"splitAtc"]:::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x960707f0c582886a(["tbl_iadb_by_date"]):::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x161c318befd047bc(["ts_quarter"]):::uptodate --> xe81889aad15f32f0["plt_dot_quarter"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xe81889aad15f32f0["plt_dot_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xe81889aad15f32f0["plt_dot_quarter"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> x594417459f28b9f7["plt_dot_diff_month"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x594417459f28b9f7["plt_dot_diff_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x594417459f28b9f7["plt_dot_diff_month"]:::uptodate
    x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate --> x84aa03deac41b190["mod_arima_forecast_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xd62f0e429a89e62d(["decom_ts_week_1.month_classic_claim2patient"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xd62f0e429a89e62d(["decom_ts_week_1.month_classic_claim2patient"]):::uptodate
    x6c48091042266f38["plt_acf_day"]:::uptodate --> x7142295daf13496f["fig_acf_day"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x7142295daf13496f["fig_acf_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x7142295daf13496f["fig_acf_day"]:::uptodate
    x5f6f1c8a83147e6b(["decom_ts_month_1.year_classic_pagerank"]):::uptodate --> xd0ae4bced1fae00b(["plt_decom_ts_month_1.year_classic_pagerank"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xd0ae4bced1fae00b(["plt_decom_ts_month_1.year_classic_pagerank"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xd0ae4bced1fae00b(["plt_decom_ts_month_1.year_classic_pagerank"]):::uptodate
    x07ac0b71f920f889>"combineMetrics"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    xc082a51377a349bf>"fieldSummary"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    x3e1db942d8fb6918(["decom_ts_day_1.week_loess_n_claim"]):::uptodate --> xbb48420e6e10ad81(["plt_decom_ts_day_1.week_loess_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xbb48420e6e10ad81(["plt_decom_ts_day_1.week_loess_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xbb48420e6e10ad81(["plt_decom_ts_day_1.week_loess_n_claim"]):::uptodate
    x6a09c8df8bd1d186["plt_acf_quarter"]:::uptodate --> xfac73dc92041cb20["fig_acf_quarter"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> xfac73dc92041cb20["fig_acf_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xfac73dc92041cb20["fig_acf_quarter"]:::uptodate
    xcc3fd8f4d6a4b61b(["decom_ts_month_1.year_loess_n_claim"]):::uptodate --> xf16e7879fce7a9b9(["plt_decom_ts_month_1.year_loess_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xf16e7879fce7a9b9(["plt_decom_ts_month_1.year_loess_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xf16e7879fce7a9b9(["plt_decom_ts_month_1.year_loess_n_claim"]):::uptodate
    x87f485f2ede7231a(["decom_ts_day_1.week_classic_eigen"]):::uptodate --> x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x14e721e34c9c8b1b(["decom_ts_week_1.month_loess_n_claim"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x14e721e34c9c8b1b(["decom_ts_week_1.month_loess_n_claim"]):::uptodate
    x897e8856e62b7088(["decom_ts_day_1.week_classic_n_claim"]):::uptodate --> xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x53f054da58185e0c(["decom_ts_month_1.year_loess_claim2patient"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x53f054da58185e0c(["decom_ts_month_1.year_loess_claim2patient"]):::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> x2e1da972c7bafc5d["ts_adf_month"]:::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x2e1da972c7bafc5d["ts_adf_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x2e1da972c7bafc5d["ts_adf_month"]:::uptodate
    xce13d34bbb5aa635(["decom_ts_month_1.year_loess_pagerank"]):::uptodate --> x5bcf6acba4a9ee87(["plt_decom_ts_month_1.year_loess_pagerank"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x5bcf6acba4a9ee87(["plt_decom_ts_month_1.year_loess_pagerank"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x5bcf6acba4a9ee87(["plt_decom_ts_month_1.year_loess_pagerank"]):::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x6f30c82e93f04550["plt_polar_n_claim"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> x6f30c82e93f04550["plt_polar_n_claim"]:::uptodate
    xb9f54242cee3597e>"vizPolar"]:::uptodate --> x6f30c82e93f04550["plt_polar_n_claim"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x177fd622fb419be5(["decom_ts_month_1.year_classic_n_claim"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x177fd622fb419be5(["decom_ts_month_1.year_classic_n_claim"]):::uptodate
    x0d663b4f57e06f5c["plt_dot_month"]:::uptodate --> xf27968c319f369d5["fig_dot_month"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> xf27968c319f369d5["fig_dot_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xf27968c319f369d5["fig_dot_month"]:::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x685ff5739109ee80(["ts_diff_day"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x685ff5739109ee80(["ts_diff_day"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x3455a1c44fd0ba64(["decom_ts_month_1.year_loess_eigen"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x3455a1c44fd0ba64(["decom_ts_month_1.year_loess_eigen"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xee05927e7b88ad5d["plt_pacf_week"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xee05927e7b88ad5d["plt_pacf_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xee05927e7b88ad5d["plt_pacf_week"]:::uptodate
    x31faa9d48477f81b(["ts_diff_week"]):::uptodate --> x9a2a3b9d04de4370["plt_acf_diff_week"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x9a2a3b9d04de4370["plt_acf_diff_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x9a2a3b9d04de4370["plt_acf_diff_week"]:::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> x7af695eda3d6ea1d["ts_diff_adf_week"]:::uptodate
    x31faa9d48477f81b(["ts_diff_week"]):::uptodate --> x7af695eda3d6ea1d["ts_diff_adf_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x7af695eda3d6ea1d["ts_diff_adf_week"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xcc3fd8f4d6a4b61b(["decom_ts_month_1.year_loess_n_claim"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> xcc3fd8f4d6a4b61b(["decom_ts_month_1.year_loess_n_claim"]):::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> x7440ed4ea9a60ac1["ts_diff_adf_month"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> x7440ed4ea9a60ac1["ts_diff_adf_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x7440ed4ea9a60ac1["ts_diff_adf_month"]:::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xb3f8990b0bb8c5fa["plt_dot_day"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xb3f8990b0bb8c5fa["plt_dot_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xb3f8990b0bb8c5fa["plt_dot_day"]:::uptodate
    xc058910fe0c21157(["decom_ts_day_1.week_loess_eigen"]):::uptodate --> x8d5c69a2dec41c58(["plt_decom_ts_day_1.week_loess_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x8d5c69a2dec41c58(["plt_decom_ts_day_1.week_loess_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x8d5c69a2dec41c58(["plt_decom_ts_day_1.week_loess_eigen"]):::uptodate
    xd62f0e429a89e62d(["decom_ts_week_1.month_classic_claim2patient"]):::uptodate --> x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::uptodate
    x161c318befd047bc(["ts_quarter"]):::uptodate --> x25acaa1eb344ea3e["plt_pacf_quarter"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x25acaa1eb344ea3e["plt_pacf_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x25acaa1eb344ea3e["plt_pacf_quarter"]:::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x31faa9d48477f81b(["ts_diff_week"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x31faa9d48477f81b(["ts_diff_week"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xd9701f9522b636a9(["decom_ts_day_1.week_classic_claim2patient"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xd9701f9522b636a9(["decom_ts_day_1.week_classic_claim2patient"]):::uptodate
    xf8272e0666b2c4b7(["decom_ts_day_1.week_loess_claim2patient"]):::uptodate --> xd7a44f53b7e1f2b5(["plt_decom_ts_day_1.week_loess_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xd7a44f53b7e1f2b5(["plt_decom_ts_day_1.week_loess_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xd7a44f53b7e1f2b5(["plt_decom_ts_day_1.week_loess_claim2patient"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xac3ca7d0385656a2(["decom_ts_week_1.month_classic_n_claim"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xac3ca7d0385656a2(["decom_ts_week_1.month_classic_n_claim"]):::uptodate
    xccc889a3af79aa2f["plt_acf_week"]:::uptodate --> xbde164b969460ca6["fig_acf_week"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> xbde164b969460ca6["fig_acf_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xbde164b969460ca6["fig_acf_week"]:::uptodate
    x07ac0b71f920f889>"combineMetrics"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x3902bbed135b0ec7>"getMetrics"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x278d817c06f60e98["iadb_graph"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    xe81889aad15f32f0["plt_dot_quarter"]:::uptodate --> x0c32c2f20c4bd0cb["fig_dot_quarter"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x0c32c2f20c4bd0cb["fig_dot_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x0c32c2f20c4bd0cb["fig_dot_quarter"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x2eab2a0f6af8a669(["decom_ts_week_1.month_loess_eigen"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x2eab2a0f6af8a669(["decom_ts_week_1.month_loess_eigen"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x981e6dcac7842e2f(["decom_ts_day_1.week_loess_pagerank"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x981e6dcac7842e2f(["decom_ts_day_1.week_loess_pagerank"]):::uptodate
    xb3f8990b0bb8c5fa["plt_dot_day"]:::uptodate --> x5b0c1878c6ce7387["fig_dot_day"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x5b0c1878c6ce7387["fig_dot_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x5b0c1878c6ce7387["fig_dot_day"]:::uptodate
    xac3ca7d0385656a2(["decom_ts_week_1.month_classic_n_claim"]):::uptodate --> x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::uptodate
    x2a89da525d1cc153>"describe"]:::uptodate --> x005a6c6598235267(["desc_ts"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x005a6c6598235267(["desc_ts"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x0d663b4f57e06f5c["plt_dot_month"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x0d663b4f57e06f5c["plt_dot_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x0d663b4f57e06f5c["plt_dot_month"]:::uptodate
    xee05927e7b88ad5d["plt_pacf_week"]:::uptodate --> x6984021042b3f101["fig_pacf_week"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x6984021042b3f101["fig_pacf_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x6984021042b3f101["fig_pacf_week"]:::uptodate
    x25acaa1eb344ea3e["plt_pacf_quarter"]:::uptodate --> xc8e557d54acf36cf["fig_pacf_quarter"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> xc8e557d54acf36cf["fig_pacf_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xc8e557d54acf36cf["fig_pacf_quarter"]:::uptodate
    x14e721e34c9c8b1b(["decom_ts_week_1.month_loess_n_claim"]):::uptodate --> xc396e37111805a84(["plt_decom_ts_week_1.month_loess_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xc396e37111805a84(["plt_decom_ts_week_1.month_loess_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xc396e37111805a84(["plt_decom_ts_week_1.month_loess_n_claim"]):::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x26d978ef372a4baa(["ts_diff_quarter"]):::uptodate
    x161c318befd047bc(["ts_quarter"]):::uptodate --> x26d978ef372a4baa(["ts_diff_quarter"]):::uptodate
    x6c570eed1079677b>"fitModel"]:::uptodate --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::uptodate
    x84aa03deac41b190["mod_arima_forecast_claim2patient"]:::uptodate --> x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::uptodate
    xab29c0af1a4e1af0>"vizArima"]:::uptodate --> x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::uptodate
    xc585414cb0a04329["plt_acf_diff_month"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    xb97e67c2f6d8ad03["plt_dot_diff_day"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x594417459f28b9f7["plt_dot_diff_month"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x9a9424cd5083d745["plt_dot_diff_week"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x8d4989d190572307["plt_pacf_diff_month"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    xb94732c2937f4162["plt_polar_claim2patient"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    xb035523f702a18f0["plt_polar_eigen"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x6f30c82e93f04550["plt_polar_n_claim"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xccc889a3af79aa2f["plt_acf_week"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xccc889a3af79aa2f["plt_acf_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xccc889a3af79aa2f["plt_acf_week"]:::uptodate
    xf2831b13ede46eac(["iadb_metrics"]):::uptodate --> xe654ad4c04f23a28(["ts_week"]):::uptodate
    x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate --> xe654ad4c04f23a28(["ts_week"]):::uptodate
    x6c212354357aadc8>"mergeTS"]:::uptodate --> xe654ad4c04f23a28(["ts_week"]):::uptodate
    x26d978ef372a4baa(["ts_diff_quarter"]):::uptodate --> x592138e7b61af613["plt_pacf_diff_quarter"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x592138e7b61af613["plt_pacf_diff_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x592138e7b61af613["plt_pacf_diff_quarter"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::uptodate
    x72cd3fa746b70917["mod_arima_forecast_eigen"]:::uptodate --> x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::uptodate
    xab29c0af1a4e1af0>"vizArima"]:::uptodate --> x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> xb94732c2937f4162["plt_polar_claim2patient"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> xb94732c2937f4162["plt_polar_claim2patient"]:::uptodate
    xb9f54242cee3597e>"vizPolar"]:::uptodate --> xb94732c2937f4162["plt_polar_claim2patient"]:::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x6da2e542198a5d93(["ts_diff_month"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x6da2e542198a5d93(["ts_diff_month"]):::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> xc585414cb0a04329["plt_acf_diff_month"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xc585414cb0a04329["plt_acf_diff_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xc585414cb0a04329["plt_acf_diff_month"]:::uptodate
    xf3e78b060469e6a9(["decom_ts_month_1.year_classic_claim2patient"]):::uptodate --> xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::uptodate
    xdfb8fbeb1ccf7a84(["decom_ts_day_1.week_classic_pagerank"]):::uptodate --> x0399dc20f8605a2d(["plt_decom_ts_day_1.week_classic_pagerank"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x0399dc20f8605a2d(["plt_decom_ts_day_1.week_classic_pagerank"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x0399dc20f8605a2d(["plt_decom_ts_day_1.week_classic_pagerank"]):::uptodate
    xd9701f9522b636a9(["decom_ts_day_1.week_classic_claim2patient"]):::uptodate --> x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> xf8de1527c97aa46e["ts_adf_day"]:::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xf8de1527c97aa46e["ts_adf_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xf8de1527c97aa46e["ts_adf_day"]:::uptodate
    x75194963d4e125a5(["decom_ts_week_1.month_loess_pagerank"]):::uptodate --> xb174918e42cc98f8(["plt_decom_ts_week_1.month_loess_pagerank"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xb174918e42cc98f8(["plt_decom_ts_week_1.month_loess_pagerank"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xb174918e42cc98f8(["plt_decom_ts_week_1.month_loess_pagerank"]):::uptodate
    x15823228216e9e2e["plt_dot_week"]:::uptodate --> x710d593c64216c80["fig_dot_week"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x710d593c64216c80["fig_dot_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x710d593c64216c80["fig_dot_week"]:::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> xf7cbcd4257e4eaeb["ts_diff2_adf_month"]:::uptodate
    x14741661dc71d34f(["ts_diff2_month"]):::uptodate --> xf7cbcd4257e4eaeb["ts_diff2_adf_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xf7cbcd4257e4eaeb["ts_diff2_adf_month"]:::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> x4d82858c988b3064["ts_adf_quarter"]:::uptodate
    x161c318befd047bc(["ts_quarter"]):::uptodate --> x4d82858c988b3064["ts_adf_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x4d82858c988b3064["ts_adf_quarter"]:::uptodate
    x31faa9d48477f81b(["ts_diff_week"]):::uptodate --> x9a9424cd5083d745["plt_dot_diff_week"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x9a9424cd5083d745["plt_dot_diff_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x9a9424cd5083d745["plt_dot_diff_week"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x87f485f2ede7231a(["decom_ts_day_1.week_classic_eigen"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x87f485f2ede7231a(["decom_ts_day_1.week_classic_eigen"]):::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> x19527b92b9df1dc8["ts_diff2_adf_quarter"]:::uptodate
    xdab756b7a7ba6359(["ts_diff2_quarter"]):::uptodate --> x19527b92b9df1dc8["ts_diff2_adf_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x19527b92b9df1dc8["ts_diff2_adf_quarter"]:::uptodate
    x981e6dcac7842e2f(["decom_ts_day_1.week_loess_pagerank"]):::uptodate --> x756eeecfd7eacab8(["plt_decom_ts_day_1.week_loess_pagerank"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x756eeecfd7eacab8(["plt_decom_ts_day_1.week_loess_pagerank"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x756eeecfd7eacab8(["plt_decom_ts_day_1.week_loess_pagerank"]):::uptodate
    x685ff5739109ee80(["ts_diff_day"]):::uptodate --> xb97e67c2f6d8ad03["plt_dot_diff_day"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xb97e67c2f6d8ad03["plt_dot_diff_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xb97e67c2f6d8ad03["plt_dot_diff_day"]:::uptodate
    x2a89da525d1cc153>"describe"]:::uptodate --> xf1c5dfc78ca50f32["plt_pair"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> xf1c5dfc78ca50f32["plt_pair"]:::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xf1c5dfc78ca50f32["plt_pair"]:::uptodate
    x005a6c6598235267(["desc_ts"]):::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x6c48091042266f38["plt_acf_day"]:::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x52127149f1444c9e["plt_acf_month"]:::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    xccc889a3af79aa2f["plt_acf_week"]:::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    xb3f8990b0bb8c5fa["plt_dot_day"]:::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x0d663b4f57e06f5c["plt_dot_month"]:::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x15823228216e9e2e["plt_dot_week"]:::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    xd663dbf13bc7985e["plt_pacf_day"]:::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x2141e3016fa1f53c["plt_pacf_month"]:::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    xee05927e7b88ad5d["plt_pacf_week"]:::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    xf1c5dfc78ca50f32["plt_pair"]:::uptodate --> xb732c9f900c9b239(["report_descriptive"]):::uptodate
    x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate --> x72cd3fa746b70917["mod_arima_forecast_eigen"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x55a0e476a043137e["plt_arima_forecast_n_claim"]:::uptodate
    xdec7d06ab7bbbc50["mod_arima_forecast_n_claim"]:::uptodate --> x55a0e476a043137e["plt_arima_forecast_n_claim"]:::uptodate
    xab29c0af1a4e1af0>"vizArima"]:::uptodate --> x55a0e476a043137e["plt_arima_forecast_n_claim"]:::uptodate
    xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate --> x960707f0c582886a(["tbl_iadb_by_date"]):::uptodate
    x52127149f1444c9e["plt_acf_month"]:::uptodate --> x1e581e1515b0bc41["fig_acf_month"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x1e581e1515b0bc41["fig_acf_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x1e581e1515b0bc41["fig_acf_month"]:::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x9bfe90d7816277ce(["ts_diff2_day"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x9bfe90d7816277ce(["ts_diff2_day"]):::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> xdab756b7a7ba6359(["ts_diff2_quarter"]):::uptodate
    x161c318befd047bc(["ts_quarter"]):::uptodate --> xdab756b7a7ba6359(["ts_diff2_quarter"]):::uptodate
    x3455a1c44fd0ba64(["decom_ts_month_1.year_loess_eigen"]):::uptodate --> x4801de0cb1b805de(["plt_decom_ts_month_1.year_loess_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4801de0cb1b805de(["plt_decom_ts_month_1.year_loess_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4801de0cb1b805de(["plt_decom_ts_month_1.year_loess_eigen"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x15823228216e9e2e["plt_dot_week"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x15823228216e9e2e["plt_dot_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x15823228216e9e2e["plt_dot_week"]:::uptodate
    x2eab2a0f6af8a669(["decom_ts_week_1.month_loess_eigen"]):::uptodate --> x2868c0cd1863b793(["plt_decom_ts_week_1.month_loess_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x2868c0cd1863b793(["plt_decom_ts_week_1.month_loess_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x2868c0cd1863b793(["plt_decom_ts_week_1.month_loess_eigen"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xf3e78b060469e6a9(["decom_ts_month_1.year_classic_claim2patient"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> xf3e78b060469e6a9(["decom_ts_month_1.year_classic_claim2patient"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xd663dbf13bc7985e["plt_pacf_day"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xd663dbf13bc7985e["plt_pacf_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xd663dbf13bc7985e["plt_pacf_day"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xc058910fe0c21157(["decom_ts_day_1.week_loess_eigen"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xc058910fe0c21157(["decom_ts_day_1.week_loess_eigen"]):::uptodate
    xf2831b13ede46eac(["iadb_metrics"]):::uptodate --> x7ffe35eee48c2674(["ts_day"]):::uptodate
    x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate --> x7ffe35eee48c2674(["ts_day"]):::uptodate
    x6c212354357aadc8>"mergeTS"]:::uptodate --> x7ffe35eee48c2674(["ts_day"]):::uptodate
    x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate --> x11abd7770785b634["mod_arima_eval_claim2patient"]:::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x6c48091042266f38["plt_acf_day"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x6c48091042266f38["plt_acf_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x6c48091042266f38["plt_acf_day"]:::uptodate
    x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate --> x91a77d5b4dfa50f4["mod_arima_eval_eigen"]:::uptodate
    x161c318befd047bc(["ts_quarter"]):::uptodate --> x6a09c8df8bd1d186["plt_acf_quarter"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x6a09c8df8bd1d186["plt_acf_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x6a09c8df8bd1d186["plt_acf_quarter"]:::uptodate
    x1ed9cd4bb202a9cd(["decom_ts_month_1.year_classic_eigen"]):::uptodate --> x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::uptodate
    x26d978ef372a4baa(["ts_diff_quarter"]):::uptodate --> x32bc61ea639738f1["plt_dot_diff_quarter"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x32bc61ea639738f1["plt_dot_diff_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x32bc61ea639738f1["plt_dot_diff_quarter"]:::uptodate
    x0e604d354415ef78(["decom_ts_week_1.month_loess_claim2patient"]):::uptodate --> x3a08a75e6c4bebfd(["plt_decom_ts_week_1.month_loess_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x3a08a75e6c4bebfd(["plt_decom_ts_week_1.month_loess_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x3a08a75e6c4bebfd(["plt_decom_ts_week_1.month_loess_claim2patient"]):::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> x05615356a2a9aaae["ts_adf_week"]:::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x05615356a2a9aaae["ts_adf_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x05615356a2a9aaae["ts_adf_week"]:::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> x8620ba0b6c1dade6["ts_diff_adf_day"]:::uptodate
    x685ff5739109ee80(["ts_diff_day"]):::uptodate --> x8620ba0b6c1dade6["ts_diff_adf_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x8620ba0b6c1dade6["ts_diff_adf_day"]:::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> xdc4595467eafe4a6["ts_diff_adf_quarter"]:::uptodate
    x26d978ef372a4baa(["ts_diff_quarter"]):::uptodate --> xdc4595467eafe4a6["ts_diff_adf_quarter"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xdc4595467eafe4a6["ts_diff_adf_quarter"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x0e604d354415ef78(["decom_ts_week_1.month_loess_claim2patient"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x0e604d354415ef78(["decom_ts_week_1.month_loess_claim2patient"]):::uptodate
    x4a5693aa168fe170{{"iadb"}}:::uptodate --> xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate
    x8d5064cb2dc0b750>"readIADB"]:::uptodate --> xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate
    x53f054da58185e0c(["decom_ts_month_1.year_loess_claim2patient"]):::uptodate --> x3bf481d8364be564(["plt_decom_ts_month_1.year_loess_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x3bf481d8364be564(["plt_decom_ts_month_1.year_loess_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x3bf481d8364be564(["plt_decom_ts_month_1.year_loess_claim2patient"]):::uptodate
    x161c318befd047bc(["ts_quarter"]):::uptodate --> xcd136c75f6948bfd(["med_groups"]):::uptodate
    xa04cca11444ac31d>"getADF"]:::uptodate --> x659cc62608118b5e["ts_diff2_adf_day"]:::uptodate
    x9bfe90d7816277ce(["ts_diff2_day"]):::uptodate --> x659cc62608118b5e["ts_diff2_adf_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x659cc62608118b5e["ts_diff2_adf_day"]:::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x2141e3016fa1f53c["plt_pacf_month"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x2141e3016fa1f53c["plt_pacf_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x2141e3016fa1f53c["plt_pacf_month"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xce13d34bbb5aa635(["decom_ts_month_1.year_loess_pagerank"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> xce13d34bbb5aa635(["decom_ts_month_1.year_loess_pagerank"]):::uptodate
    x2141e3016fa1f53c["plt_pacf_month"]:::uptodate --> x88834797050fcde2["fig_pacf_month"]:::uptodate
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x88834797050fcde2["fig_pacf_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x88834797050fcde2["fig_pacf_month"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xf8272e0666b2c4b7(["decom_ts_day_1.week_loess_claim2patient"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xf8272e0666b2c4b7(["decom_ts_day_1.week_loess_claim2patient"]):::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x897e8856e62b7088(["decom_ts_day_1.week_classic_n_claim"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x897e8856e62b7088(["decom_ts_day_1.week_classic_n_claim"]):::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> xa81f3ac85c3ab6fc(["ts_diff2_week"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xa81f3ac85c3ab6fc(["ts_diff2_week"]):::uptodate
    x685ff5739109ee80(["ts_diff_day"]):::uptodate --> x5fefb5a0d8750f50["plt_pacf_diff_day"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x5fefb5a0d8750f50["plt_pacf_diff_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x5fefb5a0d8750f50["plt_pacf_diff_day"]:::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x52127149f1444c9e["plt_acf_month"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x52127149f1444c9e["plt_acf_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x52127149f1444c9e["plt_acf_month"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x5f6f1c8a83147e6b(["decom_ts_month_1.year_classic_pagerank"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x5f6f1c8a83147e6b(["decom_ts_month_1.year_classic_pagerank"]):::uptodate
    x6e52cb0f1668cc22(["readme"]):::started --> x6e52cb0f1668cc22(["readme"]):::started
    xea1cdd6f009574c2{{"pkgs_load"}}:::uptodate --> xea1cdd6f009574c2{{"pkgs_load"}}:::uptodate
    x2166607dfe6e75f2{{"funs"}}:::uptodate --> x2166607dfe6e75f2{{"funs"}}:::uptodate
    x2d15849e3198e8d1{{"pkgs"}}:::uptodate --> x2d15849e3198e8d1{{"pkgs"}}:::uptodate
    xfb5278c6bbbf3460>"lsData"]:::uptodate --> xfb5278c6bbbf3460>"lsData"]:::uptodate
    xe1d1bcdb96b9c2dc{{"is_test"}}:::uptodate --> xe1d1bcdb96b9c2dc{{"is_test"}}:::uptodate
    x3ac540af10f1b504{{"iadb_raw"}}:::uptodate --> x3ac540af10f1b504{{"iadb_raw"}}:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef errored stroke:#000000,color:#ffffff,fill:#C93312;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 5 stroke-width:0px;
  linkStyle 411 stroke-width:0px;
  linkStyle 412 stroke-width:0px;
  linkStyle 413 stroke-width:0px;
  linkStyle 414 stroke-width:0px;
  linkStyle 415 stroke-width:0px;
  linkStyle 416 stroke-width:0px;
  linkStyle 417 stroke-width:0px;
```
