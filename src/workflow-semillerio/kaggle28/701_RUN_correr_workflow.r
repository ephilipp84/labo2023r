# Corrida general del workflow Semillerio

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})

source("~/labo2023r/src/workflow-semillerio/kaggle25/771_ZZ_final_semillerio.r")

# corrida de cada paso del workflow
source("~/labo2023r/src/workflow-semillerio/kaggle28/711_CA_reparar_dataset.r")
source("~/labo2023r/src/workflow-semillerio/kaggle28/721_DR_corregir_drifting.r")
source("~/labo2023r/src/workflow-semillerio/kaggle28/731_FE_historia.r")
source("~/labo2023r/src/workflow-semillerio/kaggle28/741_TS_training_strategy.r")
source("~/labo2023r/src/workflow-semillerio/kaggle28/751_HT_lightgbm.r")



source("~/labo2023r/src/workflow-semillerio/kaggle28/771_ZZ_final_semillerio.r")
#source("~/labo2023r/src/workflow-semillerio/kaggle2/781_ZZ_semillerios_hibridacion.r")