
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

During startup - Warning messages: 1: Setting LC_COLLATE failed, using
“C” 2: Setting LC_TIME failed, using “C” 3: Setting LC_MESSAGES failed,
using “C” 4: Setting LC_MONETARY failed, using “C”

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x5b3426b4c7fa7dbc([""Started""]):::started
    x5b3426b4c7fa7dbc([""Started""]):::started --- x0a52b03877696646([""Outdated""]):::outdated
    x0a52b03877696646([""Outdated""]):::outdated --- xbf4603d6c2c2ad6b([""Stem""]):::none
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
    x2a89da525d1cc153>"describe"]:::uptodate --> xf1c5dfc78ca50f32["plt_pair"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> xf1c5dfc78ca50f32["plt_pair"]:::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xf1c5dfc78ca50f32["plt_pair"]:::uptodate
    x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate --> x91a77d5b4dfa50f4["mod_arima_eval_eigen"]:::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> xcd136c75f6948bfd(["med_groups"]):::uptodate
    x31faa9d48477f81b(["ts_diff_week"]):::uptodate --> x37afaee2bd3e651d["plt_pacf_diff_week"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x37afaee2bd3e651d["plt_pacf_diff_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x37afaee2bd3e651d["plt_pacf_diff_week"]:::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x6da2e542198a5d93(["ts_diff_month"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x6da2e542198a5d93(["ts_diff_month"]):::uptodate
    x685ff5739109ee80(["ts_diff_day"]):::uptodate --> x5fefb5a0d8750f50["plt_pacf_diff_day"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x5fefb5a0d8750f50["plt_pacf_diff_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x5fefb5a0d8750f50["plt_pacf_diff_day"]:::uptodate
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> x117e2dedb4be160a["ts_diff_uroot_month"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> x117e2dedb4be160a["ts_diff_uroot_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x117e2dedb4be160a["ts_diff_uroot_month"]:::uptodate
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
    x31faa9d48477f81b(["ts_diff_week"]):::uptodate --> x39119b929eabe90e["plt_period_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x39119b929eabe90e["plt_period_week"]:::uptodate
    x098757b4b84b914a>"vizPeriod"]:::uptodate --> x39119b929eabe90e["plt_period_week"]:::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x2141e3016fa1f53c["plt_pacf_month"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x2141e3016fa1f53c["plt_pacf_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x2141e3016fa1f53c["plt_pacf_month"]:::uptodate
    x6c570eed1079677b>"fitModel"]:::uptodate --> xfff40f8096285418["mod_ssa_n_claim"]:::uptodate
    x7932dde01bed8634>"fitSsa"]:::uptodate --> xfff40f8096285418["mod_ssa_n_claim"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> xfff40f8096285418["mod_ssa_n_claim"]:::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xfff40f8096285418["mod_ssa_n_claim"]:::uptodate
    x07ac0b71f920f889>"combineMetrics"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    xc082a51377a349bf>"fieldSummary"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    x53f054da58185e0c(["decom_ts_month_1.year_loess_claim2patient"]):::uptodate --> x3bf481d8364be564(["plt_decom_ts_month_1.year_loess_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x3bf481d8364be564(["plt_decom_ts_month_1.year_loess_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x3bf481d8364be564(["plt_decom_ts_month_1.year_loess_claim2patient"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x52127149f1444c9e["plt_acf_month"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x52127149f1444c9e["plt_acf_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x52127149f1444c9e["plt_acf_month"]:::uptodate
    x177fd622fb419be5(["decom_ts_month_1.year_classic_n_claim"]):::uptodate --> xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xa68da955dfe639e1(["plt_decom_ts_month_1.year_classic_n_claim"]):::uptodate
    xf2831b13ede46eac(["iadb_metrics"]):::uptodate --> x7ffe35eee48c2674(["ts_day"]):::uptodate
    x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate --> x7ffe35eee48c2674(["ts_day"]):::uptodate
    x6c212354357aadc8>"mergeTS"]:::uptodate --> x7ffe35eee48c2674(["ts_day"]):::uptodate
    x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate --> xa43e6b5b1b499bca["mod_arima_eval_n_claim"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x87f485f2ede7231a(["decom_ts_day_1.week_classic_eigen"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x87f485f2ede7231a(["decom_ts_day_1.week_classic_eigen"]):::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x14741661dc71d34f(["ts_diff2_month"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x14741661dc71d34f(["ts_diff2_month"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x15823228216e9e2e["plt_dot_week"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x15823228216e9e2e["plt_dot_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x15823228216e9e2e["plt_dot_week"]:::uptodate
    x31faa9d48477f81b(["ts_diff_week"]):::uptodate --> x9a2a3b9d04de4370["plt_acf_diff_week"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x9a2a3b9d04de4370["plt_acf_diff_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x9a2a3b9d04de4370["plt_acf_diff_week"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x177fd622fb419be5(["decom_ts_month_1.year_classic_n_claim"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x177fd622fb419be5(["decom_ts_month_1.year_classic_n_claim"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xe29768ff9b12a046(["decom_ts_week_1.month_classic_eigen"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xe29768ff9b12a046(["decom_ts_week_1.month_classic_eigen"]):::uptodate
    x721b6cba1628c845(["decom_ts_week_1.month_classic_strength"]):::uptodate --> x88f3687d2c267f4e(["plt_decom_ts_week_1.month_classic_strength"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x88f3687d2c267f4e(["plt_decom_ts_week_1.month_classic_strength"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x88f3687d2c267f4e(["plt_decom_ts_week_1.month_classic_strength"]):::uptodate
    x5a026dafb9f9840e["mod_ssa_recon_claim2patient"]:::uptodate --> x666e2fe7281e2946["plt_ssa_recon_claim2patient"]:::uptodate
    x55e2af9f684b7032>"vizReconSsa"]:::uptodate --> x666e2fe7281e2946["plt_ssa_recon_claim2patient"]:::uptodate
    xac3ca7d0385656a2(["decom_ts_week_1.month_classic_n_claim"]):::uptodate --> x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x20d431b5767c5bc3(["plt_decom_ts_week_1.month_classic_n_claim"]):::uptodate
    x88a329c7ea7a65fe(["decom_ts_day_1.week_classic_strength"]):::uptodate --> x4da28536ad53b85f(["plt_decom_ts_day_1.week_classic_strength"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4da28536ad53b85f(["plt_decom_ts_day_1.week_classic_strength"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4da28536ad53b85f(["plt_decom_ts_day_1.week_classic_strength"]):::uptodate
    x07ac0b71f920f889>"combineMetrics"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x3902bbed135b0ec7>"getMetrics"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x278d817c06f60e98["iadb_graph"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x721b6cba1628c845(["decom_ts_week_1.month_classic_strength"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x721b6cba1628c845(["decom_ts_week_1.month_classic_strength"]):::uptodate
    x2a89da525d1cc153>"describe"]:::uptodate --> x005a6c6598235267(["desc_ts"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x005a6c6598235267(["desc_ts"]):::uptodate
    xd9701f9522b636a9(["decom_ts_day_1.week_classic_claim2patient"]):::uptodate --> x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4dc0972a469a3335(["plt_decom_ts_day_1.week_classic_claim2patient"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x88a329c7ea7a65fe(["decom_ts_day_1.week_classic_strength"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x88a329c7ea7a65fe(["decom_ts_day_1.week_classic_strength"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x0d663b4f57e06f5c["plt_dot_month"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x0d663b4f57e06f5c["plt_dot_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x0d663b4f57e06f5c["plt_dot_month"]:::uptodate
    x31faa9d48477f81b(["ts_diff_week"]):::uptodate --> x9a9424cd5083d745["plt_dot_diff_week"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x9a9424cd5083d745["plt_dot_diff_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x9a9424cd5083d745["plt_dot_diff_week"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::uptodate
    x72cd3fa746b70917["mod_arima_forecast_eigen"]:::uptodate --> x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::uptodate
    xab29c0af1a4e1af0>"vizArima"]:::uptodate --> x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x3e1db942d8fb6918(["decom_ts_day_1.week_loess_n_claim"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x3e1db942d8fb6918(["decom_ts_day_1.week_loess_n_claim"]):::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> x9d5535b9d7f421f3["plt_period_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x9d5535b9d7f421f3["plt_period_month"]:::uptodate
    x098757b4b84b914a>"vizPeriod"]:::uptodate --> x9d5535b9d7f421f3["plt_period_month"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xac3ca7d0385656a2(["decom_ts_week_1.month_classic_n_claim"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xac3ca7d0385656a2(["decom_ts_week_1.month_classic_n_claim"]):::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> xb94732c2937f4162["plt_polar_claim2patient"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> xb94732c2937f4162["plt_polar_claim2patient"]:::uptodate
    xb9f54242cee3597e>"vizPolar"]:::uptodate --> xb94732c2937f4162["plt_polar_claim2patient"]:::uptodate
    x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate --> x11abd7770785b634["mod_arima_eval_claim2patient"]:::uptodate
    x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::uptodate --> x77e5c1bb6f2886e6(["report_spectral"]):::uptodate
    xfbeb60eec79c1dee["mod_ssa_eigen"]:::uptodate --> x77e5c1bb6f2886e6(["report_spectral"]):::uptodate
    xfff40f8096285418["mod_ssa_n_claim"]:::uptodate --> x77e5c1bb6f2886e6(["report_spectral"]):::uptodate
    x666e2fe7281e2946["plt_ssa_recon_claim2patient"]:::uptodate --> x77e5c1bb6f2886e6(["report_spectral"]):::uptodate
    x4e10dc482538715b["plt_ssa_recon_eigen"]:::uptodate --> x77e5c1bb6f2886e6(["report_spectral"]):::uptodate
    x452ed64020a79729["plt_ssa_recon_n_claim"]:::uptodate --> x77e5c1bb6f2886e6(["report_spectral"]):::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> x8d4989d190572307["plt_pacf_diff_month"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x8d4989d190572307["plt_pacf_diff_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x8d4989d190572307["plt_pacf_diff_month"]:::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x9bfe90d7816277ce(["ts_diff2_day"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x9bfe90d7816277ce(["ts_diff2_day"]):::uptodate
    x771a367f0ef7807a>"iterby"]:::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x7514d3a2992ccd63>"splitAtc"]:::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x960707f0c582886a(["tbl_iadb_by_date"]):::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x0e604d354415ef78(["decom_ts_week_1.month_loess_claim2patient"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x0e604d354415ef78(["decom_ts_week_1.month_loess_claim2patient"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xc058910fe0c21157(["decom_ts_day_1.week_loess_eigen"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xc058910fe0c21157(["decom_ts_day_1.week_loess_eigen"]):::uptodate
    xccc889a3af79aa2f["plt_acf_week"]:::uptodate --> xbde164b969460ca6["fig_acf_week"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> xbde164b969460ca6["fig_acf_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xbde164b969460ca6["fig_acf_week"]:::outdated
    x3455a1c44fd0ba64(["decom_ts_month_1.year_loess_eigen"]):::uptodate --> x4801de0cb1b805de(["plt_decom_ts_month_1.year_loess_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4801de0cb1b805de(["plt_decom_ts_month_1.year_loess_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4801de0cb1b805de(["plt_decom_ts_month_1.year_loess_eigen"]):::uptodate
    xf2831b13ede46eac(["iadb_metrics"]):::uptodate --> x14bcf0b7ef5959f1(["ts_month"]):::uptodate
    x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate --> x14bcf0b7ef5959f1(["ts_month"]):::uptodate
    x6c212354357aadc8>"mergeTS"]:::uptodate --> x14bcf0b7ef5959f1(["ts_month"]):::uptodate
    x2000c60e6c626cec(["decom_ts_month_1.year_classic_strength"]):::uptodate --> xdf0b710b05022f8f(["plt_decom_ts_month_1.year_classic_strength"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xdf0b710b05022f8f(["plt_decom_ts_month_1.year_classic_strength"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xdf0b710b05022f8f(["plt_decom_ts_month_1.year_classic_strength"]):::uptodate
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> x9abecde5a6409199["ts_diff2_uroot_month"]:::uptodate
    x14741661dc71d34f(["ts_diff2_month"]):::uptodate --> x9abecde5a6409199["ts_diff2_uroot_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x9abecde5a6409199["ts_diff2_uroot_month"]:::uptodate
    xf8272e0666b2c4b7(["decom_ts_day_1.week_loess_claim2patient"]):::uptodate --> xd7a44f53b7e1f2b5(["plt_decom_ts_day_1.week_loess_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xd7a44f53b7e1f2b5(["plt_decom_ts_day_1.week_loess_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xd7a44f53b7e1f2b5(["plt_decom_ts_day_1.week_loess_claim2patient"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xb3f8990b0bb8c5fa["plt_dot_day"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xb3f8990b0bb8c5fa["plt_dot_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xb3f8990b0bb8c5fa["plt_dot_day"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> xb035523f702a18f0["plt_polar_eigen"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> xb035523f702a18f0["plt_polar_eigen"]:::uptodate
    xb9f54242cee3597e>"vizPolar"]:::uptodate --> xb035523f702a18f0["plt_polar_eigen"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x14e721e34c9c8b1b(["decom_ts_week_1.month_loess_n_claim"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x14e721e34c9c8b1b(["decom_ts_week_1.month_loess_n_claim"]):::uptodate
    x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::uptodate --> x5a026dafb9f9840e["mod_ssa_recon_claim2patient"]:::uptodate
    x530163c6df184499>"reconSsa"]:::uptodate --> x5a026dafb9f9840e["mod_ssa_recon_claim2patient"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> xc585414cb0a04329["plt_acf_diff_month"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xc585414cb0a04329["plt_acf_diff_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xc585414cb0a04329["plt_acf_diff_month"]:::uptodate
    xc6e289d90e4f347f>"fitArima"]:::uptodate --> x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate
    x6c570eed1079677b>"fitModel"]:::uptodate --> x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x6c48091042266f38["plt_acf_day"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x6c48091042266f38["plt_acf_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x6c48091042266f38["plt_acf_day"]:::uptodate
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xf24ba0a5fa22e4ad["ts_uroot_day"]:::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xf24ba0a5fa22e4ad["ts_uroot_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xf24ba0a5fa22e4ad["ts_uroot_day"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x1ed9cd4bb202a9cd(["decom_ts_month_1.year_classic_eigen"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x1ed9cd4bb202a9cd(["decom_ts_month_1.year_classic_eigen"]):::uptodate
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xa74557e112499157["ts_diff_uroot_day"]:::uptodate
    x685ff5739109ee80(["ts_diff_day"]):::uptodate --> xa74557e112499157["ts_diff_uroot_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xa74557e112499157["ts_diff_uroot_day"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x897e8856e62b7088(["decom_ts_day_1.week_classic_n_claim"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x897e8856e62b7088(["decom_ts_day_1.week_classic_n_claim"]):::uptodate
    x87f485f2ede7231a(["decom_ts_day_1.week_classic_eigen"]):::uptodate --> x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x4b4f913cb18cc09a(["plt_decom_ts_day_1.week_classic_eigen"]):::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x31faa9d48477f81b(["ts_diff_week"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x31faa9d48477f81b(["ts_diff_week"]):::uptodate
    xc6e289d90e4f347f>"fitArima"]:::uptodate --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate
    x6c570eed1079677b>"fitModel"]:::uptodate --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xd4fc6dffefb838f3["ts_diff2_uroot_week"]:::uptodate
    xa81f3ac85c3ab6fc(["ts_diff2_week"]):::uptodate --> xd4fc6dffefb838f3["ts_diff2_uroot_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xd4fc6dffefb838f3["ts_diff2_uroot_week"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x4a5cabf4ebd7accb(["decom_ts_day_1.week_loess_strength"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x4a5cabf4ebd7accb(["decom_ts_day_1.week_loess_strength"]):::uptodate
    x9ca1aa7607080a7b>"mkGraph"]:::uptodate --> x278d817c06f60e98["iadb_graph"]:::uptodate
    xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate --> x278d817c06f60e98["iadb_graph"]:::uptodate
    x6c48091042266f38["plt_acf_day"]:::uptodate --> x7142295daf13496f["fig_acf_day"]:::started
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x7142295daf13496f["fig_acf_day"]:::started
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x7142295daf13496f["fig_acf_day"]:::started
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x2eab2a0f6af8a669(["decom_ts_week_1.month_loess_eigen"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x2eab2a0f6af8a669(["decom_ts_week_1.month_loess_eigen"]):::uptodate
    x897e8856e62b7088(["decom_ts_day_1.week_classic_n_claim"]):::uptodate --> xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xc91cfe6f7292e4b4(["plt_decom_ts_day_1.week_classic_n_claim"]):::uptodate
    x34ce3d16770ddcf5(["decom_ts_week_1.month_loess_strength"]):::uptodate --> xb486ed7c26a92168(["plt_decom_ts_week_1.month_loess_strength"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xb486ed7c26a92168(["plt_decom_ts_week_1.month_loess_strength"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xb486ed7c26a92168(["plt_decom_ts_week_1.month_loess_strength"]):::uptodate
    x685ff5739109ee80(["ts_diff_day"]):::uptodate --> xb97e67c2f6d8ad03["plt_dot_diff_day"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xb97e67c2f6d8ad03["plt_dot_diff_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xb97e67c2f6d8ad03["plt_dot_diff_day"]:::uptodate
    x685ff5739109ee80(["ts_diff_day"]):::uptodate --> xe9bba18952d1eff6["plt_period_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xe9bba18952d1eff6["plt_period_day"]:::uptodate
    x098757b4b84b914a>"vizPeriod"]:::uptodate --> xe9bba18952d1eff6["plt_period_day"]:::uptodate
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xc751146609196dc6["ts_uroot_month"]:::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> xc751146609196dc6["ts_uroot_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xc751146609196dc6["ts_uroot_month"]:::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xccc889a3af79aa2f["plt_acf_week"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xccc889a3af79aa2f["plt_acf_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xccc889a3af79aa2f["plt_acf_week"]:::uptodate
    xcd2ea74d422880aa["mod_ssa_recon_n_claim"]:::uptodate --> x452ed64020a79729["plt_ssa_recon_n_claim"]:::uptodate
    x55e2af9f684b7032>"vizReconSsa"]:::uptodate --> x452ed64020a79729["plt_ssa_recon_n_claim"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x7dbb58def017efbe(["report_arima"]):::uptodate
    x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::uptodate
    x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::uptodate
    x11abd7770785b634["mod_arima_eval_claim2patient"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::uptodate
    x91a77d5b4dfa50f4["mod_arima_eval_eigen"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::uptodate
    xa43e6b5b1b499bca["mod_arima_eval_n_claim"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::uptodate
    x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::uptodate
    x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::uptodate
    x6eb2cd606ce0984c["plt_arima_forecast_eigen"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::uptodate
    x55a0e476a043137e["plt_arima_forecast_n_claim"]:::uptodate --> x7dbb58def017efbe(["report_arima"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x53f054da58185e0c(["decom_ts_month_1.year_loess_claim2patient"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x53f054da58185e0c(["decom_ts_month_1.year_loess_claim2patient"]):::uptodate
    x14e721e34c9c8b1b(["decom_ts_week_1.month_loess_n_claim"]):::uptodate --> xc396e37111805a84(["plt_decom_ts_week_1.month_loess_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xc396e37111805a84(["plt_decom_ts_week_1.month_loess_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xc396e37111805a84(["plt_decom_ts_week_1.month_loess_n_claim"]):::uptodate
    x0d9b06f0646ca4fd["plt_acf_diff_day"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    xc585414cb0a04329["plt_acf_diff_month"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x9a2a3b9d04de4370["plt_acf_diff_week"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    xb97e67c2f6d8ad03["plt_dot_diff_day"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x594417459f28b9f7["plt_dot_diff_month"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x9a9424cd5083d745["plt_dot_diff_week"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x5fefb5a0d8750f50["plt_pacf_diff_day"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x8d4989d190572307["plt_pacf_diff_month"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x37afaee2bd3e651d["plt_pacf_diff_week"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    xe9bba18952d1eff6["plt_period_day"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x9d5535b9d7f421f3["plt_period_month"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    x39119b929eabe90e["plt_period_week"]:::uptodate --> xb85d303ab56a5a47(["report_seasonality"]):::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::uptodate
    x84aa03deac41b190["mod_arima_forecast_claim2patient"]:::uptodate --> x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::uptodate
    xab29c0af1a4e1af0>"vizArima"]:::uptodate --> x8ae03bd67401026c["plt_arima_forecast_claim2patient"]:::uptodate
    xf3e78b060469e6a9(["decom_ts_month_1.year_classic_claim2patient"]):::uptodate --> xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xa7bbabbf1f5a1178(["plt_decom_ts_month_1.year_classic_claim2patient"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xd663dbf13bc7985e["plt_pacf_day"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xd663dbf13bc7985e["plt_pacf_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xd663dbf13bc7985e["plt_pacf_day"]:::uptodate
    xcc3fd8f4d6a4b61b(["decom_ts_month_1.year_loess_n_claim"]):::uptodate --> xf16e7879fce7a9b9(["plt_decom_ts_month_1.year_loess_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xf16e7879fce7a9b9(["plt_decom_ts_month_1.year_loess_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xf16e7879fce7a9b9(["plt_decom_ts_month_1.year_loess_n_claim"]):::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x55a0e476a043137e["plt_arima_forecast_n_claim"]:::uptodate
    xdec7d06ab7bbbc50["mod_arima_forecast_n_claim"]:::uptodate --> x55a0e476a043137e["plt_arima_forecast_n_claim"]:::uptodate
    xab29c0af1a4e1af0>"vizArima"]:::uptodate --> x55a0e476a043137e["plt_arima_forecast_n_claim"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x2000c60e6c626cec(["decom_ts_month_1.year_classic_strength"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x2000c60e6c626cec(["decom_ts_month_1.year_classic_strength"]):::uptodate
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> x93ad525b678e411b["ts_diff_uroot_week"]:::uptodate
    x31faa9d48477f81b(["ts_diff_week"]):::uptodate --> x93ad525b678e411b["ts_diff_uroot_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x93ad525b678e411b["ts_diff_uroot_week"]:::uptodate
    x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate --> x84aa03deac41b190["mod_arima_forecast_claim2patient"]:::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xf3e78b060469e6a9(["decom_ts_month_1.year_classic_claim2patient"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> xf3e78b060469e6a9(["decom_ts_month_1.year_classic_claim2patient"]):::uptodate
    xd62f0e429a89e62d(["decom_ts_week_1.month_classic_claim2patient"]):::uptodate --> x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x0ea926d06006d949(["plt_decom_ts_week_1.month_classic_claim2patient"]):::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x6f30c82e93f04550["plt_polar_n_claim"]:::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> x6f30c82e93f04550["plt_polar_n_claim"]:::uptodate
    xb9f54242cee3597e>"vizPolar"]:::uptodate --> x6f30c82e93f04550["plt_polar_n_claim"]:::uptodate
    x4a5cabf4ebd7accb(["decom_ts_day_1.week_loess_strength"]):::uptodate --> x0908815c91e26243(["plt_decom_ts_day_1.week_loess_strength"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x0908815c91e26243(["plt_decom_ts_day_1.week_loess_strength"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x0908815c91e26243(["plt_decom_ts_day_1.week_loess_strength"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xd62f0e429a89e62d(["decom_ts_week_1.month_classic_claim2patient"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xd62f0e429a89e62d(["decom_ts_week_1.month_classic_claim2patient"]):::uptodate
    xf2831b13ede46eac(["iadb_metrics"]):::uptodate --> xe654ad4c04f23a28(["ts_week"]):::uptodate
    x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate --> xe654ad4c04f23a28(["ts_week"]):::uptodate
    x6c212354357aadc8>"mergeTS"]:::uptodate --> xe654ad4c04f23a28(["ts_week"]):::uptodate
    xb3f8990b0bb8c5fa["plt_dot_day"]:::uptodate --> x5b0c1878c6ce7387["fig_dot_day"]:::started
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x5b0c1878c6ce7387["fig_dot_day"]:::started
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x5b0c1878c6ce7387["fig_dot_day"]:::started
    xc058910fe0c21157(["decom_ts_day_1.week_loess_eigen"]):::uptodate --> x8d5c69a2dec41c58(["plt_decom_ts_day_1.week_loess_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x8d5c69a2dec41c58(["plt_decom_ts_day_1.week_loess_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x8d5c69a2dec41c58(["plt_decom_ts_day_1.week_loess_eigen"]):::uptodate
    x6da2e542198a5d93(["ts_diff_month"]):::uptodate --> x594417459f28b9f7["plt_dot_diff_month"]:::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x594417459f28b9f7["plt_dot_diff_month"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x594417459f28b9f7["plt_dot_diff_month"]:::uptodate
    xfff40f8096285418["mod_ssa_n_claim"]:::uptodate --> xcd2ea74d422880aa["mod_ssa_recon_n_claim"]:::uptodate
    x530163c6df184499>"reconSsa"]:::uptodate --> xcd2ea74d422880aa["mod_ssa_recon_n_claim"]:::uptodate
    xee05927e7b88ad5d["plt_pacf_week"]:::uptodate --> x6984021042b3f101["fig_pacf_week"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x6984021042b3f101["fig_pacf_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x6984021042b3f101["fig_pacf_week"]:::outdated
    x7e1814e57b0b1be4["mod_arima_n_claim"]:::uptodate --> xdec7d06ab7bbbc50["mod_arima_forecast_n_claim"]:::uptodate
    x4a5693aa168fe170{{"iadb"}}:::uptodate --> xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate
    x8d5064cb2dc0b750>"readIADB"]:::uptodate --> xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate
    x52127149f1444c9e["plt_acf_month"]:::uptodate --> x1e581e1515b0bc41["fig_acf_month"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x1e581e1515b0bc41["fig_acf_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x1e581e1515b0bc41["fig_acf_month"]:::outdated
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xf58e1f08339fb674["ts_diff2_uroot_day"]:::uptodate
    x9bfe90d7816277ce(["ts_diff2_day"]):::uptodate --> xf58e1f08339fb674["ts_diff2_uroot_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xf58e1f08339fb674["ts_diff2_uroot_day"]:::uptodate
    xe29768ff9b12a046(["decom_ts_week_1.month_classic_eigen"]):::uptodate --> x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x434d3238aa3a615c(["plt_decom_ts_week_1.month_classic_eigen"]):::uptodate
    x6c570eed1079677b>"fitModel"]:::uptodate --> xfbeb60eec79c1dee["mod_ssa_eigen"]:::uptodate
    x7932dde01bed8634>"fitSsa"]:::uptodate --> xfbeb60eec79c1dee["mod_ssa_eigen"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> xfbeb60eec79c1dee["mod_ssa_eigen"]:::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xfbeb60eec79c1dee["mod_ssa_eigen"]:::uptodate
    xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate --> x960707f0c582886a(["tbl_iadb_by_date"]):::uptodate
    x3e1db942d8fb6918(["decom_ts_day_1.week_loess_n_claim"]):::uptodate --> xbb48420e6e10ad81(["plt_decom_ts_day_1.week_loess_n_claim"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xbb48420e6e10ad81(["plt_decom_ts_day_1.week_loess_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xbb48420e6e10ad81(["plt_decom_ts_day_1.week_loess_n_claim"]):::uptodate
    xfbeb60eec79c1dee["mod_ssa_eigen"]:::uptodate --> x0aa0ece969fa8517["mod_ssa_recon_eigen"]:::uptodate
    x530163c6df184499>"reconSsa"]:::uptodate --> x0aa0ece969fa8517["mod_ssa_recon_eigen"]:::uptodate
    x0d663b4f57e06f5c["plt_dot_month"]:::uptodate --> xf27968c319f369d5["fig_dot_month"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> xf27968c319f369d5["fig_dot_month"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xf27968c319f369d5["fig_dot_month"]:::outdated
    x0aa0ece969fa8517["mod_ssa_recon_eigen"]:::uptodate --> x4e10dc482538715b["plt_ssa_recon_eigen"]:::uptodate
    x55e2af9f684b7032>"vizReconSsa"]:::uptodate --> x4e10dc482538715b["plt_ssa_recon_eigen"]:::uptodate
    x3e87573bd30d006b>"evalUnitRoot"]:::uptodate --> xe9d057717b7c09db["ts_uroot_week"]:::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xe9d057717b7c09db["ts_uroot_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xe9d057717b7c09db["ts_uroot_week"]:::uptodate
    x1ed9cd4bb202a9cd(["decom_ts_month_1.year_classic_eigen"]):::uptodate --> x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x55cf2497ae5dd26c(["plt_decom_ts_month_1.year_classic_eigen"]):::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> xa81f3ac85c3ab6fc(["ts_diff2_week"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xa81f3ac85c3ab6fc(["ts_diff2_week"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xcc3fd8f4d6a4b61b(["decom_ts_month_1.year_loess_n_claim"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> xcc3fd8f4d6a4b61b(["decom_ts_month_1.year_loess_n_claim"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> xee05927e7b88ad5d["plt_pacf_week"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> xee05927e7b88ad5d["plt_pacf_week"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> xee05927e7b88ad5d["plt_pacf_week"]:::uptodate
    x0e604d354415ef78(["decom_ts_week_1.month_loess_claim2patient"]):::uptodate --> x3a08a75e6c4bebfd(["plt_decom_ts_week_1.month_loess_claim2patient"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x3a08a75e6c4bebfd(["plt_decom_ts_week_1.month_loess_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x3a08a75e6c4bebfd(["plt_decom_ts_week_1.month_loess_claim2patient"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xf8272e0666b2c4b7(["decom_ts_day_1.week_loess_claim2patient"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xf8272e0666b2c4b7(["decom_ts_day_1.week_loess_claim2patient"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x3455a1c44fd0ba64(["decom_ts_month_1.year_loess_eigen"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x3455a1c44fd0ba64(["decom_ts_month_1.year_loess_eigen"]):::uptodate
    x685ff5739109ee80(["ts_diff_day"]):::uptodate --> x0d9b06f0646ca4fd["plt_acf_diff_day"]:::uptodate
    xfc9293f408401e5e>"vizAutocor"]:::uptodate --> x0d9b06f0646ca4fd["plt_acf_diff_day"]:::uptodate
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x0d9b06f0646ca4fd["plt_acf_diff_day"]:::uptodate
    xd663dbf13bc7985e["plt_pacf_day"]:::uptodate --> x91895ac9fc912426["fig_pacf_day"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x91895ac9fc912426["fig_pacf_day"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x91895ac9fc912426["fig_pacf_day"]:::outdated
    x2eab2a0f6af8a669(["decom_ts_week_1.month_loess_eigen"]):::uptodate --> x2868c0cd1863b793(["plt_decom_ts_week_1.month_loess_eigen"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x2868c0cd1863b793(["plt_decom_ts_week_1.month_loess_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x2868c0cd1863b793(["plt_decom_ts_week_1.month_loess_eigen"]):::uptodate
    x484af6f82192f2e9>"timeDiff"]:::uptodate --> x685ff5739109ee80(["ts_diff_day"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> x685ff5739109ee80(["ts_diff_day"]):::uptodate
    x79fa432b43dcafaf["mod_arima_eigen"]:::uptodate --> x72cd3fa746b70917["mod_arima_forecast_eigen"]:::uptodate
    xc6e289d90e4f347f>"fitArima"]:::uptodate --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate
    x6c570eed1079677b>"fitModel"]:::uptodate --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x4f2d2e559519efe1["mod_arima_claim2patient"]:::uptodate
    x57a05589a58fabfc(["decom_ts_month_1.year_loess_strength"]):::uptodate --> xf32dbf53c1b5a9b2(["plt_decom_ts_month_1.year_loess_strength"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xf32dbf53c1b5a9b2(["plt_decom_ts_month_1.year_loess_strength"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xf32dbf53c1b5a9b2(["plt_decom_ts_month_1.year_loess_strength"]):::uptodate
    x2141e3016fa1f53c["plt_pacf_month"]:::uptodate --> x88834797050fcde2["fig_pacf_month"]:::started
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x88834797050fcde2["fig_pacf_month"]:::started
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x88834797050fcde2["fig_pacf_month"]:::started
    x15823228216e9e2e["plt_dot_week"]:::uptodate --> x710d593c64216c80["fig_dot_week"]:::outdated
    x0e2a1e9ee6890aa6>"saveFig"]:::uptodate --> x710d593c64216c80["fig_dot_week"]:::outdated
    x9544603ba0a3eba6(["vizDotParams"]):::uptodate --> x710d593c64216c80["fig_dot_week"]:::outdated
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> xd9701f9522b636a9(["decom_ts_day_1.week_classic_claim2patient"]):::uptodate
    x7ffe35eee48c2674(["ts_day"]):::uptodate --> xd9701f9522b636a9(["decom_ts_day_1.week_classic_claim2patient"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x57a05589a58fabfc(["decom_ts_month_1.year_loess_strength"]):::uptodate
    x14bcf0b7ef5959f1(["ts_month"]):::uptodate --> x57a05589a58fabfc(["decom_ts_month_1.year_loess_strength"]):::uptodate
    x6f31b4097fc37fb5>"timeDecom"]:::uptodate --> x34ce3d16770ddcf5(["decom_ts_week_1.month_loess_strength"]):::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x34ce3d16770ddcf5(["decom_ts_week_1.month_loess_strength"]):::uptodate
    x6c570eed1079677b>"fitModel"]:::uptodate --> x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::uptodate
    x7932dde01bed8634>"fitSsa"]:::uptodate --> x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::uptodate
    xcd136c75f6948bfd(["med_groups"]):::uptodate --> x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::uptodate
    xe654ad4c04f23a28(["ts_week"]):::uptodate --> x3f3f5a0c614e32c5["mod_ssa_claim2patient"]:::uptodate
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
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
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
