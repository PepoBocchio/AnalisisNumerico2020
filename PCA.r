###########################################################
#             UNIVERSIDAD DE BUENOS AIRES                 #
#           FACULTAD DE CIENCIAS ECON�MICAS               #
###########################################################

## Asignatura: AN�LISIS NUM�RICO
## A�o Lectivo: 2020
## Docente: Mauro Speranza - Mart�n Masci - Rodrigo Del Rosso

################################
####### SETEO DE CARPETA #######
################################

getwd()

dir()

directorio <- "/ruta"  ## colocar la ruta entre comillas

setwd(directorio)

getwd() ## verifico si me modific� la ruta

## permite cambiar el directorio donde estamos trabajando (working directory)
## Hay que tener en cuenta que los datos se guardar�n en ese directorio

#########################
####### LIBRERIAS #######
#########################

library(ggplot2)
library(faraway)
library(FactoMineR)
library(cluster) 
library(gridExtra)
library(dplyr)
library(factoextra)

###################
####### PCA #######
###################

## % de asaltos (Assault), asesinatos (Murder) y secuestros (Rape) 
## por cada 100,000 habitantes para cada uno de los 50 estados de USA (1973). 
## Adem�s, tambi�n incluye el porcentaje de la poblaci�n de cada estado 
## que vive en zonas rurales (UrbanPoP).

data("USArrests")
head(USArrests)

View(USArrests)

## la funci�n prcomp es una de las m�ltiples funciones en R que realizan PCA
## por defecto centra las variables para que tengan media cero, pero si se quiere adem�s
## que su desviaci�n est�ndar sea de uno, hay que indicar scale = TRUE

pca <- prcomp(USArrests, scale = TRUE)
names(pca)

summary(pca)

## Los elementos center y scale y	almacenados en el objeto pca
## contienen la media y desviaci�n t�pica de las variables 
## previa estandarizaci�n (en la escala original).

pca$center
apply(X = USArrests, MARGIN = 2, FUN = mean) #ac� armamos la media para comparar

pca$scale
apply(X = USArrests, MARGIN = 2, FUN = sd) #ac� armamos la varianza para comparar

## rotation contiene el valor de los loadings para cada componente (eigenvector).
## El n�mero m�ximo de componentes principales se corresponde con el m�nimo(n-1,p), 
## que en este caso es min(49,4)=4

pca$rotation

## Analizar con detalle el vector de loadings que forma cada componente
## puede ayudar a interpretar que tipo de informaci�n recoge cada una de ellas
## La funci�n	prcomp() calcula autom�ticamente el valor de las componentes principales
## para cada observaci�n (principal component scores) 
## multiplicando los datos por los vectores de loadings. 
## El resultado se almacena en la matriz x.

head(pca$x)

dim(pca$x)

## Mediante la funci�n biplot()	se puede obtener una 
## representaci�n bidimensional de las dos primeras componentes

biplot(x = pca, scale = 0, cex = 0.6, col = c("blue4", "brown3"))

## La imagen especular, cuya interpretaci�n es equivalente, se puede obtener 
## invirtiendo el signo de los loadings y de los principal component scores.

pca$rotation <- -pca$rotation
pca$x        <- -pca$x
biplot(x = pca, scale = 0, cex = 0.6, col = c("blue4", "brown3"))

## Una vez calculadas las componentes principales, 
## se puede conocer la varianza explicada por cada una de ellas, 
## la proporci�n respecto al total y la proporci�n de varianza acumulada.

pca$sdev
pca$sdev^2

prop_varianza <- pca$sdev^2 / sum(pca$sdev^2)
prop_varianza

summary(pca)

VE <- ggplot(data = data.frame(prop_varianza, pc = 1:4),
       aes(x = pc, y = prop_varianza)) +
  geom_col(width = 0.3) +
  scale_y_continuous(limits = c(0,1)) +
  theme_bw() +
  labs(x = "Componente Principal",
       y = "En %") +
  ggtitle("Varianza Explicada", subtitle = "Por Factor")

#dev.off()  #cerrar el gr�fico

prop_varianza_acum <- cumsum(prop_varianza)
prop_varianza_acum

VAE <- ggplot(data = data.frame(prop_varianza_acum, pc = 1:4),
       aes(x = pc, y = prop_varianza_acum, group = 1)) +
  geom_point() +
  geom_line() +
  theme_bw() +
  labs(x = "Componente Principal",
       y = "En %") +
  ggtitle("Varianza Acumulada Explicada", subtitle = "Por Factor")

grid.arrange(VE, VAE, ncol=2)

## En  este  caso,  la  primera  componente  explica  el  62%  de  la  varianza  
## observada  en  los datos y la segunda el 24.7%. 

## Las dos �ltimas componentes no superan por separado el 1% de varianza explicada. 
## Si se empleasen �nicamente las dos primeras componentes se 
## conseguir�a explicar el 86.75% de la varianza observada.

####################################### OTRO EJEMPLO ##########################################

# Carga de datos inicial, tipos de flores con diferentes caracteristicas 
data(iris)

