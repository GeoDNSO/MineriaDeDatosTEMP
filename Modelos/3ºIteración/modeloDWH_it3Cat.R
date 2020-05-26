#Iteración 3

require(RMySQL) #if already installed
require(scatterplot3d)

#Libera memoria
rm(list=ls())

#---------------------------------------------------------------------------------------------------------------
#-----------Durante la 3º iteración se hicieron pruebas categorizando la variable Número de Parados,------------ 
#-----------este script es similar al de la anterior iteración pero probando a clasificar con nClass,-----------
#-------------tras hacer unas pruebas vimos que realizar nClass con Sturges daba buenos resultados--------------
#---------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------
#-----------------------------NumParados a partir de IPC y Deuda Pública desde 2005------------------------
#----------------------------------------------------------------------------------------------------------


paradosBD <- dbGetQuery(con, sqlParados)
turistasBD <- dbGetQuery(con, sqlTuristas)
ipcBD <- dbGetQuery(con, sqlIPC)
deudaPubBD <- dbGetQuery(con, sqlDeudaPublica)



#Filtrar los datos NA

ipcPrePred <- ipcBD[-c(1:4),]
ipcPrePred <- ipcBD[-c(178:182),]
paradosPrePred <- paradosBD[-c(182:192),]
paradosPrePred <- paradosPrePred[-c(1:4),]
deudaPrePred <- deudaPubBD[-c(1:4),]
deudaPrePred <- deudaPubBD[-c(178:192),]

#----- UNIR DATA FRAMES


#--------CON SERIES TEMP------------------


vectorIPC <- unlist(ipcPrePred$Indice, use.names = FALSE)
vectorParados <- unlist(paradosPrePred$numParados, use.names = FALSE)
vectorDeudaPub <- unlist(deudaPrePred$deudaPubPIB, use.names = FALSE)


#-----------Prueba de categorización del número de parados, el resultado es una división en 9 Grupos-----------


#Calculamos el numero de intervalos
#k = nclass.FD(vectorParados)
k = nclass.Sturges(vectorParados)

#Calculamos la amplitud
A = diff(range(vectorParados))/k

A = ceiling(A)

#Calculamos el elemento minimo para poner los intervalos
m = min(vectorParados)

L = m - 0.05 + A * (0:k)
L

marcas = (L[0:k] + L[1:k+1])/2
marcas

#etiq = c("grado 1", "grado 2", "grado 3","grado 4","grado 5","grado 6","grado 7")

corte = cut(vectorParados, breaks=L, labels=marcas, right=FALSE)
corte

f_abs=as.vector(table(corte))
f_abs_acum=cumsum(table(corte))
f_rel=as.vector(prop.table(table(corte)))
f_rel_acum=cumsum(prop.table(table(corte)))
tabla_frec=data.frame(marcas, f_abs, f_abs_acum, f_rel, f_rel_acum)
tabla_frec 

#---------Vuelta a la regresión como en la anterior iteración--------

matriz <- cbind(vectorIPC, vectorParados, vectorDeudaPub, corte)

serieTemp <- ts(matriz, start = c(2005, 5), frequency = 12)

serieTemp

cor(serieTemp)

#Semilla y division para entrenamiento

set.seed(1)

ind <- sample(2, nrow(matriz), replace=TRUE, prob=c(0.9, 0.1))
head(ind, 10)
# [1] 1 1 1 1 2 1 1 1 1 1
trainData <- matriz[ind==1,] ; dim(trainData)
# [1] 112 5
testData <- matriz[ind==2,] ; dim(testData)


#----CON LM


cor(ipcPrePred$Indice, paradosPrePred$numParados)

cor(trainData[,1], trainData[,2])# 1 --> IPC, 2 --> Parados

ipcTrain <- trainData[,1]
paradTrain <- trainData[,2]

pred <- lm(ipcTrain ~ paradTrain)

pred

attributes(pred)

pred$coefficients

summary(pred)

hist(pred$residuals)

layout(matrix(c(1,2,3,4),2,2)) # 4 gráficos por ventana 
plot(pred)
layout(matrix(1)) # Restauración del valor inicial 


