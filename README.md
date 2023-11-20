
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
    x5b3426b4c7fa7dbc([""Started""]):::started --- xbf4603d6c2c2ad6b([""Stem""]):::none
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
    xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate --> x960707f0c582886a(["tbl_iadb_by_date"]):::uptodate
    x07ac0b71f920f889>"combineMetrics"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    xc082a51377a349bf>"fieldSummary"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate --> x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x14d4712ddbe7d483(["dotplot_eigen"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x14d4712ddbe7d483(["dotplot_eigen"]):::uptodate
    x4a5693aa168fe170{{"iadb"}}:::uptodate --> xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate
    x8d5064cb2dc0b750>"readIADB"]:::uptodate --> xf220e84da6d0ff6f(["tbl_iadb"]):::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x1491e8016ae7ee3f(["dotplot_pagerank"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x1491e8016ae7ee3f(["dotplot_pagerank"]):::uptodate
    x771a367f0ef7807a>"iterby"]:::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x7514d3a2992ccd63>"splitAtc"]:::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x960707f0c582886a(["tbl_iadb_by_date"]):::uptodate --> xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> x61c7c735846b2fdc(["dotplot_claim2patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> x61c7c735846b2fdc(["dotplot_claim2patient"]):::uptodate
    xf2831b13ede46eac(["iadb_metrics"]):::uptodate --> x50845f0ded6a477d(["iadb_ts"]):::uptodate
    x6bbf38eac08a1fe8(["iadb_stats"]):::uptodate --> x50845f0ded6a477d(["iadb_ts"]):::uptodate
    x6c212354357aadc8>"mergeTS"]:::uptodate --> x50845f0ded6a477d(["iadb_ts"]):::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xa2ab490bcc111d90(["dotplot_n_claim"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xa2ab490bcc111d90(["dotplot_n_claim"]):::uptodate
    x50845f0ded6a477d(["iadb_ts"]):::uptodate --> xdc89b29ed5f4121e(["dotplot_n_patient"]):::uptodate
    x203d559dcf99559c>"vizDot"]:::uptodate --> xdc89b29ed5f4121e(["dotplot_n_patient"]):::uptodate
    x9ca1aa7607080a7b>"mkGraph"]:::uptodate --> x278d817c06f60e98["iadb_graph"]:::uptodate
    xf7e9b577faef0a3a["tbl_iadb_split_atc"]:::uptodate --> x278d817c06f60e98["iadb_graph"]:::uptodate
    x07ac0b71f920f889>"combineMetrics"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x3902bbed135b0ec7>"getMetrics"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x278d817c06f60e98["iadb_graph"]:::uptodate --> xf2831b13ede46eac(["iadb_metrics"]):::uptodate
    x6e52cb0f1668cc22(["readme"]):::started --> x6e52cb0f1668cc22(["readme"]):::started
    x2166607dfe6e75f2{{"funs"}}:::uptodate --> x2166607dfe6e75f2{{"funs"}}:::uptodate
    x2d15849e3198e8d1{{"pkgs"}}:::uptodate --> x2d15849e3198e8d1{{"pkgs"}}:::uptodate
    xea1cdd6f009574c2{{"pkgs_load"}}:::uptodate --> xea1cdd6f009574c2{{"pkgs_load"}}:::uptodate
    x3ac540af10f1b504{{"iadb_raw"}}:::uptodate --> x3ac540af10f1b504{{"iadb_raw"}}:::uptodate
    xfb5278c6bbbf3460>"lsData"]:::uptodate --> xfb5278c6bbbf3460>"lsData"]:::uptodate
    xe1d1bcdb96b9c2dc{{"is_test"}}:::uptodate --> xe1d1bcdb96b9c2dc{{"is_test"}}:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 39 stroke-width:0px;
  linkStyle 40 stroke-width:0px;
  linkStyle 41 stroke-width:0px;
  linkStyle 42 stroke-width:0px;
  linkStyle 43 stroke-width:0px;
  linkStyle 44 stroke-width:0px;
  linkStyle 45 stroke-width:0px;
```
