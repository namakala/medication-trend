
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
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x0a52b03877696646([""Outdated""]):::outdated
    x0a52b03877696646([""Outdated""]):::outdated --- x5b3426b4c7fa7dbc([""Started""]):::started
    x5b3426b4c7fa7dbc([""Started""]):::started --- x4b0c520b8bc07c5b([""Errored""]):::errored
    x4b0c520b8bc07c5b([""Errored""]):::errored --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- x70a5fa6bea6f298d[""Pattern""]:::none
    x70a5fa6bea6f298d[""Pattern""]:::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    xec523c05a7988872>"pairByRow"]:::uptodate --> x970b27788a81a7b0>"mkMatrix"]:::uptodate
    x4e58fb85b5f553b2>"groupAtc"]:::uptodate --> x7514d3a2992ccd63>"splitAtc"]:::uptodate
    xaba6069a563b12e8>"getNeuroMeds"]:::uptodate --> xc04d85957c4a84d0>"setGroupFactor"]:::uptodate
    xaba6069a563b12e8>"getNeuroMeds"]:::uptodate --> x6c212354357aadc8>"mergeTS"]:::uptodate
    xc366d1d8806979f6>"genLabel"]:::uptodate --> x970b27788a81a7b0>"mkMatrix"]:::uptodate
    x970b27788a81a7b0>"mkMatrix"]:::uptodate --> x9ca1aa7607080a7b>"mkGraph"]:::uptodate
    xc04d85957c4a84d0>"setGroupFactor"]:::uptodate --> x6c212354357aadc8>"mergeTS"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x2936b3ced15b65d2["iadb_decom_1.week_classic_pagerank"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x2936b3ced15b65d2["iadb_decom_1.week_classic_pagerank"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x2936b3ced15b65d2["iadb_decom_1.week_classic_pagerank"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xf6fdcadf5a2ee88a["iadb_decom_3.month_classic_n_claim"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xf6fdcadf5a2ee88a["iadb_decom_3.month_classic_n_claim"]:::outdated
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xf6fdcadf5a2ee88a["iadb_decom_3.month_classic_n_claim"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x865f6029cac42be9(["plt_dot_n_patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x865f6029cac42be9(["plt_dot_n_patient"]):::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x6fc1984e55bad138["iadb_decom_2.month_loess_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x6fc1984e55bad138["iadb_decom_2.month_loess_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x6fc1984e55bad138["iadb_decom_2.month_loess_eigen"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xe1974980365c89c4["iadb_decom_1.month_classic_n_patient"]:::errored
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xe1974980365c89c4["iadb_decom_1.month_classic_n_patient"]:::errored
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xe1974980365c89c4["iadb_decom_1.month_classic_n_patient"]:::errored
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xa4b0253d07513712["iadb_decom_3.week_classic_n_claim"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xa4b0253d07513712["iadb_decom_3.week_classic_n_claim"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xa4b0253d07513712["iadb_decom_3.week_classic_n_claim"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x5e3e244db2697b42["iadb_decom_2.week_loess_n_claim"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x5e3e244db2697b42["iadb_decom_2.week_loess_n_claim"]:::outdated
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x5e3e244db2697b42["iadb_decom_2.week_loess_n_claim"]:::outdated
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x0f981af6aa12e97d["iadb_decom_3.month_loess_claim2patient"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x0f981af6aa12e97d["iadb_decom_3.month_loess_claim2patient"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x0f981af6aa12e97d["iadb_decom_3.month_loess_claim2patient"]:::started
    x07ac0b71f920f889>"combineMetrics"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x3902bbed135b0ec7>"getMetrics"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x278d817c06f60e98["iadb_graph"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x3d11ef3bd39493f4(["plt_dot_eigen"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x3d11ef3bd39493f4(["plt_dot_eigen"]):::outdated
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x106e2d5f64c25acd["iadb_decom_1.week_classic_n_claim"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x106e2d5f64c25acd["iadb_decom_1.week_classic_n_claim"]:::outdated
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x106e2d5f64c25acd["iadb_decom_1.week_classic_n_claim"]:::outdated
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x531911f60728b4a0["iadb_decom_1.week_classic_n_patient"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x531911f60728b4a0["iadb_decom_1.week_classic_n_patient"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x531911f60728b4a0["iadb_decom_1.week_classic_n_patient"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xe505b5554cf8f859["iadb_decom_2.week_loess_n_patient"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xe505b5554cf8f859["iadb_decom_2.week_loess_n_patient"]:::outdated
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xe505b5554cf8f859["iadb_decom_2.week_loess_n_patient"]:::outdated
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x3d1fb1c26f3f7c1c["iadb_decom_2.month_classic_n_claim"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x3d1fb1c26f3f7c1c["iadb_decom_2.month_classic_n_claim"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x3d1fb1c26f3f7c1c["iadb_decom_2.month_classic_n_claim"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xe7f418e99185b360["iadb_decom_1.month_classic_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xe7f418e99185b360["iadb_decom_1.month_classic_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xe7f418e99185b360["iadb_decom_1.month_classic_eigen"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xff24d52e667de931["iadb_decom_1.month_loess_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xff24d52e667de931["iadb_decom_1.month_loess_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xff24d52e667de931["iadb_decom_1.month_loess_eigen"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xc8806d466dcd060a["iadb_decom_3.month_loess_pagerank"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xc8806d466dcd060a["iadb_decom_3.month_loess_pagerank"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xc8806d466dcd060a["iadb_decom_3.month_loess_pagerank"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x37635adefd81ee2e["iadb_decom_2.month_classic_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x37635adefd81ee2e["iadb_decom_2.month_classic_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x37635adefd81ee2e["iadb_decom_2.month_classic_eigen"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xbb03b32198e1af45["iadb_decom_2.month_loess_n_patient"]:::errored
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xbb03b32198e1af45["iadb_decom_2.month_loess_n_patient"]:::errored
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xbb03b32198e1af45["iadb_decom_2.month_loess_n_patient"]:::errored
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x519262b59e9e7ed6["iadb_decom_1.week_classic_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x519262b59e9e7ed6["iadb_decom_1.week_classic_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x519262b59e9e7ed6["iadb_decom_1.week_classic_claim2patient"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x6c1cec40b0e2ec9b["iadb_decom_2.month_loess_n_claim"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x6c1cec40b0e2ec9b["iadb_decom_2.month_loess_n_claim"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x6c1cec40b0e2ec9b["iadb_decom_2.month_loess_n_claim"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xa4c7c6e9a9280612["iadb_decom_1.month_loess_n_patient"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xa4c7c6e9a9280612["iadb_decom_1.month_loess_n_patient"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xa4c7c6e9a9280612["iadb_decom_1.month_loess_n_patient"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x2afabb5fd5cdaa9f["iadb_decom_1.month_loess_pagerank"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x2afabb5fd5cdaa9f["iadb_decom_1.month_loess_pagerank"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x2afabb5fd5cdaa9f["iadb_decom_1.month_loess_pagerank"]:::uptodate
    x07ac0b71f920f889>"combineMetrics"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    xc082a51377a349bf>"fieldSummary"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x6db7c8faac9f753f["iadb_decom_2.month_loess_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x6db7c8faac9f753f["iadb_decom_2.month_loess_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x6db7c8faac9f753f["iadb_decom_2.month_loess_claim2patient"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x1379d69e1cca6623["iadb_decom_3.month_classic_n_patient"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x1379d69e1cca6623["iadb_decom_3.month_classic_n_patient"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x1379d69e1cca6623["iadb_decom_3.month_classic_n_patient"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xec4745325b7be7bc(["plt_dot_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xec4745325b7be7bc(["plt_dot_n_claim"]):::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xb5fdf68fe68ea382["iadb_decom_1.month_classic_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xb5fdf68fe68ea382["iadb_decom_1.month_classic_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xb5fdf68fe68ea382["iadb_decom_1.month_classic_claim2patient"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xe3d6d81019c65f5c["iadb_decom_1.week_loess_n_patient"]:::errored
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xe3d6d81019c65f5c["iadb_decom_1.week_loess_n_patient"]:::errored
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xe3d6d81019c65f5c["iadb_decom_1.week_loess_n_patient"]:::errored
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x16e47712e1b5e9f3["iadb_decom_3.month_classic_pagerank"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x16e47712e1b5e9f3["iadb_decom_3.month_classic_pagerank"]:::outdated
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x16e47712e1b5e9f3["iadb_decom_3.month_classic_pagerank"]:::outdated
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x26a981f27eebb281["iadb_decom_3.month_classic_claim2patient"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x26a981f27eebb281["iadb_decom_3.month_classic_claim2patient"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x26a981f27eebb281["iadb_decom_3.month_classic_claim2patient"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x636bdf1680d25c19["iadb_decom_2.month_classic_pagerank"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x636bdf1680d25c19["iadb_decom_2.month_classic_pagerank"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x636bdf1680d25c19["iadb_decom_2.month_classic_pagerank"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x9bfa21505edcc728["iadb_decom_3.week_loess_n_patient"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x9bfa21505edcc728["iadb_decom_3.week_loess_n_patient"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x9bfa21505edcc728["iadb_decom_3.week_loess_n_patient"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x357dd91cda8a724c["iadb_decom_2.month_classic_n_patient"]:::errored
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x357dd91cda8a724c["iadb_decom_2.month_classic_n_patient"]:::errored
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x357dd91cda8a724c["iadb_decom_2.month_classic_n_patient"]:::errored
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x7fad677f63040cc7["iadb_decom_3.month_loess_n_patient"]:::errored
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x7fad677f63040cc7["iadb_decom_3.month_loess_n_patient"]:::errored
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x7fad677f63040cc7["iadb_decom_3.month_loess_n_patient"]:::errored
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x0cfdaf286c3c75ee["iadb_decom_1.month_classic_pagerank"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x0cfdaf286c3c75ee["iadb_decom_1.month_classic_pagerank"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x0cfdaf286c3c75ee["iadb_decom_1.month_classic_pagerank"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x7b8fd5249f3f25bd["iadb_decom_2.week_classic_n_claim"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x7b8fd5249f3f25bd["iadb_decom_2.week_classic_n_claim"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x7b8fd5249f3f25bd["iadb_decom_2.week_classic_n_claim"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x59af7cdef36bb25b["iadb_decom_1.month_classic_n_claim"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x59af7cdef36bb25b["iadb_decom_1.month_classic_n_claim"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x59af7cdef36bb25b["iadb_decom_1.month_classic_n_claim"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x57a94832b8e0cdeb["iadb_decom_2.week_classic_n_patient"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x57a94832b8e0cdeb["iadb_decom_2.week_classic_n_patient"]:::outdated
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x57a94832b8e0cdeb["iadb_decom_2.week_classic_n_patient"]:::outdated
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xbb69940df4b3584b["iadb_decom_1.week_loess_pagerank"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xbb69940df4b3584b["iadb_decom_1.week_loess_pagerank"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xbb69940df4b3584b["iadb_decom_1.week_loess_pagerank"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x3119eb94d17a33b7["iadb_decom_3.week_loess_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x3119eb94d17a33b7["iadb_decom_3.week_loess_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x3119eb94d17a33b7["iadb_decom_3.week_loess_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xcc5d4ac867cad085(["plt_dot_pagerank"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xcc5d4ac867cad085(["plt_dot_pagerank"]):::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x759a9c8a991341c1["iadb_decom_2.week_classic_pagerank"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x759a9c8a991341c1["iadb_decom_2.week_classic_pagerank"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x759a9c8a991341c1["iadb_decom_2.week_classic_pagerank"]:::uptodate
    x4a5693aa168fe170{{"iadb"}}:::uptodate --> xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate
    x8d5064cb2dc0b750>"readIADB"]:::uptodate --> xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xd3eb72e56b6e1f48["iadb_decom_2.week_classic_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xd3eb72e56b6e1f48["iadb_decom_2.week_classic_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xd3eb72e56b6e1f48["iadb_decom_2.week_classic_eigen"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xe71b5cbcc874e1ce["iadb_decom_2.month_classic_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xe71b5cbcc874e1ce["iadb_decom_2.month_classic_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xe71b5cbcc874e1ce["iadb_decom_2.month_classic_claim2patient"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x93f838992b24555f["iadb_decom_3.week_classic_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x93f838992b24555f["iadb_decom_3.week_classic_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x93f838992b24555f["iadb_decom_3.week_classic_eigen"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x75950e6141ded4b1["iadb_decom_3.week_classic_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x75950e6141ded4b1["iadb_decom_3.week_classic_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x75950e6141ded4b1["iadb_decom_3.week_classic_claim2patient"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x092ec311a4c36d08["iadb_decom_2.week_classic_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x092ec311a4c36d08["iadb_decom_2.week_classic_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x092ec311a4c36d08["iadb_decom_2.week_classic_claim2patient"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x9fcdc73f0ac64556["iadb_decom_3.week_loess_pagerank"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x9fcdc73f0ac64556["iadb_decom_3.week_loess_pagerank"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x9fcdc73f0ac64556["iadb_decom_3.week_loess_pagerank"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x5f8a19143c83ab93["iadb_decom_1.week_classic_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x5f8a19143c83ab93["iadb_decom_1.week_classic_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x5f8a19143c83ab93["iadb_decom_1.week_classic_eigen"]:::uptodate
    xf2831b13ede46eac(["iadb_metrics"]):::uptodate --> x50845f0ded6a477d(["iadb_ts"]):::uptodate
    x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate --> x50845f0ded6a477d(["iadb_ts"]):::uptodate
    x6c212354357aadc8>"mergeTS"]:::uptodate --> x50845f0ded6a477d(["iadb_ts"]):::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x288db8c91948fcce["iadb_decom_3.month_loess_n_claim"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x288db8c91948fcce["iadb_decom_3.month_loess_n_claim"]:::outdated
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x288db8c91948fcce["iadb_decom_3.month_loess_n_claim"]:::outdated
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x93fcd98a47f543d4["iadb_decom_3.week_classic_pagerank"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x93fcd98a47f543d4["iadb_decom_3.week_classic_pagerank"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x93fcd98a47f543d4["iadb_decom_3.week_classic_pagerank"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x4a2f40a4a3218c7b["iadb_decom_1.month_loess_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x4a2f40a4a3218c7b["iadb_decom_1.month_loess_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x4a2f40a4a3218c7b["iadb_decom_1.month_loess_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x5680850cf061ee74(["plt_dot_claim2patient"]):::outdated
    x203d559dcf99559c>"vizDot"]:::uptodate --> x5680850cf061ee74(["plt_dot_claim2patient"]):::outdated
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xa7449dc48b4b0bd9["iadb_decom_1.week_loess_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xa7449dc48b4b0bd9["iadb_decom_1.week_loess_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xa7449dc48b4b0bd9["iadb_decom_1.week_loess_eigen"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x1f196735de19126a["iadb_decom_3.month_loess_eigen"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x1f196735de19126a["iadb_decom_3.month_loess_eigen"]:::outdated
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x1f196735de19126a["iadb_decom_3.month_loess_eigen"]:::outdated
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xe3752d20020339fc["iadb_decom_3.month_classic_eigen"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xe3752d20020339fc["iadb_decom_3.month_classic_eigen"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xe3752d20020339fc["iadb_decom_3.month_classic_eigen"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x6354a23f4ae1fdef["iadb_decom_3.week_loess_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x6354a23f4ae1fdef["iadb_decom_3.week_loess_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x6354a23f4ae1fdef["iadb_decom_3.week_loess_claim2patient"]:::uptodate
    x9ca1aa7607080a7b>"mkGraph"]:::uptodate --> x278d817c06f60e98["iadb_graph"]:::uptodate
    xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate --> x278d817c06f60e98["iadb_graph"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xfc5d20144620d087["iadb_decom_2.month_loess_pagerank"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xfc5d20144620d087["iadb_decom_2.month_loess_pagerank"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xfc5d20144620d087["iadb_decom_2.month_loess_pagerank"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x0de7810f5a214a5c["iadb_decom_3.week_classic_n_patient"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x0de7810f5a214a5c["iadb_decom_3.week_classic_n_patient"]:::outdated
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x0de7810f5a214a5c["iadb_decom_3.week_classic_n_patient"]:::outdated
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x17cce5f542c5a503["iadb_decom_1.week_loess_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x17cce5f542c5a503["iadb_decom_1.week_loess_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x17cce5f542c5a503["iadb_decom_1.week_loess_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x8c1d7a9905b41e74(["groupname"]):::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x1d9f32491126cb20["iadb_decom_3.week_loess_n_claim"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x1d9f32491126cb20["iadb_decom_3.week_loess_n_claim"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x1d9f32491126cb20["iadb_decom_3.week_loess_n_claim"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x0d415f6bf13ef14c["iadb_decom_2.week_loess_eigen"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x0d415f6bf13ef14c["iadb_decom_2.week_loess_eigen"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x0d415f6bf13ef14c["iadb_decom_2.week_loess_eigen"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xe8c2223347d4e0a1["iadb_decom_1.month_loess_n_claim"]:::started
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xe8c2223347d4e0a1["iadb_decom_1.month_loess_n_claim"]:::started
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xe8c2223347d4e0a1["iadb_decom_1.month_loess_n_claim"]:::started
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xf386493cc11a73c9["iadb_decom_1.week_loess_n_claim"]:::outdated
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xf386493cc11a73c9["iadb_decom_1.week_loess_n_claim"]:::outdated
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xf386493cc11a73c9["iadb_decom_1.week_loess_n_claim"]:::outdated
    xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate --> x960707f0c582886a(["tbl_iadb_by_date"]):::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> xd1ca86cd22ff7f74["iadb_decom_2.week_loess_claim2patient"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xd1ca86cd22ff7f74["iadb_decom_2.week_loess_claim2patient"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> xd1ca86cd22ff7f74["iadb_decom_2.week_loess_claim2patient"]:::uptodate
    x8c1d7a9905b41e74(["groupname"]):::uptodate --> x4aac79c5b1f8d8d8["iadb_decom_2.week_loess_pagerank"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x4aac79c5b1f8d8d8["iadb_decom_2.week_loess_pagerank"]:::uptodate
    xc78421dd0f40e7eb>"timeDecomp"]:::uptodate --> x4aac79c5b1f8d8d8["iadb_decom_2.week_loess_pagerank"]:::uptodate
    x771a367f0ef7807a>"iterby"]:::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x7514d3a2992ccd63>"splitAtc"]:::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x960707f0c582886a(["tbl_iadb_by_date"]):::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x6e52cb0f1668cc22(["readme"]):::started --> x6e52cb0f1668cc22(["readme"]):::started
    x2166607dfe6e75f2{{"funs"}}:::uptodate --> x2166607dfe6e75f2{{"funs"}}:::uptodate
    x2d15849e3198e8d1{{"pkgs"}}:::uptodate --> x2d15849e3198e8d1{{"pkgs"}}:::uptodate
    xea1cdd6f009574c2{{"pkgs_load"}}:::uptodate --> xea1cdd6f009574c2{{"pkgs_load"}}:::uptodate
    x3ac540af10f1b504{{"iadb_raw"}}:::uptodate --> x3ac540af10f1b504{{"iadb_raw"}}:::uptodate
    xfb5278c6bbbf3460>"lsData"]:::uptodate --> xfb5278c6bbbf3460>"lsData"]:::uptodate
    xe1d1bcdb96b9c2dc{{"is_test"}}:::uptodate --> xe1d1bcdb96b9c2dc{{"is_test"}}:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef errored stroke:#000000,color:#ffffff,fill:#C93312;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 5 stroke-width:0px;
  linkStyle 6 stroke-width:0px;
  linkStyle 222 stroke-width:0px;
  linkStyle 223 stroke-width:0px;
  linkStyle 224 stroke-width:0px;
  linkStyle 225 stroke-width:0px;
  linkStyle 226 stroke-width:0px;
  linkStyle 227 stroke-width:0px;
  linkStyle 228 stroke-width:0px;
```
