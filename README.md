
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

- The project is out-of-sync – use `renv::status()` for details. During
  startup - Warning messages: 1: Setting LC_COLLATE failed, using “C” 2:
  Setting LC_TIME failed, using “C” 3: Setting LC_MESSAGES failed, using
  “C” 4: Setting LC_MONETARY failed, using “C”

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    x0a52b03877696646([""Outdated""]):::outdated --- xa8565c104d8f0705([""Dispatched""]):::dispatched
    xa8565c104d8f0705([""Dispatched""]):::dispatched --- x7420bd9270f8d27d([""Up to date""]):::uptodate
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- x70a5fa6bea6f298d[""Pattern""]:::none
    x70a5fa6bea6f298d[""Pattern""]:::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x55e2af9f684b7032>"vizReconSsa"]:::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xa117c043e8f9b503>"vizMonth"]:::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xfc9293f408401e5e>"vizAutocor"]:::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xab29c0af1a4e1af0>"vizArima"]:::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x203d559dcf99559c>"vizDot"]:::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x098757b4b84b914a>"vizPeriod"]:::uptodate
    x5509cc22a0bc4e12>"tidyReconSsa"]:::uptodate --> x530163c6df184499>"reconSsa"]:::uptodate
    x97c70e20651b3e03>"genColor"]:::uptodate --> x1e87c6f89e191de7>"setStripColor"]:::uptodate
    x97c70e20651b3e03>"genColor"]:::uptodate --> xfc9293f408401e5e>"vizAutocor"]:::uptodate
    x97c70e20651b3e03>"genColor"]:::uptodate --> x203d559dcf99559c>"vizDot"]:::uptodate
    xaba6069a563b12e8>"getNeuroMeds"]:::uptodate --> x1e87c6f89e191de7>"setStripColor"]:::uptodate
    xaba6069a563b12e8>"getNeuroMeds"]:::uptodate --> xc04d85957c4a84d0>"setGroupFactor"]:::uptodate
    xaba6069a563b12e8>"getNeuroMeds"]:::uptodate --> x6c212354357aadc8>"mergeTS"]:::uptodate
    x1e87c6f89e191de7>"setStripColor"]:::uptodate --> xfc9293f408401e5e>"vizAutocor"]:::uptodate
    x1e87c6f89e191de7>"setStripColor"]:::uptodate --> x203d559dcf99559c>"vizDot"]:::uptodate
    x1e87c6f89e191de7>"setStripColor"]:::uptodate --> x098757b4b84b914a>"vizPeriod"]:::uptodate
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
    x0f6bf75cdbde6203>"getSsaGroup"]:::uptodate --> x530163c6df184499>"reconSsa"]:::uptodate
    x2a89da525d1cc153>"describe"]:::uptodate --> xf1c5dfc78ca50f32["plt_pair"]:::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> xf1c5dfc78ca50f32["plt_pair"]:::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> xf1c5dfc78ca50f32["plt_pair"]:::outdated
    x79fa432b43dcafaf["mod_arima_eigen"]:::outdated --> x91a77d5b4dfa50f4["mod_arima_eval_eigen"]:::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> xcd136c75f6948bfd(["med_groups"]):::outdated
    x31faa9d48477f81b(["ts_diff_week"]):::outdated --> x37afaee2bd3e651d["plt_pacf_diff_week"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x37afaee2bd3e651d["plt_pacf_diff_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x37afaee2bd3e651d["plt_pacf_diff_week"]:::outdated
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x6da2e542198a5d93(["ts_diff_month"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x6da2e542198a5d93(["ts_diff_month"]):::outdated
    x685ff5739109ee80(["ts_diff_day"]):::outdated --> x5fefb5a0d8750f50["plt_pacf_diff_day"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x5fefb5a0d8750f50["plt_pacf_diff_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x5fefb5a0d8750f50["plt_pacf_diff_day"]:::outdated
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> x117e2dedb4be160a["ts_diff_uroot_month"]:::outdated
    x6da2e542198a5d93(["ts_diff_month"]):::outdated --> x117e2dedb4be160a["ts_diff_uroot_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x117e2dedb4be160a["ts_diff_uroot_month"]:::outdated
    x005a6c6598235267(["desc_ts"]):::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x6c48091042266f38["plt_acf_day"]:::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x52127149f1444c9e["plt_acf_month"]:::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    xccc889a3af79aa2f["plt_acf_week"]:::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    xb3f8990b0bb8c5fa["plt_dot_day"]:::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x0d663b4f57e06f5c["plt_dot_month"]:::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x15823228216e9e2e["plt_dot_week"]:::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    xd663dbf13bc7985e["plt_pacf_day"]:::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x2141e3016fa1f53c["plt_pacf_month"]:::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    xee05927e7b88ad5d["plt_pacf_week"]:::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    xf1c5dfc78ca50f32["plt_pair"]:::outdated --> xb732c9f900c9b239(["report_descriptive"]):::outdated
    x31faa9d48477f81b(["ts_diff_week"]):::outdated --> x39119b929eabe90e["plt_period_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x39119b929eabe90e["plt_period_week"]:::outdated
    x098757b4b84b914a>"vizPeriod"]:::uptodate --> x39119b929eabe90e["plt_period_week"]:::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x2141e3016fa1f53c["plt_pacf_month"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x2141e3016fa1f53c["plt_pacf_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x2141e3016fa1f53c["plt_pacf_month"]:::outdated
    x6c570eed1079677b>"fitModel"]:::uptodate --> xfff40f8096285418["mod_ssa_n_claim"]:::outdated
    x7932dde01bed8634>"fitSsa"]:::uptodate --> xfff40f8096285418["mod_ssa_n_claim"]:::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> xfff40f8096285418["mod_ssa_n_claim"]:::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> xfff40f8096285418["mod_ssa_n_claim"]:::outdated
    x07ac0b71f920f889>"combineMetrics"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::outdated
    xc082a51377a349bf>"fieldSummary"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::outdated
    xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::outdated --> x6bbf38eac08a1fe8(["iadb_stats"]):::outdated
    x53f054da58185e0c(["decom_ts_month_1.year_loess_claim2patient"]):::outdated --> x3bf481d8364be564(["plt_decom_ts_month_1.year_loess_claim2patient"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x3bf481d8364be564(["plt_decom_ts_month_1.year_loess_claim2patient"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x3bf481d8364be564(["plt_decom_ts_month_1.year_loess_claim2patient"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x52127149f1444c9e["plt_acf_month"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x52127149f1444c9e["plt_acf_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x52127149f1444c9e["plt_acf_month"]:::outdated
    x177fd622fb419be5(["decom_ts_month_1.year_classic_n_claim"]):::outdated --> xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::outdated
    xf2831b13ede46eac(["iadb_metrics"]):::outdated --> x7ffe35eee48c2674(["ts_day"]):::outdated
    x6bbf38eac08a1fe8(["iadb_stats"]):::outdated --> x7ffe35eee48c2674(["ts_day"]):::outdated
    x6c212354357aadc8>"mergeTS"]:::uptodate --> x7ffe35eee48c2674(["ts_day"]):::outdated
    x7e1814e57b0b1be4["mod_arima_n_claim"]:::outdated --> xa43e6b5b1b499bca["mod_arima_eval_n_claim"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x87f485f2ede7231a(["decom_ts_day_1.week_classic_eigen"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> x87f485f2ede7231a(["decom_ts_day_1.week_classic_eigen"]):::outdated
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x14741661dc71d34f(["ts_diff2_month"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x14741661dc71d34f(["ts_diff2_month"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x15823228216e9e2e["plt_dot_week"]:::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x15823228216e9e2e["plt_dot_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x15823228216e9e2e["plt_dot_week"]:::outdated
    x31faa9d48477f81b(["ts_diff_week"]):::outdated --> x9a2a3b9d04de4370["plt_acf_diff_week"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x9a2a3b9d04de4370["plt_acf_diff_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x9a2a3b9d04de4370["plt_acf_diff_week"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x177fd622fb419be5(["decom_ts_month_1.year_classic_n_claim"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x177fd622fb419be5(["decom_ts_month_1.year_classic_n_claim"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xe29768ff9b12a046(["decom_ts_week_1.month_classic_eigen"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> xe29768ff9b12a046(["decom_ts_week_1.month_classic_eigen"]):::outdated
    x721b6cba1628c845(["decom_ts_week_1.month_classic_strength"]):::outdated --> x88f3687d2c267f4e(["plt_decom_ts_week_1.month_classic_strength"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x88f3687d2c267f4e(["plt_decom_ts_week_1.month_classic_strength"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x88f3687d2c267f4e(["plt_decom_ts_week_1.month_classic_strength"]):::outdated
    x5a026dafb9f9840e["mod_ssa_recon_claim2patient"]:::outdated --> x666e2fe7281e2946["plt_ssa_recon_claim2patient"]:::outdated
    x55e2af9f684b7032>"vizReconSsa"]:::uptodate --> x666e2fe7281e2946["plt_ssa_recon_claim2patient"]:::outdated
    xac3ca7d0385656a2(["decom_ts_week_1.month_classic_n_claim"]):::outdated --> x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::outdated
    x88a329c7ea7a65fe(["decom_ts_day_1.week_classic_strength"]):::outdated --> x4da28536ad53b85f(["plt_decom_ts_day_1.week_classic_strength"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4da28536ad53b85f(["plt_decom_ts_day_1.week_classic_strength"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4da28536ad53b85f(["plt_decom_ts_day_1.week_classic_strength"]):::outdated
    x07ac0b71f920f889>"combineMetrics"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::outdated
    x3902bbed135b0ec7>"getMetrics"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::outdated
    x278d817c06f60e98["iadb_graph"]:::outdated --> xf2831b13ede46eac(["iadb_metrics"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x721b6cba1628c845(["decom_ts_week_1.month_classic_strength"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x721b6cba1628c845(["decom_ts_week_1.month_classic_strength"]):::outdated
    x2a89da525d1cc153>"describe"]:::uptodate --> x005a6c6598235267(["desc_ts"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> x005a6c6598235267(["desc_ts"]):::outdated
    xd9701f9522b636a9(["decom_ts_day_1.week_classic_claim2patient"]):::outdated --> x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x88a329c7ea7a65fe(["decom_ts_day_1.week_classic_strength"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> x88a329c7ea7a65fe(["decom_ts_day_1.week_classic_strength"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x0d663b4f57e06f5c["plt_dot_month"]:::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x0d663b4f57e06f5c["plt_dot_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x0d663b4f57e06f5c["plt_dot_month"]:::outdated
    x31faa9d48477f81b(["ts_diff_week"]):::outdated --> x9a9424cd5083d745["plt_dot_diff_week"]:::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x9a9424cd5083d745["plt_dot_diff_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x9a9424cd5083d745["plt_dot_diff_week"]:::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::outdated
    x72cd3fa746b70917["mod_arima_forecast_eigen"]:::outdated --> x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::outdated
    xab29c0af1a4e1af0>"vizArima"]:::uptodate --> x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x3e1db942d8fb6918(["decom_ts_day_1.week_loess_n_claim"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> x3e1db942d8fb6918(["decom_ts_day_1.week_loess_n_claim"]):::outdated
    x6da2e542198a5d93(["ts_diff_month"]):::outdated --> x9d5535b9d7f421f3["plt_period_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x9d5535b9d7f421f3["plt_period_month"]:::outdated
    x098757b4b84b914a>"vizPeriod"]:::uptodate --> x9d5535b9d7f421f3["plt_period_month"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xac3ca7d0385656a2(["decom_ts_week_1.month_classic_n_claim"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> xac3ca7d0385656a2(["decom_ts_week_1.month_classic_n_claim"]):::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> xb94732c2937f4162["plt_polar_claim2patient"]:::outdated
    x6da2e542198a5d93(["ts_diff_month"]):::outdated --> xb94732c2937f4162["plt_polar_claim2patient"]:::outdated
    xb9f54242cee3597e>"vizPolar"]:::uptodate --> xb94732c2937f4162["plt_polar_claim2patient"]:::outdated
    x4f2d2e559519efe1["mod_arima_claim2patient"]:::outdated --> x11abd7770785b634["mod_arima_eval_claim2patient"]:::outdated
    x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::outdated --> x77e5c1bb6f2886e6(["report_spectral"]):::outdated
    xfbeb60eec79c1dee["mod_ssa_eigen"]:::outdated --> x77e5c1bb6f2886e6(["report_spectral"]):::outdated
    xfff40f8096285418["mod_ssa_n_claim"]:::outdated --> x77e5c1bb6f2886e6(["report_spectral"]):::outdated
    x666e2fe7281e2946["plt_ssa_recon_claim2patient"]:::outdated --> x77e5c1bb6f2886e6(["report_spectral"]):::outdated
    x4e10dc482538715b["plt_ssa_recon_eigen"]:::outdated --> x77e5c1bb6f2886e6(["report_spectral"]):::outdated
    x452ed64020a79729["plt_ssa_recon_n_claim"]:::outdated --> x77e5c1bb6f2886e6(["report_spectral"]):::outdated
    x6da2e542198a5d93(["ts_diff_month"]):::outdated --> x8d4989d190572307["plt_pacf_diff_month"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x8d4989d190572307["plt_pacf_diff_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x8d4989d190572307["plt_pacf_diff_month"]:::outdated
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x9bfe90d7816277ce(["ts_diff2_day"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> x9bfe90d7816277ce(["ts_diff2_day"]):::outdated
    x771a367f0ef7807a>"iterby"]:::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::outdated
    x7514d3a2992ccd63>"splitAtc"]:::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::outdated
    x960707f0c582886a(["tbl_iadb_by_date"]):::outdated --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x0e604d354415ef78(["decom_ts_week_1.month_loess_claim2patient"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x0e604d354415ef78(["decom_ts_week_1.month_loess_claim2patient"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xc058910fe0c21157(["decom_ts_day_1.week_loess_eigen"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> xc058910fe0c21157(["decom_ts_day_1.week_loess_eigen"]):::outdated
    xccc889a3af79aa2f["plt_acf_week"]:::outdated --> xbde164b969460ca6["fig_acf_week"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> xbde164b969460ca6["fig_acf_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xbde164b969460ca6["fig_acf_week"]:::outdated
    x3455a1c44fd0ba64(["decom_ts_month_1.year_loess_eigen"]):::outdated --> x4801de0cb1b805de(["plt_decom_ts_month_1.year_loess_eigen"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4801de0cb1b805de(["plt_decom_ts_month_1.year_loess_eigen"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4801de0cb1b805de(["plt_decom_ts_month_1.year_loess_eigen"]):::outdated
    xf2831b13ede46eac(["iadb_metrics"]):::outdated --> x14bcf0b7ef5959f1(["ts_month"]):::outdated
    x6bbf38eac08a1fe8(["iadb_stats"]):::outdated --> x14bcf0b7ef5959f1(["ts_month"]):::outdated
    x6c212354357aadc8>"mergeTS"]:::uptodate --> x14bcf0b7ef5959f1(["ts_month"]):::outdated
    x2000c60e6c626cec(["decom_ts_month_1.year_classic_strength"]):::outdated --> xdf0b710b05022f8f(["plt_decom_ts_month_1.year_classic_strength"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xdf0b710b05022f8f(["plt_decom_ts_month_1.year_classic_strength"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xdf0b710b05022f8f(["plt_decom_ts_month_1.year_classic_strength"]):::outdated
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> x9abecde5a6409199["ts_diff2_uroot_month"]:::outdated
    x14741661dc71d34f(["ts_diff2_month"]):::outdated --> x9abecde5a6409199["ts_diff2_uroot_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x9abecde5a6409199["ts_diff2_uroot_month"]:::outdated
    xf8272e0666b2c4b7(["decom_ts_day_1.week_loess_claim2patient"]):::outdated --> xd7a44f53b7e1f2b5(["plt_decom_ts_day_1.week_loess_claim2patient"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xd7a44f53b7e1f2b5(["plt_decom_ts_day_1.week_loess_claim2patient"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xd7a44f53b7e1f2b5(["plt_decom_ts_day_1.week_loess_claim2patient"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> xb3f8990b0bb8c5fa["plt_dot_day"]:::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xb3f8990b0bb8c5fa["plt_dot_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xb3f8990b0bb8c5fa["plt_dot_day"]:::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> xb035523f702a18f0["plt_polar_eigen"]:::outdated
    x6da2e542198a5d93(["ts_diff_month"]):::outdated --> xb035523f702a18f0["plt_polar_eigen"]:::outdated
    xb9f54242cee3597e>"vizPolar"]:::uptodate --> xb035523f702a18f0["plt_polar_eigen"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x14e721e34c9c8b1b(["decom_ts_week_1.month_loess_n_claim"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x14e721e34c9c8b1b(["decom_ts_week_1.month_loess_n_claim"]):::outdated
    x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::outdated --> x5a026dafb9f9840e["mod_ssa_recon_claim2patient"]:::outdated
    x530163c6df184499>"reconSsa"]:::uptodate --> x5a026dafb9f9840e["mod_ssa_recon_claim2patient"]:::outdated
    x6da2e542198a5d93(["ts_diff_month"]):::outdated --> xc585414cb0a04329["plt_acf_diff_month"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xc585414cb0a04329["plt_acf_diff_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xc585414cb0a04329["plt_acf_diff_month"]:::outdated
    xc6e289d90e4f347f>"fitArima"]:::uptodate --> x79fa432b43dcafaf["mod_arima_eigen"]:::outdated
    x6c570eed1079677b>"fitModel"]:::uptodate --> x79fa432b43dcafaf["mod_arima_eigen"]:::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> x79fa432b43dcafaf["mod_arima_eigen"]:::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x79fa432b43dcafaf["mod_arima_eigen"]:::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> x6c48091042266f38["plt_acf_day"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x6c48091042266f38["plt_acf_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x6c48091042266f38["plt_acf_day"]:::outdated
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xf24ba0a5fa22e4ad["ts_uroot_day"]:::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> xf24ba0a5fa22e4ad["ts_uroot_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xf24ba0a5fa22e4ad["ts_uroot_day"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x1ed9cd4bb202a9cd(["decom_ts_month_1.year_classic_eigen"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x1ed9cd4bb202a9cd(["decom_ts_month_1.year_classic_eigen"]):::outdated
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xa74557e112499157["ts_diff_uroot_day"]:::outdated
    x685ff5739109ee80(["ts_diff_day"]):::outdated --> xa74557e112499157["ts_diff_uroot_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xa74557e112499157["ts_diff_uroot_day"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x897e8856e62b7088(["decom_ts_day_1.week_classic_n_claim"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> x897e8856e62b7088(["decom_ts_day_1.week_classic_n_claim"]):::outdated
    x87f485f2ede7231a(["decom_ts_day_1.week_classic_eigen"]):::outdated --> x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::outdated
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x31faa9d48477f81b(["ts_diff_week"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x31faa9d48477f81b(["ts_diff_week"]):::outdated
    xc6e289d90e4f347f>"fitArima"]:::uptodate --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::outdated
    x6c570eed1079677b>"fitModel"]:::uptodate --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::outdated
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xd4fc6dffefb838f3["ts_diff2_uroot_week"]:::outdated
    xa81f3ac85c3ab6fc(["ts_diff2_week"]):::outdated --> xd4fc6dffefb838f3["ts_diff2_uroot_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xd4fc6dffefb838f3["ts_diff2_uroot_week"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x4a5cabf4ebd7accb(["decom_ts_day_1.week_loess_strength"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> x4a5cabf4ebd7accb(["decom_ts_day_1.week_loess_strength"]):::outdated
    x9ca1aa7607080a7b>"mkGraph"]:::uptodate --> x278d817c06f60e98["iadb_graph"]:::outdated
    xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::outdated --> x278d817c06f60e98["iadb_graph"]:::outdated
    x6c48091042266f38["plt_acf_day"]:::outdated --> x7142295daf13496f["fig_acf_day"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x7142295daf13496f["fig_acf_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x7142295daf13496f["fig_acf_day"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x2eab2a0f6af8a669(["decom_ts_week_1.month_loess_eigen"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x2eab2a0f6af8a669(["decom_ts_week_1.month_loess_eigen"]):::outdated
    x897e8856e62b7088(["decom_ts_day_1.week_classic_n_claim"]):::outdated --> xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::outdated
    x34ce3d16770ddcf5(["decom_ts_week_1.month_loess_strength"]):::outdated --> xb486ed7c26a92168(["plt_decom_ts_week_1.month_loess_strength"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xb486ed7c26a92168(["plt_decom_ts_week_1.month_loess_strength"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xb486ed7c26a92168(["plt_decom_ts_week_1.month_loess_strength"]):::outdated
    x685ff5739109ee80(["ts_diff_day"]):::outdated --> xb97e67c2f6d8ad03["plt_dot_diff_day"]:::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xb97e67c2f6d8ad03["plt_dot_diff_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xb97e67c2f6d8ad03["plt_dot_diff_day"]:::outdated
    x685ff5739109ee80(["ts_diff_day"]):::outdated --> xe9bba18952d1eff6["plt_period_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xe9bba18952d1eff6["plt_period_day"]:::outdated
    x098757b4b84b914a>"vizPeriod"]:::uptodate --> xe9bba18952d1eff6["plt_period_day"]:::outdated
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xc751146609196dc6["ts_uroot_month"]:::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> xc751146609196dc6["ts_uroot_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xc751146609196dc6["ts_uroot_month"]:::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> xccc889a3af79aa2f["plt_acf_week"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xccc889a3af79aa2f["plt_acf_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xccc889a3af79aa2f["plt_acf_week"]:::outdated
    xcd2ea74d422880aa["mod_ssa_recon_n_claim"]:::outdated --> x452ed64020a79729["plt_ssa_recon_n_claim"]:::outdated
    x55e2af9f684b7032>"vizReconSsa"]:::uptodate --> x452ed64020a79729["plt_ssa_recon_n_claim"]:::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> x7dbb58def017efbe(["report_arima"]):::outdated
    x4f2d2e559519efe1["mod_arima_claim2patient"]:::outdated --> x7dbb58def017efbe(["report_arima"]):::outdated
    x79fa432b43dcafaf["mod_arima_eigen"]:::outdated --> x7dbb58def017efbe(["report_arima"]):::outdated
    x11abd7770785b634["mod_arima_eval_claim2patient"]:::outdated --> x7dbb58def017efbe(["report_arima"]):::outdated
    x91a77d5b4dfa50f4["mod_arima_eval_eigen"]:::outdated --> x7dbb58def017efbe(["report_arima"]):::outdated
    xa43e6b5b1b499bca["mod_arima_eval_n_claim"]:::outdated --> x7dbb58def017efbe(["report_arima"]):::outdated
    x7e1814e57b0b1be4["mod_arima_n_claim"]:::outdated --> x7dbb58def017efbe(["report_arima"]):::outdated
    x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::outdated --> x7dbb58def017efbe(["report_arima"]):::outdated
    x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::outdated --> x7dbb58def017efbe(["report_arima"]):::outdated
    x55a0e476a043137e["plt_arima_forecast_n_claim"]:::outdated --> x7dbb58def017efbe(["report_arima"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x53f054da58185e0c(["decom_ts_month_1.year_loess_claim2patient"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x53f054da58185e0c(["decom_ts_month_1.year_loess_claim2patient"]):::outdated
    x14e721e34c9c8b1b(["decom_ts_week_1.month_loess_n_claim"]):::outdated --> xc396e37111805a84(["plt_decom_ts_week_1.month_loess_n_claim"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xc396e37111805a84(["plt_decom_ts_week_1.month_loess_n_claim"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xc396e37111805a84(["plt_decom_ts_week_1.month_loess_n_claim"]):::outdated
    x0d9b06f0646ca4fd["plt_acf_diff_day"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    xc585414cb0a04329["plt_acf_diff_month"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    x9a2a3b9d04de4370["plt_acf_diff_week"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    xb97e67c2f6d8ad03["plt_dot_diff_day"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    x594417459f28b9f7["plt_dot_diff_month"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    x9a9424cd5083d745["plt_dot_diff_week"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    x5fefb5a0d8750f50["plt_pacf_diff_day"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    x8d4989d190572307["plt_pacf_diff_month"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    x37afaee2bd3e651d["plt_pacf_diff_week"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    xe9bba18952d1eff6["plt_period_day"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    x9d5535b9d7f421f3["plt_period_month"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    x39119b929eabe90e["plt_period_week"]:::outdated --> xb85d303ab56a5a47(["report_seasonality"]):::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::outdated
    x84aa03deac41b190["mod_arima_forecast_claim2patient"]:::outdated --> x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::outdated
    xab29c0af1a4e1af0>"vizArima"]:::uptodate --> x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::outdated
    xf3e78b060469e6a9(["decom_ts_month_1.year_classic_claim2patient"]):::outdated --> xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> xd663dbf13bc7985e["plt_pacf_day"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xd663dbf13bc7985e["plt_pacf_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xd663dbf13bc7985e["plt_pacf_day"]:::outdated
    xcc3fd8f4d6a4b61b(["decom_ts_month_1.year_loess_n_claim"]):::outdated --> xf16e7879fce7a9b9(["plt_decom_ts_month_1.year_loess_n_claim"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xf16e7879fce7a9b9(["plt_decom_ts_month_1.year_loess_n_claim"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xf16e7879fce7a9b9(["plt_decom_ts_month_1.year_loess_n_claim"]):::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> x55a0e476a043137e["plt_arima_forecast_n_claim"]:::outdated
    xdec7d06ab7bbbc50["mod_arima_forecast_n_claim"]:::outdated --> x55a0e476a043137e["plt_arima_forecast_n_claim"]:::outdated
    xab29c0af1a4e1af0>"vizArima"]:::uptodate --> x55a0e476a043137e["plt_arima_forecast_n_claim"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x2000c60e6c626cec(["decom_ts_month_1.year_classic_strength"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x2000c60e6c626cec(["decom_ts_month_1.year_classic_strength"]):::outdated
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> x93ad525b678e411b["ts_diff_uroot_week"]:::outdated
    x31faa9d48477f81b(["ts_diff_week"]):::outdated --> x93ad525b678e411b["ts_diff_uroot_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x93ad525b678e411b["ts_diff_uroot_week"]:::outdated
    x4f2d2e559519efe1["mod_arima_claim2patient"]:::outdated --> x84aa03deac41b190["mod_arima_forecast_claim2patient"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xf3e78b060469e6a9(["decom_ts_month_1.year_classic_claim2patient"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> xf3e78b060469e6a9(["decom_ts_month_1.year_classic_claim2patient"]):::outdated
    xd62f0e429a89e62d(["decom_ts_week_1.month_classic_claim2patient"]):::outdated --> x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> x6f30c82e93f04550["plt_polar_n_claim"]:::outdated
    x6da2e542198a5d93(["ts_diff_month"]):::outdated --> x6f30c82e93f04550["plt_polar_n_claim"]:::outdated
    xb9f54242cee3597e>"vizPolar"]:::uptodate --> x6f30c82e93f04550["plt_polar_n_claim"]:::outdated
    x4a5cabf4ebd7accb(["decom_ts_day_1.week_loess_strength"]):::outdated --> x0908815c91e26243(["plt_decom_ts_day_1.week_loess_strength"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x0908815c91e26243(["plt_decom_ts_day_1.week_loess_strength"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x0908815c91e26243(["plt_decom_ts_day_1.week_loess_strength"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xd62f0e429a89e62d(["decom_ts_week_1.month_classic_claim2patient"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> xd62f0e429a89e62d(["decom_ts_week_1.month_classic_claim2patient"]):::outdated
    xf2831b13ede46eac(["iadb_metrics"]):::outdated --> xe654ad4c04f23a28(["ts_week"]):::outdated
    x6bbf38eac08a1fe8(["iadb_stats"]):::outdated --> xe654ad4c04f23a28(["ts_week"]):::outdated
    x6c212354357aadc8>"mergeTS"]:::uptodate --> xe654ad4c04f23a28(["ts_week"]):::outdated
    xb3f8990b0bb8c5fa["plt_dot_day"]:::outdated --> x5b0c1878c6ce7387["fig_dot_day"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x5b0c1878c6ce7387["fig_dot_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x5b0c1878c6ce7387["fig_dot_day"]:::outdated
    xc058910fe0c21157(["decom_ts_day_1.week_loess_eigen"]):::outdated --> x8d5c69a2dec41c58(["plt_decom_ts_day_1.week_loess_eigen"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x8d5c69a2dec41c58(["plt_decom_ts_day_1.week_loess_eigen"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x8d5c69a2dec41c58(["plt_decom_ts_day_1.week_loess_eigen"]):::outdated
    x6da2e542198a5d93(["ts_diff_month"]):::outdated --> x594417459f28b9f7["plt_dot_diff_month"]:::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x594417459f28b9f7["plt_dot_diff_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x594417459f28b9f7["plt_dot_diff_month"]:::outdated
    xfff40f8096285418["mod_ssa_n_claim"]:::outdated --> xcd2ea74d422880aa["mod_ssa_recon_n_claim"]:::outdated
    x530163c6df184499>"reconSsa"]:::uptodate --> xcd2ea74d422880aa["mod_ssa_recon_n_claim"]:::outdated
    xee05927e7b88ad5d["plt_pacf_week"]:::outdated --> x6984021042b3f101["fig_pacf_week"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x6984021042b3f101["fig_pacf_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x6984021042b3f101["fig_pacf_week"]:::outdated
    x7e1814e57b0b1be4["mod_arima_n_claim"]:::outdated --> xdec7d06ab7bbbc50["mod_arima_forecast_n_claim"]:::outdated
    x4a5693aa168fe170{{"iadb"}}:::uptodate --> xf220e84da6d0ff6f(["tbl_iadb"]):::dispatched
    x8d5064cb2dc0b750>"readIADB"]:::uptodate --> xf220e84da6d0ff6f(["tbl_iadb"]):::dispatched
    x52127149f1444c9e["plt_acf_month"]:::outdated --> x1e581e1515b0bc41["fig_acf_month"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x1e581e1515b0bc41["fig_acf_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x1e581e1515b0bc41["fig_acf_month"]:::outdated
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xf58e1f08339fb674["ts_diff2_uroot_day"]:::outdated
    x9bfe90d7816277ce(["ts_diff2_day"]):::outdated --> xf58e1f08339fb674["ts_diff2_uroot_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xf58e1f08339fb674["ts_diff2_uroot_day"]:::outdated
    xe29768ff9b12a046(["decom_ts_week_1.month_classic_eigen"]):::outdated --> x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::outdated
    x6c570eed1079677b>"fitModel"]:::uptodate --> xfbeb60eec79c1dee["mod_ssa_eigen"]:::outdated
    x7932dde01bed8634>"fitSsa"]:::uptodate --> xfbeb60eec79c1dee["mod_ssa_eigen"]:::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> xfbeb60eec79c1dee["mod_ssa_eigen"]:::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> xfbeb60eec79c1dee["mod_ssa_eigen"]:::outdated
    xf220e84da6d0ff6f(["tbl_iadb"]):::dispatched --> x960707f0c582886a(["tbl_iadb_by_date"]):::outdated
    x3e1db942d8fb6918(["decom_ts_day_1.week_loess_n_claim"]):::outdated --> xbb48420e6e10ad81(["plt_decom_ts_day_1.week_loess_n_claim"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xbb48420e6e10ad81(["plt_decom_ts_day_1.week_loess_n_claim"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xbb48420e6e10ad81(["plt_decom_ts_day_1.week_loess_n_claim"]):::outdated
    xfbeb60eec79c1dee["mod_ssa_eigen"]:::outdated --> x0aa0ece969fa8517["mod_ssa_recon_eigen"]:::outdated
    x530163c6df184499>"reconSsa"]:::uptodate --> x0aa0ece969fa8517["mod_ssa_recon_eigen"]:::outdated
    x0d663b4f57e06f5c["plt_dot_month"]:::outdated --> xf27968c319f369d5["fig_dot_month"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> xf27968c319f369d5["fig_dot_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xf27968c319f369d5["fig_dot_month"]:::outdated
    x0aa0ece969fa8517["mod_ssa_recon_eigen"]:::outdated --> x4e10dc482538715b["plt_ssa_recon_eigen"]:::outdated
    x55e2af9f684b7032>"vizReconSsa"]:::uptodate --> x4e10dc482538715b["plt_ssa_recon_eigen"]:::outdated
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xe9d057717b7c09db["ts_uroot_week"]:::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> xe9d057717b7c09db["ts_uroot_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xe9d057717b7c09db["ts_uroot_week"]:::outdated
    x1ed9cd4bb202a9cd(["decom_ts_month_1.year_classic_eigen"]):::outdated --> x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::outdated
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> xa81f3ac85c3ab6fc(["ts_diff2_week"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> xa81f3ac85c3ab6fc(["ts_diff2_week"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xcc3fd8f4d6a4b61b(["decom_ts_month_1.year_loess_n_claim"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> xcc3fd8f4d6a4b61b(["decom_ts_month_1.year_loess_n_claim"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> xee05927e7b88ad5d["plt_pacf_week"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xee05927e7b88ad5d["plt_pacf_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> xee05927e7b88ad5d["plt_pacf_week"]:::outdated
    x0e604d354415ef78(["decom_ts_week_1.month_loess_claim2patient"]):::outdated --> x3a08a75e6c4bebfd(["plt_decom_ts_week_1.month_loess_claim2patient"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x3a08a75e6c4bebfd(["plt_decom_ts_week_1.month_loess_claim2patient"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x3a08a75e6c4bebfd(["plt_decom_ts_week_1.month_loess_claim2patient"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xf8272e0666b2c4b7(["decom_ts_day_1.week_loess_claim2patient"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> xf8272e0666b2c4b7(["decom_ts_day_1.week_loess_claim2patient"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x3455a1c44fd0ba64(["decom_ts_month_1.year_loess_eigen"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x3455a1c44fd0ba64(["decom_ts_month_1.year_loess_eigen"]):::outdated
    x685ff5739109ee80(["ts_diff_day"]):::outdated --> x0d9b06f0646ca4fd["plt_acf_diff_day"]:::outdated
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x0d9b06f0646ca4fd["plt_acf_diff_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x0d9b06f0646ca4fd["plt_acf_diff_day"]:::outdated
    xd663dbf13bc7985e["plt_pacf_day"]:::outdated --> x91895ac9fc912426["fig_pacf_day"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x91895ac9fc912426["fig_pacf_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x91895ac9fc912426["fig_pacf_day"]:::outdated
    x2eab2a0f6af8a669(["decom_ts_week_1.month_loess_eigen"]):::outdated --> x2868c0cd1863b793(["plt_decom_ts_week_1.month_loess_eigen"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x2868c0cd1863b793(["plt_decom_ts_week_1.month_loess_eigen"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x2868c0cd1863b793(["plt_decom_ts_week_1.month_loess_eigen"]):::outdated
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x685ff5739109ee80(["ts_diff_day"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> x685ff5739109ee80(["ts_diff_day"]):::outdated
    x79fa432b43dcafaf["mod_arima_eigen"]:::outdated --> x72cd3fa746b70917["mod_arima_forecast_eigen"]:::outdated
    xc6e289d90e4f347f>"fitArima"]:::uptodate --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::outdated
    x6c570eed1079677b>"fitModel"]:::uptodate --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::outdated
    x57a05589a58fabfc(["decom_ts_month_1.year_loess_strength"]):::outdated --> xf32dbf53c1b5a9b2(["plt_decom_ts_month_1.year_loess_strength"]):::outdated
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xf32dbf53c1b5a9b2(["plt_decom_ts_month_1.year_loess_strength"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> xf32dbf53c1b5a9b2(["plt_decom_ts_month_1.year_loess_strength"]):::outdated
    x2141e3016fa1f53c["plt_pacf_month"]:::outdated --> x88834797050fcde2["fig_pacf_month"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x88834797050fcde2["fig_pacf_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x88834797050fcde2["fig_pacf_month"]:::outdated
    x15823228216e9e2e["plt_dot_week"]:::outdated --> x710d593c64216c80["fig_dot_week"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x710d593c64216c80["fig_dot_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::dispatched --> x710d593c64216c80["fig_dot_week"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xd9701f9522b636a9(["decom_ts_day_1.week_classic_claim2patient"]):::outdated
    x7ffe35eee48c2674(["ts_day"]):::outdated --> xd9701f9522b636a9(["decom_ts_day_1.week_classic_claim2patient"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x57a05589a58fabfc(["decom_ts_month_1.year_loess_strength"]):::outdated
    x14bcf0b7ef5959f1(["ts_month"]):::outdated --> x57a05589a58fabfc(["decom_ts_month_1.year_loess_strength"]):::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x34ce3d16770ddcf5(["decom_ts_week_1.month_loess_strength"]):::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x34ce3d16770ddcf5(["decom_ts_week_1.month_loess_strength"]):::outdated
    x6c570eed1079677b>"fitModel"]:::uptodate --> x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::outdated
    x7932dde01bed8634>"fitSsa"]:::uptodate --> x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::outdated
    xcd136c75f6948bfd(["med_groups"]):::outdated --> x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::outdated
    xe654ad4c04f23a28(["ts_week"]):::outdated --> x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::outdated
    x6e52cb0f1668cc22(["readme"]):::dispatched --> x6e52cb0f1668cc22(["readme"]):::dispatched
    xea1cdd6f009574c2{{"pkgs_load"}}:::uptodate --> xea1cdd6f009574c2{{"pkgs_load"}}:::uptodate
    x2166607dfe6e75f2{{"funs"}}:::uptodate --> x2166607dfe6e75f2{{"funs"}}:::uptodate
    x2d15849e3198e8d1{{"pkgs"}}:::uptodate --> x2d15849e3198e8d1{{"pkgs"}}:::uptodate
    xfb5278c6bbbf3460>"lsData"]:::uptodate --> xfb5278c6bbbf3460>"lsData"]:::uptodate
    xe1d1bcdb96b9c2dc{{"is_test"}}:::uptodate --> xe1d1bcdb96b9c2dc{{"is_test"}}:::uptodate
    x3ac540af10f1b504{{"iadb_raw"}}:::uptodate --> x3ac540af10f1b504{{"iadb_raw"}}:::uptodate
  end
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef dispatched stroke:#000000,color:#000000,fill:#DC863B;
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 5 stroke-width:0px;
  linkStyle 419 stroke-width:0px;
  linkStyle 420 stroke-width:0px;
  linkStyle 421 stroke-width:0px;
  linkStyle 422 stroke-width:0px;
  linkStyle 423 stroke-width:0px;
  linkStyle 424 stroke-width:0px;
  linkStyle 425 stroke-width:0px;
```