# Nos quedamos todas las variables excepto la variable dependiente
datos <- iris[-5] 

# Ejecutar el an�lisis de componentes principales PCA
modelo <- prcomp(datos) 

# Mostrar la desviaci�n estandar y la relaci�n de cada variable con cada componente
modelo

# Mostrar un resumen de cada uno de los componentes
# Standard deviation = valores propios de la varianza explicada en cada componente
# Proportion of Variance = porcentaje de varianza explicada por cada factor
# Cumulative Proportion = porcentaje de varianza acumulada explicada por cada factor
summary(modelo)

# Preparaci�n del modelo para mostrar la distinci�n por colores
colores <- as.character(iris$Specie)
colores[colores=="setosa"] <- "red"
colores[colores=="virginica"] <- "black"
colores[colores=="versicolor"] <- "blue"

# Dibujar los pares de componentes
pairs(modelo$x,col=colores) 

# Grafico de PC1 y PC2
plot(modelo$rotation,pch='')
abline(h = 0, v = 0, col = "gray60")
text(modelo$rotation,labels=rownames(modelo$rotation))

# Grafico de PC1 y PC3 
plot(modelo$rotation[,1],modelo$rotation[,3],pch='.')
abline(h = 0, v = 0, col = "gray60")
text(modelo$rotation[,1],modelo$rotation[,3],labels=rownames(modelo$rotation))

# Dibujar la varianza que explica cada factor
plot(modelo)

# Se guardan los dos primeros factores del PCA en un nuevo data.frame para usarlo en un GLM
valoresDeFactores <- modelo$x[,1:2]
str(valoresDeFactores)
View(valoresDeFactores)


####################################### OTRO EJEMPLO ##########################################

#Dataset del desempleo en cada Estado de USA

states <- c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID", "IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO", "MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA", "RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
states

raw <- read.csv("http://www.biz.uiowa.edu/faculty/jledolter/DataMining/unempstates.csv")
dim(raw)

raw[1:3,1:5] # Y las filas continuan hasta la dimensi�n 416

## transponemos la matriz 50 filas (cada uno de los Estados) 
## y 416 columnas (cada Tasa de Desempleo)
rawt <- matrix(nrow=50,ncol=416)
rawt <- t(raw)
rawt[1:3,1:5] # Y las columnas continuan hasta la dimensi�n 416

pcaunemp <- prcomp(rawt,scale=FALSE) # computamos las componentes

head(pcaunemp$sdev) # Aqui vemos las varianzas de las componentes

plot(pcaunemp, main="Varianza de las Componentes")
mtext(side=1,"Desempleo: 50 Estados",line=1,font=2)

pcaunemp$rotation[1:10,1]
## Cargas de la primera componentes. 
## Solo se visualizan las primeras 10 variables 
## Ac� tendremos una ecuaci�n con 416 cargas para cada una de las 
## variables en columna de la matriz de datos original

# Calculamos la Tasa Promedio de Desempleo para todos los Estados 
## para cada uno de los meses en el an�lisis

ave <- dim(416)
for(j in 1:416){
  ave[j] <- mean(rawt[,j])
}


par(mfrow = c(1,2))
## Gr�fica de los valores (negativos) de las cargas de la 1era Componente
plot(-pcaunemp$rotation[,1], 
     main ='Cargas de la primera componente', 
     type = "l")

## Gr�fica de los valores medios de paro para los estados
plot(ave,
     type ="l",
     ylim = c(3,10),
     xlab = "Mes",
     ylab= "Evoluci�n de la Tasa Promedio de Desempleo")

# Calculamos la correlaci�n entre los factores de la primera componente 
## y las Tasas Promedios de Desempleo
abs(cor(ave,pcaunemp$rotation[,1]))

unemppc <- predict(pcaunemp)

## A continuaci�n constru�mos una gr�fica de los estados 
## utilizando solo la informaci�n de las primeras 2 componentes principales. 
## Llevamos a cabo un an�lisis de clusters y pintamos los estados que 
## pertenecen a cada cluster de diferentes colores,

set.seed(123)
grpunemp3 <- kmeans(rawt,centers=3,nstart=10)
par(mfrow=c(1,1))
plot(unemppc[,1:2],type="n")
text(x=unemppc[,1],y=unemppc[,2],labels=states,col=rainbow(7)
     [grpunemp3$cluster])

## OTRO EJEMPLO ## 

data(decathlon)
View(decathlon)

head(decathlon, 3)

res <- PCA(decathlon,quanti.sup=11:12,quali.sup=13)

plot(res,invisible="quali")
plot(res,choix="var",invisible="quanti.sup")
plot(res,habillage=13)

aa <- cbind.data.frame(decathlon[,13],res$ind$coord)
bb <- coord.ellipse(aa,bary=TRUE)

plot.PCA(res,habillage=13,ellipse=bb)

#RESETEO DE SESI�N Y BORRADO DE MEMORIA
rm(list=ls())
.rs.restartR()
gc()
