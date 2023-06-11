# Ensemble de arboles de decision
# utilizando el naif metodo de Arboles Azarosos
# entreno cada arbol utilizando un subconjunto distinto de atributos del dataset

# limpio la memoria
rm(list = ls()) # Borro todos los objetos
gc() # Garbage Collection

require("data.table")
require("rpart")

# parmatros experimento
PARAM <- list()
PARAM$experimento <- 3210

# Establezco la semilla aleatoria, cambiar por SU primer semilla
PARAM$semilla <- 558149

# parameetros rpart
#PARAM$rpart_param <- list(
#  "cp" = -0.195447565300536,
#  "minsplit" = 1772,
#  "minbucket" = 883,
#  "maxdepth" = 5
#)


# parametros  arbol
# entreno cada arbol con solo 50% de las variables variables
PARAM$feature_fraction <- 0.5
# voy a generar 500 arboles, a mas arboles mas tiempo de proceso y MEJOR MODELO,
# pero ganancias marginales
PARAM$num_trees_max <- 1500

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# Aqui comienza el programa

# Aqui se debe poner la carpeta de la computadora local
setwd("G:\\Otros ordenadores\\Mi Portátil\\GOOGLE DRIVE\\austral_posta\\MCD\\lab1\\datasets") # Establezco el Working Directory

# cargo los datos
dataset <- fread("./dataset_pequeno.csv")

# agrego tantos canaritos como variables tiene el dataset
for (i in 1:ncol(dataset)) {
  dataset[, paste0("canarito", i) := runif(nrow(dataset))]
}

dtrain <- dataset[foto_mes == 202107]
dapply <- dataset[foto_mes == 202109]




# creo la carpeta donde va el experimento
dir.create("./exp/", showWarnings = FALSE)
carpeta_experimento <- paste0("./exp/KA", PARAM$experimento, "/")
dir.create(paste0("./exp/KA", PARAM$experimento, "/"),
           showWarnings = FALSE
)

setwd(carpeta_experimento)


# que tamanos de ensemble grabo a disco, pero siempre debo generar los 500
grabar <- c(110, 200, 300, 420, 550, 750, 950, 1500)
#grabar <- c(1000,2000)

# aqui se va acumulando la probabilidad del ensemble
dapply[, prob_acumulada := 0]

# Establezco cuales son los campos que puedo usar para la prediccion
# el copy() es por la Lazy Evaluation
campos_buenos <- copy(setdiff(colnames(dtrain), c("clase_ternaria")))


# Genero las salidas
set.seed(PARAM$semilla) # Establezco la semilla aleatoria

for (arbolito in 1:PARAM$num_trees_max) {
  qty_campos_a_utilizar <- as.integer(length(campos_buenos)
                                      * PARAM$feature_fraction)
  
  campos_random <- sample(campos_buenos, qty_campos_a_utilizar)
  
  # paso de un vector a un string con los elementos
  # separados por un signo de "+"
  # este hace falta para la formula
  campos_random <- paste(campos_random, collapse = " + ")
  
  # armo la formula para rpart
  formulita <- paste0("clase_ternaria ~ ", campos_random)
  
  # genero el arbol de decision
  modelo_original <- rpart(
    formulita,
    data = dtrain,
    model = TRUE,
    xval = 0,
    cp = -1,
    minsplit = 2, # dejo que crezca y corte todo lo que quiera
    minbucket = 1,
    maxdepth = 30
  )
  
  
  # hago el pruning de los canaritos
  # haciendo un hackeo a la estructura  modelo_original$frame
  # -666 es un valor arbritrariamente negativo que jamas es generado por rpart
  modelo_original$frame[
    modelo_original$frame$var %like% "canarito",
    "complexity"
  ] <- -666
  
  modelo_pruned <- prune(modelo_original, -666)
  
  # aplico el modelo a los datos que no tienen clase
  prediccion <- predict(modelo_pruned, dapply, type = "prob")
  
  dapply[, prob_acumulada := prob_acumulada + prediccion[, "BAJA+2"]]
  
  if (arbolito %in% grabar) {
    # Genero la entrega para Kaggle
    umbral_corte <- (1 / 40) * arbolito
    entrega <- as.data.table(list(
      "numero_de_cliente" = dapply[, numero_de_cliente],
      "Predicted" = as.numeric(dapply[, prob_acumulada] > umbral_corte)
    )) # genero la salida
    
    nom_arch <- paste0(
      "KA", PARAM$experimento, "_",
      sprintf("%.3d", arbolito), # para que tenga ceros adelante
      ".csv"
    )
    fwrite(entrega,
           file = nom_arch,
           sep = ","
    )
    
    cat(arbolito, " ")
  }
}
