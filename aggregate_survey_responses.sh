#!/bin/bash
SE_PATH=/home/nettrom/src/Growth-welcomesurvey-2018
CONDA_ENV_NAME="growth_team"

cd $SE_PATH
{
  date

  echo "Running monthly aggregation of Welcome Survey responses"

  source conda-activate-stacked $CONDA_ENV_NAME

  # We add /usr/local/bin to the path because analytics-mysql is there and it's needed
  export PATH=/usr/local/bin:$PATH

  # These are needed because the Welcome Survey aggregation grabs wiki configuration
  # data from repository mirrors on GitHub
  export http_proxy=http://webproxy.eqiad.wmnet:8080
  export https_proxy=http://webproxy.eqiad.wmnet:8080

  # The processor timeout setting is important here because aggregating all the answers
  # takes a while as we've got hundreds of wikis to check. Two hours seems reasonable based
  # on time-per-wiki as of December 2021.
  jupyter nbconvert --ExecutePreprocessor.timeout=7200 \
       --to html --execute T275172_survey_aggregation.ipynb
  hdfs dfs -chmod -R o+rx /user/hive/warehouse/growth_welcomesurvey.db/monthly_overview
  hdfs dfs -chmod -R o+rx /user/hive/warehouse/growth_welcomesurvey.db/survey_response_aggregates
} >> $SE_PATH/survey_response_aggregation.log 2>&1
