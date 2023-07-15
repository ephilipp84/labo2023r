# Corrida general del workflow

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})


# corrida de cada paso del workflow

# primeros pasos, relativamente rapidos
source("~/labo2023r/src/workflow-inicial/wfv8/wfv8611_CA_reparar_dataset.r")
source("~/labo2023r/src/workflow-inicial/wfv8/wfv8621_DR_corregir_drifting.r")
source("~/labo2023r/src/workflow-inicial/wfv8/wfv8631_FE_historia.r")
source("~/labo2023r/src/workflow-inicial/wfv8/wfv8641_TS_training_strategy.r")

# ultimos pasos, muy lentos
source("~/labo2023r/src/workflow-inicial/wfv8/wfv8651_HT_lightgbm.r")
source("~/labo2023r/src/workflow-inicial/wfv8/wfv8661_ZZ_final.r")
